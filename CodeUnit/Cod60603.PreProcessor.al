codeunit 60603 "Pre-Processor"
{
    SingleInstance = true;

    var
        RecordRef: RecordRef;
        GlobalBatch: Code[10];
        Posted: Boolean;
        GlobalTemplateName: Code[20];
        GlobalBatchName: Code[20];

    procedure ProcessRecord(RecordVariant: Variant): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        ItemJnl: Record "Item Journal Line";
    begin
        Posted := false;
        RecordRef.GetTable(RecordVariant);
        case RecordRef.Number of
            Database::"Gen. Journal Line":
                begin
                    RecordRef.SetTable(GenJnlLine);
                    exit(PostGenJnl(GenJnlLine));
                end;
            Database::"Item Journal Line":
                begin
                    RecordRef.SetTable(ItemJnl);
                    exit(PostItemJnl(ItemJnl));
                end;
            Database::"Purchase Header":
                begin
                    RecordRef.SetTable(PurchaseHeader);
                    exit(PostPurchaseHeader(PurchaseHeader));
                end;
            Database::"Sales Header":
                begin
                    RecordRef.SetTable(SalesHeader);
                    exit(PostSalesHeader(SalesHeader));
                end;
        end;
    end;

    local procedure PostGenJnl(var GenJnl: Record "Gen. Journal Line"): Boolean
    var
        SessionID: Integer;
    begin
        Posted := false;
        GlobalBatch := GenJnl."Journal Batch Name";
        if not GenJnl.IsEmpty then begin
            GlobalTemplateName := GenJnl."Journal Template Name";
            GlobalBatchName := GenJnl."Journal Batch Name";
            Codeunit.Run(Codeunit::"Gen. Jnl.-Post", GenJnl);
        end;
        exit(Posted);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeUpdateAndDeleteLines', '', false, false)]
    local procedure OnBeforeUpdateAndDeleteLines(var GenJournalLine: Record "Gen. Journal Line")
    var

    begin
        Posted := GenJournalLine."Journal Batch Name" = GlobalBatch;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    var

    begin
        if (GlobalTemplateName = GenJournalLine."Journal Template Name")
        and (GlobalBatchName = GenJournalLine."Journal Batch Name")
        then
            HideDialog := true;
    end;

    local procedure PostPurchaseHeader(var PurchaseHeader: Record "Purchase Header"): Boolean
    begin
        if not PurchaseHeader.IsEmpty then begin
            Codeunit.Run(Codeunit::"Purch.-Post (Yes/No)", PurchaseHeader);
            exit(Posted);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(PurchCrMemoHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; var PurchaseHeader: Record "Purchase Header")

    begin
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice,
            PurchaseHeader."Document Type"::"Blanket Order", PurchaseHeader."Document Type"::Quote:
                Posted := not (PurchInvHdrNo = '') or not (PurchRcpHdrNo = '');
            PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order":
                Posted := not (PurchCrMemoHdrNo = '');
        end;
    end;

    local procedure PostSalesHeader(var SalesHeader: Record "Sales Header"): Boolean
    begin
        if not SalesHeader.IsEmpty then begin
            Codeunit.Run(Codeunit::"Sales-Post (Yes/No)", SalesHeader);
            exit(Posted);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesCrMemoHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesShptHdrNo: Code[20])

    begin

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice,
            SalesHeader."Document Type"::"Blanket Order", SalesHeader."Document Type"::Quote:
                Posted := not (SalesInvHdrNo = '') or not (SalesShptHdrNo = '');
            SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order":
                Posted := not (SalesCrMemoHdrNo = '');
        end;
    end;

    local procedure PostItemJnl(var ItenJnlLine: Record "Item Journal Line"): Boolean
    var
        SessionID: Integer;
    begin
        GlobalBatch := ItenJnlLine."Journal Batch Name";
        if not ItenJnlLine.IsEmpty then begin
            GlobalTemplateName := ItenJnlLine."Journal Template Name";
            GlobalBatchName := ItenJnlLine."Journal Batch Name";
            Codeunit.Run(Codeunit::"Item Jnl.-Post", ItenJnlLine);
        end;
        exit(Posted);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnBeforeUpdateDeleteLines', '', false, false)]
    local procedure OnBeforeUpdateAndDeleteItemLines(var ItemJournalLine: Record "Item Journal Line")
    begin
        Posted := ItemJournalLine."Journal Batch Name" = GlobalBatch;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeItemCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean)
    begin
        if (GlobalTemplateName = ItemJournalLine."Journal Template Name")
        and (GlobalBatchName = ItemJournalLine."Journal Batch Name")
        then
            HideDialog := true;
    end;
}