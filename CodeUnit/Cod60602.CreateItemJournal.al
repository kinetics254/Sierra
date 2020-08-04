codeunit 60602 "Create Item Journal"
{
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    local procedure CheckIfJournalExist(TemplateName: Code[10]; BatchName: Code[20]): Boolean
    var
        ItemBatch: Record "Item Journal Batch";
    begin
        exit(ItemBatch.Get(TemplateName, BatchName));
    end;
}