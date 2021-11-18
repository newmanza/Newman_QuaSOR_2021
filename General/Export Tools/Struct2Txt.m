function Struct2Txt(TempStruct,SaveDir,SaveName)

    AllFields=fieldnames(TempStruct);
    CurrentLine=1;
    ExportArray{CurrentLine,1}='SaveName: ';
    ExportArray{CurrentLine,2}=SaveName;
    CurrentLine=CurrentLine+1;
    ExportArray{CurrentLine,1}='=============================================================';
    CurrentLine=CurrentLine+1;
    for i=1:length(AllFields)
        CurrentLine=CurrentLine+1;
        ExportArray{CurrentLine,1}=[AllFields{i},': '];
        TempVal=getfield(TempStruct,AllFields{i});
        if ischar(TempVal)
            try
                ExportArray{CurrentLine,2}=TempVal;
            catch
                ExportArray{CurrentLine,2}=['Unable To Export'];
            end
        else
            try
                ExportArray{CurrentLine,2}=num2str(TempVal);
            catch
                ExportArray{CurrentLine,2}=['Unable To Export'];
            end
        end
    end
    dlmcell([SaveDir,SaveName,'.txt'], ExportArray);



end