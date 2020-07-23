codeunit 60600 "Create General Journal"
{
    SingleInstance = true;

    var
        GenJnlLine: Record "Gen. Journal Line";
        CurrJournalLineNo: Integer;
        TempJournal: Record "Journal Temp Table";
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

    procedure ClearJournalBatch(TemplateName: Code[10]; BatchName: Code[20]; SourceCode: Code[20]; ReasonCode: Code[20])
    var

    begin
        if CheckIfJournalExist(TemplateName, BatchName) then begin
            ResetCurrentLine();
            TempJournal.Reset();
            if TempJournal.FindFirst() then TempJournal.DeleteAll();
            with GenJnlLine do begin
                Reset();
                SetFilter("Journal Template Name", '%1', TemplateName);
                SetFilter("Journal Batch Name", '%1', BatchName);
                if FindSet() then DeleteAll();
            end;
            TempJournal."Template Name" := TemplateName;
            TempJournal."Batch Name" := BatchName;
            TempJournal."Source Code" := SourceCode;
            TempJournal."Reason Code" := ReasonCode;
            TempJournal.Insert();
        end;
    end;


    local procedure SetJournalDefaults()
    var

    begin
        TempJournal.Get();
        with GenJnlLine do begin
            "Journal Template Name" := TempJournal."Template Name";
            "Journal Batch Name" := TempJournal."Batch Name";
            "Source Code" := TempJournal."Source Code";
            "Reason Code" := TempJournal."Reason Code";
        end;
    end;

    procedure CallJournalPostRoutine()

    begin
        TempJournal.Get();
        with GenJnlLine do begin
            Reset();
            SetFilter("Journal Template Name", '%1', TempJournal."Template Name");
            SetFilter("Journal Batch Name", '%1', TempJournal."Batch Name");
            if FindSet() then begin
                ReconcileHeaderLineAmounts(GenJnlLine);
                Codeunit.Run(Codeunit::"Gen. Jnl.-Post", GenJnlLine)
            end;
        end;
    end;

    local procedure ClearVaribles()

    begin
        PostingDate := 0D;
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
    end;

    local procedure PackageArray(var VaribleArray: array[30] of Variant)
    var
        i: Integer;
    begin
        i := 1;
        if VaribleArray[i].IsDate then
            PostingDate := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsDate then
            DocDate := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            DocNo := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            ExtDocNo := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsBoolean then
            SysCreated := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsInteger then
            DocType := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsInteger then
            AccType := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            AccountNo := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            CurrCode := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsDecimal then
            Amt := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsText then
            Desc := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            AppToDocNo := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsInteger then
            AppDocType := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            BalAccNo := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsInteger then
            BalAccType := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            VatBus := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            VatProd := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            Dim1 := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsCode then
            Dim1 := VaribleArray[i];
        i += 1;
        if VaribleArray[i].IsInteger then
            DimSetId := VaribleArray[i];

    end;

    procedure CreateJournalLineGLEntry(var VaribleArray: array[30] of Variant)

    begin

        SetJournalDefaults(); //Assign default Journal properties
        ClearVaribles();
        PackageArray(VaribleArray);
        with GenJnlLine do begin

            Validate("Posting Date", PostingDate);
            Validate("Document Date", DocDate);
            "Line No." := CurrJournalLineNo;
            "Document No." := DocNo;
            "External Document No." := ExtDocNo;
            "System-Created Entry" := SysCreated;
            case DocType of
                0:
                    "Document Type" := GenJnlLine."Document Type"::" ";

                1:
                    "Document Type" := GenJnlLine."Document Type"::Payment;
                2:
                    "Document Type" := GenJnlLine."Document Type"::Invoice;
                3:
                    "Document Type" := GenJnlLine."Document Type"::"Credit Memo";
                4:
                    "Document Type" := GenJnlLine."Document Type"::"Finance Charge Memo";
                5:
                    "Document Type" := GenJnlLine."Document Type"::Reminder;
                6:
                    "Document Type" := GenJnlLine."Document Type"::Refund;

            end;
            case AccType of
                0:
                    "Account Type" := GenJnlLine."Account Type"::"G/L Account";

                1:
                    "Account Type" := GenJnlLine."Account Type"::Customer;
                2:
                    "Account Type" := GenJnlLine."Account Type"::Vendor;
                3:
                    "Account Type" := GenJnlLine."Account Type"::"Bank Account";
                4:
                    "Account Type" := GenJnlLine."Account Type"::"Fixed Asset";
                5:
                    "Account Type" := GenJnlLine."Account Type"::"IC Partner";
                6:
                    "Account Type" := GenJnlLine."Account Type"::Employee;


            end;
            Validate("Account No.", AccountNo);
            Validate("Currency Code", CurrCode);
            Validate(Amount, Amt);
            Description := Desc;
            If AppToDocNo <> '' then begin
                case AppDocType of
                    0:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";

                    1:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
                    2:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
                    3:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
                    4:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Finance Charge Memo";
                    5:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Reminder;
                    6:
                        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Refund;

                end;
                Validate("Applies-to Doc. No.", AppToDocNo);
            end;
            if BalAccNo <> '' then begin
                case BalAccType of
                    0:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";

                    1:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::Customer;
                    2:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::Vendor;
                    3:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
                    4:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Fixed Asset";
                    5:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::"IC Partner";
                    6:
                        "Bal. Account Type" := GenJnlLine."Bal. Account Type"::Employee;


                end;
                Validate("Bal. Account No.", BalAccNo);
            end;
            if VatBus <> '' then
                Validate("VAT Bus. Posting Group", VatBus);
            if VatProd <> '' then
                Validate("VAT Prod. Posting Group", VatProd);

            if Amount <> 0 then
                if Insert() then begin
                    Validate("Shortcut Dimension 1 Code", Dim1);
                    Validate("Shortcut Dimension 2 Code", Dim2);
                    Validate("Dimension Set ID", DimSetId);
                    Modify();
                    CurrJournalLineNo += 1000;
                end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure HideDialog(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    var
        LocalGenJournalLine: Record "Gen. Journal Line";
    begin
        TempJournal.Get();
        LocalGenJournalLine.Reset();
        LocalGenJournalLine.SetFilter("Journal Template Name", '%1', TempJournal."Template Name");
        LocalGenJournalLine.SetFilter("Journal Batch Name", '%1', TempJournal."Batch Name");
        LocalGenJournalLine.SetFilter("Document No.", '%1', GenJournalLine."Document No.");
        if LocalGenJournalLine.FindFirst() then HideDialog := true;
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
            DeltaVar := LineTotalsVar - Abs(GnlJnLines."Amount (LCY)");
            if Abs(DeltaVar) < 0.5 then begin
                GnlJnLines.Validate("Amount (LCY)", (GnlJnLines."Amount (LCY)" - DeltaVar));
                GnlJnLines.Modify();
            end;
        end;
    end;
}