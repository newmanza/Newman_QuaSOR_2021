function [myPool]=ParPoolManager(StartPool,myPool)
    warning on all
    warning off backtrace
    warning off verbose
    if isempty(StartPool)
        PoolChoice = questdlg('Start Parallel Pool?','Start Parallel Pool?','Start','Skip','Start');
        if strcmp(PoolChoice,'Start')
            StartPool=1;
        elseif strcmp(PoolChoice,'Skip')
            StartPool=0;
        end
    end
    if StartPool
        if exist('myPool')
            if ~isempty(myPool)
                try
                    if isempty(myPool.IdleTimeout)
                        warning('Parpool timed out! Restarting now...')
                        delete(gcp('nocreate'))
                        myPool=parpool;%
                    else
                        disp('Parpool active...')
                    end
                catch
                    warning('Problem with parpool trying again...')
                    delete(gcp('nocreate'))
                    myPool=parpool;
                end
            else
                warning('Restarting ParPool...')
                delete(gcp('nocreate'))
                myPool=parpool;
            end
        else
            warning('Restarting ParPool...')
            delete(gcp('nocreate'))
            myPool=parpool;
        end
    else
        myPool=[];
    end
end