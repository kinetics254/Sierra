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
    begin
        Posted := false;
        RecordRef.GetTable(RecordVariant);
        case RecordRef.Number of
            Database::"Gen. Journal Line":
                begin
                    RecordRef.SetTable(GenJnlLine);
                    exit(PostGenJnl(GenJnlLine));
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
        with PurchaseHeader do begin
            case "Document Type" of
                "Document Type"::Order, "Document Type"::Invoice, "Document Type"::"Blanket Order", "Document Type"::Quote:
                    Posted := not (PurchInvHdrNo = '') or not (PurchRcpHdrNo = '');
                "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                    Posted := not (PurchCrMemoHdrNo = '');
            end;
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
        with SalesHeader do begin
            case "Document Type" of
                "Document Type"::Order, "Document Type"::Invoice, "Document Type"::"Blanket Order", "Document Type"::Quote:
                    Posted := not (SalesInvHdrNo = '') or not (SalesShptHdrNo = '');
                "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                    Posted := not (SalesCrMemoHdrNo = '');
            end;
        end;
    end;
}