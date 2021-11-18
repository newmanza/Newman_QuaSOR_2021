function ExportFigureDataTxt(TableExport,SaveName,TableExportDir)
    fprintf(['Exporting: ',SaveName,'.txt...'])
    if ~exist(TableExportDir)
        mkdir(TableExportDir);
    end
    TitleBar=cell(2,size(TableExport,2));
    TitleBar{1,1}=SaveName;
    TableExport=vertcat(TitleBar,TableExport);
    dlmcell([TableExportDir, SaveName,'.txt'], TableExport,'delimiter','\t');
    fprintf('Finished!\n');
end
