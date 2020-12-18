codeunit 60600 "Create General Journal"
{
    SingleInstance = true;

    var
        GenJnlLine: Record "Gen. Journal Line";
        CurrJournalLineNo: Integer;
        GlobalTemplateName: Code[10];
        GlobalBatchName: Code[20];
        GlobalSourceCode: Code[20];
        GlobalReasonCode: Code[20];
        PostingDate: Date;
        DocDate: Date;
        DocNo: Code[20];
        ExtDocNo: Code[20];
        SysCreated: Boolean;
        DocType: Integer;
        AccType: Integer;
        AccountNo: Code[20];
        CurrCode: Code[20];
        Amt: Decimal;
        Desc: Text;
        AppToDocNo: Code[20];
        AppDocType: Integer;
        BalAccNo: Code[20];
        BalAccType: Integer;
        VatBus: Code[20];
        VatProd: Code[20];
        Dim1: Code[20];
        Dim2: Code[20];
        DimSetId: Integer;
        FAPostingType: Integer;
        Posted: Boolean;

    procedure ClearJournalBatch(TemplateName: Code[10]; BatchName: Code[20]; SourceCode: Code[20]; ReasonCode: Code[20]): Boolean
    var
        TempNotDefined: Label 'Journal Template Name not Defined';
        BatchNotDefined: Label 'Journal Batch Not Defined';
    begin
        GlobalTemplateName := '';
        GlobalBatchName := '';
        GlobalSourceCode := '';
        GlobalReasonCode := '';
        if TemplateName = '' then Error(TempNotDefined);
        if BatchName = '' then Error(BatchNotDefined);
        if CheckIfJournalExist(TemplateName, BatchName) then begin
            ResetCurrentLine();
            GlobalTemplateName := TemplateName;
            GlobalBatchName := BatchName;
            GlobalSourceCode := SourceCode;
            GlobalReasonCode := ReasonCode;
            GenJnlLine.Reset();
            GenJnlLine.SetFilter("Journal Template Name", '%1', TemplateName);
            GenJnlLine.SetFilter("Journal Batch Name", '%1', BatchName);
            if GenJnlLine.FindSet() then GenJnlLine.DeleteAll();

        end;
        exit(CheckIfJournalExist(TemplateName, BatchName));
    end;


    local procedure SetJournalDefaults()
    var
        TempNotDefined: Label 'Journal Template Name not Defined';
        BatchNotDefined: Label 'Journal Batch Not Defined';
    begin
        if GlobalTemplateName = '' then Error(TempNotDefined);
        if GlobalBatchName = '' then Error(BatchNotDefined);
        GenJnlLine."Journal Template Name" := GlobalTemplateName;
        GenJnlLine."Journal Batch Name" := GlobalBatchName;
        GenJnlLine."Source Code" := GlobalSourceCode;
        GenJnlLine."Reason Code" := GlobalReasonCode;
    end;

    procedure CallJournalPostRoutine(): Boolean
    var

        SessionID: Integer;
    begin
        Posted := false;

        GenJnlLine.Reset();
        GenJnlLine.SetFilter("Journal Template Name", '%1', GlobalTemplateName);
        GenJnlLine.SetFilter("Journal Batch Name", '%1', GlobalBatchName);
        if GenJnlLine.FindSet() then begin
            ReconcileHeaderLineAmounts(GenJnlLine);
            Codeunit.Run(Codeunit::"Gen. Jnl.-Post", GenJnlLine);

        end;
        exit(Posted);
    end;

    local procedure ClearVaribles()

    begin
        PostingDate := 0D;
        DocDate := 0D;
        DocNo := '';
        ExtDocNo := '';
        SysCreated := false;
        DocType := 0;
        AccType := 0;
        AccountNo := '';
        CurrCode := '';
        Amt := 0;
        Desc := '';
        AppToDocNo := '';
        AppDocType := 0;
        BalAccNo := '';
        BalAccType := 0;
        VatBus := '';
        VatProd := '';
        Dim1 := '';
        Dim2 := '';
        DimSetId := 0;
        FAPostingType := 0;
    end;

    local procedure PackageArray(var VaribleArray: array[30] of Variant)
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(VaribleArray) do begin
            case i of
                1:
                    if VaribleArray[i].IsDate then
                        PostingDate := VaribleArray[i];
                2:
                    if VaribleArray[i].IsDate then
                        DocDate := VaribleArray[i];
                3:
                    if VaribleArray[i].IsCode then
                        DocNo := VaribleArray[i];
                4:
                    if VaribleArray[i].IsCode then
                        ExtDocNo := VaribleArray[i];
                5:
                    if VaribleArray[i].IsBoolean then
                        SysCreated := VaribleArray[i];
                6:
                    if VaribleArray[i].IsInteger then
                        DocType := VaribleArray[i];
                7:
                    if VaribleArray[i].IsInteger then
                        AccType := VaribleArray[i];
                8:
                    if VaribleArray[i].IsCode then
                        AccountNo := VaribleArray[i];
                9:
                    if VaribleArray[i].IsCode then
                        CurrCode := VaribleArray[i];
                10:
                    if VaribleArray[i].IsDecimal then
                        Amt := VaribleArray[i];
                11:
                    if VaribleArray[i].IsText then
                        Desc := VaribleArray[i];
                12:
                    if VaribleArray[i].IsCode then
                        AppToDocNo := VaribleArray[i];
                13:
                    if VaribleArray[i].IsInteger then
                        AppDocType := VaribleArray[i];
                14:
                    if VaribleArray[i].IsCode then
                        BalAccNo := VaribleArray[i];
                15:
                    if VaribleArray[i].IsInteger then
                        BalAccType := VaribleArray[i];
                16:
                    if VaribleArray[i].IsCode then
                        VatBus := VaribleArray[i];
                17:
                    if VaribleArray[i].IsCode then
                        VatProd := VaribleArray[i];
                18:
                    if VaribleArray[i].IsCode then
                        Dim1 := VaribleArray[i];
                19:
                    if VaribleArray[i].IsCode then
                        Dim2 := VaribleArray[i];
                20:
                    if VaribleArray[i].IsInteger then
                        DimSetId := VaribleArray[i];
                21:
                    if VaribleArray[i].IsInteger then
                        FAPostingType := VaribleArray[i];
            end;
        end;

    end;

    procedure CreateJournalLineGLEntry(var VaribleArray: array[30] of Variant)

    begin

        SetJournalDefaults(); //Assign default Journal properties
        ClearVaribles();
        PackageArray(VaribleArray);
        //Reset
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
        GenJnlLine."Applies-to Doc. No." := '';
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Bal. Account No." := '';
        //Reset

        GenJnlLine.Validate("Posting Date", PostingDate);
        GenJnlLine.Validate("Document Date", DocDate);
        GenJnlLine."Line No." := CurrJournalLineNo;
        GenJnlLine."Document No." := DocNo;
        GenJnlLine."External Document No." := ExtDocNo;
        GenJnlLine."System-Created Entry" := SysCreated;
        case DocType of
            0:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";

            1:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
            2:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
            3:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
            4:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Finance Charge Memo";
            5:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Reminder;
            6:
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;

        end;
        case AccType of
            0:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";

            1:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            2:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
            3:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
            4:
                begin
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Fixed Asset";
                    GenJnlLine.Validate("FA Posting Date", PostingDate);
                    case FAPostingType of
                        0:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::" ");
                        1:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::"Acquisition Cost");
                        2:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::Depreciation);
                        3:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::"Write-Down");
                        4:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::Appreciation);
                        5:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::"Custom 1");
                        6:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::"Custom 2");
                        7:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::Disposal);
                        8:
                            GenJnlLine.Validate("FA Posting Type", GenJnlLine."FA Posting Type"::Maintenance);
                    end;
                end;
            5:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"IC Partner";
            6:
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::Employee;


        end;
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine.Validate("Currency Code", CurrCode);
        GenJnlLine.Validate(Amount, Amt);
        GenJnlLine.Description := Desc;
        If AppToDocNo <> '' then begin
            case AppDocType of
                0:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";

                1:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
                2:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                3:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                4:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Finance Charge Memo";
                5:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Reminder;
                6:
                    GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Refund;

            end;
            GenJnlLine.Validate("Applies-to Doc. No.", AppToDocNo);
        end;
        if BalAccNo <> '' then begin
            case BalAccType of
                0:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";

                1:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::Customer;
                2:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::Vendor;
                3:
                    begin
                        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
                        GenJnlLine."Bal. Account No." := BalAccNo;
                    end;

                4:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Fixed Asset";
                5:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"IC Partner";
                6:
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::Employee;


            end;
            GenJnlLine.Validate("Bal. Account No.", BalAccNo);
        end;
        if VatBus <> '' then
            GenJnlLine.Validate("VAT Bus. Posting Group", VatBus);
        if VatProd <> '' then
            GenJnlLine.Validate("VAT Prod. Posting Group", VatProd);
        GenJnlLine.Validate("Pmt. Discount Date", 0D);
        GenJnlLine.Validate("Payment Discount %", 0);
        if GenJnlLine.Amount <> 0 then
            if GenJnlLine.Insert() then begin
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Dim1);
                GenJnlLine.Validate("Shortcut Dimension 2 Code", Dim2);
                if DimSetId <> 0 then
                    GenJnlLine.Validate("Dimension Set ID", DimSetId);
                GenJnlLine.Modify();
                CurrJournalLineNo += 1000;
            end;

    end;

    local procedure ResetCurrentLine()

    begin
        CurrJournalLineNo := 1000;
    end;

    local procedure CheckIfJournalExist(TemplateName: Code[10]; BatchName: Code[20]): Boolean
    var
        GenBatch: Record "Gen. Journal Batch";
    begin
        exit(GenBatch.Get(TemplateName, BatchName));
    end;

    local procedure ReconcileHeaderLineAmounts(GenJnlLine: Record "Gen. Journal Line")
    var
        LineTotalsVar: Decimal;
        DeltaVar: Decimal;
        GnlJnLines: Record "Gen. Journal Line";
    begin
        LineTotalsVar := 0;
        GnlJnLines.Reset();
        GnlJnLines.SetFilter("Journal Template Name", GenJnlLine."Journal Template Name");
        GnlJnLines.SetFilter("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GnlJnLines.SetFilter("Document No.", GenJnlLine."Document No.");
        GnlJnLines.SetFilter("Document Type", '%1', GnlJnLines."Document Type"::Payment);
        GnlJnLines.SetFilter("Account Type", '%1', GnlJnLines."Account Type"::Vendor);
        GnlJnLines.SetFilter("Bal. Account No.", '%1', '');
        if GnlJnLines.FindSet() then
            repeat
                LineTotalsVar += Abs(GnlJnLines."Amount (LCY)");
            until GnlJnLines.Next() = 0;

        GnlJnLines.Reset();
        GnlJnLines.SetFilter("Journal Template Name", GenJnlLine."Journal Template Name");
        GnlJnLines.SetFilter("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GnlJnLines.SetFilter("Document No.", GenJnlLine."Document No.");
        GnlJnLines.SetFilter("Document Type", '%1', GnlJnLines."Document Type"::Payment);
        GnlJnLines.SetFilter("Account Type", '%1', GnlJnLines."Account Type"::"Bank Account");
        GnlJnLines.SetFilter("Bal. Account No.", '%1', '');
        if GnlJnLines.FindSet() then begin
            GnlJnLines.CalcSums("Amount (LCY)");
            DeltaVar := LineTotalsVar - Abs(GnlJnLines."Amount (LCY)");
            if Abs(DeltaVar) < 0.5 then begin
                GnlJnLines.Validate("Amount (LCY)", (GnlJnLines."Amount (LCY)" - DeltaVar));
                GnlJnLines.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeUpdateAndDeleteLines', '', false, false)]
    local procedure OnBeforeUpdateAndDeleteLines(var GenJournalLine: Record "Gen. Journal Line")
    var

    begin
        Posted := GenJournalLine."Journal Batch Name" = GlobalBatchName;
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
}