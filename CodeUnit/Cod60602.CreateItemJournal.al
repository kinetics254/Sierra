codeunit 60602 "Create Item Journal"
{
    SingleInstance = true;

    var
        itemJnl: Record "Item Journal Line";
        CurrJournalLineNo: Integer;

        GlobalTemplateName: Code[10];
        GlobalBatchName: Code[20];
        GlobalSourceCode: Code[20];
        GlobalReasonCode: Code[20];
        PostingDate: Date;
        DocDate: Date;
        LocationCode: Code[10];
        UOM: Code[10];
        Qty: Decimal;
        UnitCost: Decimal;
        ItemNo: Code[20];
        EntryType: Integer;
        DocNo: Code[20];
        ExtDocNo: Code[20];
        LotNo: Code[20];
        SerialNo: Code[20];
        Dim1: Code[20];
        Dim2: Code[20];
        DimSetId: Integer;
        ZeroCost: Boolean;
        GenProdPosting: Code[20];
        TempNotDefined: Label 'Journal Template Name not Defined';
        BatchNotDefined: Label 'Journal Batch Not Defined';
        Posted: Boolean;

    procedure ClearJournalBatch(TemplateName: Code[10]; BatchName: Code[20]; SourceCode: Code[20]; ReasonCode: Code[20]): Boolean

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
            with itemJnl do begin
                Reset();
                SetFilter("Journal Template Name", '%1', TemplateName);
                SetFilter("Journal Batch Name", '%1', BatchName);
                if FindSet() then DeleteAll();
            end;

        end;
        exit(CheckIfJournalExist(TemplateName, BatchName));
    end;

    local procedure ResetCurrentLine()

    begin
        CurrJournalLineNo := 1000;
    end;

    local procedure SetJournalDefaults()

    begin
        if GlobalTemplateName = '' then Error(TempNotDefined);
        if GlobalBatchName = '' then Error(BatchNotDefined);
        with itemJnl do begin
            "Journal Template Name" := GlobalTemplateName;
            "Journal Batch Name" := GlobalBatchName;
            "Source Code" := GlobalSourceCode;
            "Reason Code" := GlobalReasonCode;
        end;
    end;

    local procedure CheckIfJournalExist(TemplateName: Code[10]; BatchName: Code[20]): Boolean
    var
        ItemBatch: Record "Item Journal Batch";
    begin
        exit(ItemBatch.Get(TemplateName, BatchName));
    end;

    local procedure ClearVaribles()

    begin

        PostingDate := 0D;
        DocDate := 0D;
        DocNo := '';
        ExtDocNo := '';
        EntryType := 0;
        ItemNo := '';
        LocationCode := '';
        UOM := '';
        Qty := 0;
        UnitCost := 0;
        LotNo := '';
        SerialNo := '';
        Dim1 := '';
        Dim2 := '';
        DimSetId := 0;
        ZeroCost := false;
        GenProdPosting := '';
    end;

    local procedure PackageArray(var VaribleArray: array[30] of Variant)
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(VaribleArray) do begin
            case i of
                1:
                    if VaribleArray[i].IsDate then
                        PostingDate := VaribleArray[i]; //Posting Date
                2:
                    if VaribleArray[i].IsDate then
                        DocDate := VaribleArray[i]; // Document Date
                3:
                    if VaribleArray[i].IsCode then
                        DocNo := VaribleArray[i]; // Document No.
                4:
                    if VaribleArray[i].IsCode then
                        ExtDocNo := VaribleArray[i]; // External Doucment No.
                5:
                    if VaribleArray[i].IsInteger then
                        EntryType := VaribleArray[i]; // EntryType
                6:
                    if VaribleArray[i].IsCode then
                        ItemNo := VaribleArray[i]; //Item No
                7:
                    if VaribleArray[i].IsCode then
                        LocationCode := VaribleArray[i]; // Location Code
                8:
                    if VaribleArray[i].IsCode then
                        UOM := VaribleArray[i]; // UOM
                9:
                    if VaribleArray[i].IsDecimal then
                        Qty := VaribleArray[i]; // Qty
                10:
                    if VaribleArray[i].IsDecimal then
                        UnitCost := VaribleArray[i]; //Unit Cost
                11:
                    if VaribleArray[i].IsCode then
                        LotNo := VaribleArray[i]; // Lot No 
                12:
                    if VaribleArray[i].IsCode then
                        SerialNo := VaribleArray[i]; // Serial No       
                13:
                    if VaribleArray[i].IsCode then
                        Dim1 := VaribleArray[i]; // Dim 1
                14:
                    if VaribleArray[i].IsCode then
                        Dim2 := VaribleArray[i]; // Dim 2
                15:
                    if VaribleArray[i].IsInteger then
                        DimSetId := VaribleArray[i]; // Dim Set ID
                16:
                    if VaribleArray[i].IsBoolean then
                        ZeroCost := VaribleArray[i]; //Check Zero Cost
                17:
                    if VaribleArray[i].IsCode then
                        GenProdPosting := VaribleArray[i]; // Change Gen Posting Grp
            end;
        end;
    end;

    procedure CreateItemJournalLineEntry(var VaribleArray: array[30] of Variant)

    begin
        //Purchase - 0,Sale - 1,Positive Adjmt. - 2,Negative Adjmt. - 3,
        //Transfer - 4,Consumption - 5,Output - 6, ,Assembly Consumption - 7,Assembly Output - 8
        SetJournalDefaults(); //Assign default Journal properties
        ClearVaribles();
        PackageArray(VaribleArray);
        with itemJnl do begin
            "Document No." := DocNo;
            "Line No." := CurrJournalLineNo;
            Validate("Posting Date", PostingDate);
            Validate("Document Date", DocDate);
            "External Document No." := ExtDocNo;
            case EntryType of
                0:
                    Validate("Entry Type", itemJnl."Entry Type"::Purchase);
                1:
                    Validate("Entry Type", itemJnl."Entry Type"::Sale);
                2:
                    Validate("Entry Type", itemJnl."Entry Type"::"Positive Adjmt.");
                3:
                    Validate("Entry Type", itemJnl."Entry Type"::"Negative Adjmt.");
                4:
                    Validate("Entry Type", itemJnl."Entry Type"::Transfer);
                5:
                    Validate("Entry Type", itemJnl."Entry Type"::Consumption);
                6:
                    Validate("Entry Type", itemJnl."Entry Type"::Output);
                7:
                    Validate("Entry Type", itemJnl."Entry Type"::"Assembly Consumption");
                8:
                    Validate("Entry Type", itemJnl."Entry Type"::"Assembly Output");
            end;
            Validate("Item No.", ItemNo);
            Validate("Unit of Measure Code", UOM);
            Validate("Location Code", LocationCode);
            Validate(Quantity, Qty);
            if ZeroCost then
                Validate("Unit Cost", UnitCost);

            if GenProdPosting <> '' then
                Validate("Gen. Prod. Posting Group", GenProdPosting);
            if Quantity <> 0 then begin
                if Insert(true) then begin
                    DoItemTracking(itemJnl, LotNo, SerialNo);
                    Validate("Shortcut Dimension 1 Code", Dim1);
                    Validate("Shortcut Dimension 2 Code", Dim2);
                    if DimSetId <> 0 then
                        Validate("Dimension Set ID", DimSetId);
                    Modify();
                    CurrJournalLineNo += 1000;
                end;
            end;
        end;
    end;

    procedure CallItemJournalPostRoutine(): Boolean
    var

        SessionID: Integer;
    begin
        Posted := false;
        with itemJnl do begin
            Reset();
            SetFilter("Journal Template Name", '%1', GlobalTemplateName);
            SetFilter("Journal Batch Name", '%1', GlobalBatchName);
            if FindSet() then begin
                Codeunit.Run(Codeunit::"Item Jnl.-Post", itemJnl);
                // StartSession(SessionID, Codeunit::"Item Jnl.-Post", CompanyName, itemJnl);
                // StopSession(SessionID)
            end;
        end;
        exit(Posted);
    end;

    local procedure DoItemTracking(var ItemJnlLine: Record "Item Journal Line"; LotNoVar: Code[20]; SerialNoVar: Code[20])
    var
        TrackingSpecification: Record "Tracking Specification";
        ResevervationEntry: Record "Reservation Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ReservationMgt: Codeunit "Reservation Management";
    begin
        if LotNoVar = '' then exit;
        TrackingSpecification.InitFromItemJnlLine(ItemJnlLine);
        TrackingSpecification."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
        TrackingSpecification."Lot No." := LotNoVar;
        if SerialNoVar <> '' then
            TrackingSpecification."Serial No." := SerialNoVar;
        if TrackingSpecification.TrackingExists() then begin
            ReservationMgt.SetCalcReservEntry(TrackingSpecification, ResevervationEntry);
            ResevervationEntry."Reservation Status" := ResevervationEntry."Reservation Status"::Prospect;

            if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::Purchase] then
                ResevervationEntry.Validate("Quantity (Base)", ItemJnlLine."Quantity (Base)");
            if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::"Negative Adjmt.", ItemJnlLine."Entry Type"::Sale] then
                ResevervationEntry.Validate("Quantity (Base)", (ItemJnlLine."Quantity (Base)" * -1));
            ResevervationEntry.Insert(true);

        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnBeforeUpdateDeleteLines', '', false, false)]
    local procedure OnBeforeUpdateAndDeleteLines(var ItemJournalLine: Record "Item Journal Line")
    var

    begin
        Posted := ItemJournalLine."Journal Batch Name" = GlobalBatchName;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean)

    begin
        if (GlobalTemplateName = ItemJournalLine."Journal Template Name") and (GlobalBatchName = ItemJournalLine."Journal Batch Name") then
            HideDialog := true;
    end;
}