%INSTRUCTION: use cell array for possible integer answers and for a range use a 1d array with
%the upper lower limits ex. [0:10] as one of the answers
%[Answer]=InputWithVerification('Is this the correct way to use this: ',{[],[1:10]},0)
function [Answer]=InputWithVerification(Question,PossibleAnswers,BeepOn)

    warning off verbose
    warning off backtrace
    commandwindow
    GoodAnswer=0;
    while GoodAnswer==0
        if BeepOn
            Beeper(3,0.1)
            pause(0.1)
        else
            pause(0.1)
        end
        try
            Answer=input(Question);
        catch
            warning('ONLY Integer responses allowed. Try again (3 attempts left)!')
            try
                Answer=input(Question);
            catch
                warning('ONLY Integer responses allowed. Try again (2 attempts left)!')
                try
                    Answer=input(Question);
                catch
                    warning('ONLY Integer responses allowed. Try again (1 attempts left)!')
                    try
                        Answer=input(Question);
                    catch
                        error('ONLY Integer responses allowed. No attempts left Exiting Function!')
                        error('ONLY Integer responses allowed. No attempts left Exiting Function!')
                        error('ONLY Integer responses allowed. No attempts left Exiting Function!')
                    end
                end
            end
        end
        if isempty(Answer)
            for i=1:length(PossibleAnswers)
               if isempty(PossibleAnswers{i})
                   GoodAnswer=1;
               end
            end
        else
           for i=1:length(PossibleAnswers)
               if length(PossibleAnswers{i})>1
                   if Answer>=min(PossibleAnswers{i})&&Answer<=max(PossibleAnswers{i})
                        GoodAnswer=1;
                   end
               else
                   if Answer==PossibleAnswers{i}
                       GoodAnswer=1;
                   end
               end
           end
        end

       if GoodAnswer==0
           if BeepOn
            Beeper(10,0.1);
           else
            beep;
           end
           warning('Bad response, please try again')
       end

    end

end
