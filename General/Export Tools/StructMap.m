function StructMap(TempStruct,StructDepth)

    TempStruct=ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(2).BoutonArray(1).All_QuaSOR_Data;
    
    d=1;
    
    DeconStruct(d).AllFields=fieldnames(TempStruct);
    DeconStruct(d).NumFields=length(TempStruct);
    
    ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(1).BoutonArray(1).All_QuaSOR_Data(2).Refined_QuaSOR_Match_Spont_Fs_ByNMJ_AZ_Mean_Mean
    ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(2).BoutonArray(1).All_QuaSOR_Data(2).Refined_QuaSOR_Match_Spont_Fs_ByNMJ_AZ_Mean_Mean
    ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(2).BoutonArray(2).All_QuaSOR_Data(2).Refined_QuaSOR_Match_Spont_Fs_ByNMJ_AZ_Mean_Mean
    mean(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(2).BoutonArray(1).All_QuaSOR_Data(2).Spont_Fs)
    mean(ExperimentSet_PooledData.Refined_Quantifications.ExperimentSet(2).BoutonArray(2).All_QuaSOR_Data(2).Spont_Fs)

    
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