# Sierra
MS Dynamics BC Journals and Posting API
Gen Journal Array Arrangement
1:   {Posting Date}                     :=      IsDate;  

2:   {Document Date}                    :=      IsDate; 

3:   {Document No.}                     :=      IsCode;

4:   {Extrenal Document No}             :=      IsCode;

5:   {System Created}                   :=      IsBoolean;
    
6:   {Document Type}                    :=      IsOptionString ()
      
7:   {Account Type}                     :=      IsOptionString ()
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