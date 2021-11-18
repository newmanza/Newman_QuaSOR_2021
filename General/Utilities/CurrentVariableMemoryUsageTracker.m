function [FileList]=CurrentVariableMemoryUsageTracker(Details,SizeRange)
    %use CurrentVariableMemoryUsage(whos,CutOff) in bytes
    warning on all
    warning off verbose
    warning off backtrace
    FileList=[];
    FileCount=0;
    for i=1:length(Details)
        if Details(i).bytes>SizeRange(1)&&Details(i).bytes<SizeRange(2)

            warning('==================================================')
            warning([Details(i).name,' : ',num2str(Details(i).bytes/1e9),'GB (',Details(i).class,')'])
            FileList=['''',FileList,Details(i).name,''','];
            FileCount=FileCount+1;
    %         if isstruct(eval(Details(i).name))
    %             TempFields=fields(eval(Details(i).name));
    %             for j=1:length(TempFields)
    %                 warning(['     ',Details(i).name,'.',TempFields{j}])
    %             end
    %         end

        end
    end
    warning('==================================================')
    warning('==================================================')
    warning('==================================================')
    warning(['Found ',num2str(FileCount),' Files'])
    warning('==================================================')
    warning('==================================================')
    warning('==================================================')

    FileList=FileList(1:length(FileList)-1);
end