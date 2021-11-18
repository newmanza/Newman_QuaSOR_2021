function [FileList]=CurrentVariableMemoryUsageTracker(Details,CutOff)
    %use CurrentVariableMemoryUsage(whos,CutOff) in bytes
    warning on all
    warning off verbose
    warning off backtrace

    for i=1:length(Details)
        if Details(i).bytes>CutOff

            warning('==================================================')
            warning([Details(i).name,' : ',num2str(Details(i).bytes/1e9),'GB (',Details(i).class,')'])
    %         if isstruct(eval(Details(i).name))
    %             TempFields=fields(eval(Details(i).name));
    %             for j=1:length(TempFields)
    %                 warning(['     ',Details(i).name,'.',TempFields{j}])
    %             end
    %         end

        end
    end
end