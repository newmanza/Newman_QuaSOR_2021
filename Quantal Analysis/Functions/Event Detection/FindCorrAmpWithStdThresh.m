% Subtract first response before correlation to second response, iterate until no more responses:
% while max value is larger than Corr_Thresh:
% get first (largest) max value.
% check that index is within range (lags range 0-23)
% shift TemplateResponse and subtract from sequence
% Run correlation again and look for next max.
% Get: Corr lags and amplitudes

% MaxLags = Max interval for correlation
% MinGap: once a response was identified, will accept new responses only if they
% are MinGap away (otherwise sometimes the same response will be counted
% twice)

% Added WithStdThresh: accept MaxValue only if it is larger than the std of
% Sequence_Sum by at least StdFactor

%Sequence_Sum=OneSequence;

function [CorrLags CorrAmps ShiftValue] = FindCorrAmpWithStdThresh(Sequence_Sum, corrTemplate, TemplateResponse, Corr_Thresh, FirstIndex, SecondIndex, MaxLags, MinGap, StdFactor)

    Sequence_Sum = Sequence_Sum(:);
    corrTemplate = corrTemplate(:);
    TemplateResponse = TemplateResponse(:);

    StdValue = std(Sequence_Sum); % will compare StdValue to MaxValue


    CorrLags = [];
    CorrAmps = [];

    % 1. Find shift between TemplateResponse and corrTemplate
    % correlation
    [OneSequence_Cov, OneSequence_Lags] = xcov(TemplateResponse, corrTemplate, MaxLags, 'none'); 
    % find max correlation
    [~, OneSequenceCov_PeakIndices, xmin, imin] = extrema(OneSequence_Cov);
    ShiftValue = OneSequence_Lags(OneSequenceCov_PeakIndices(1));

    % 2. Sequence_Sum

    cont = 1;
    while(cont)
        cont = 0;

        % a) Correlation
        [OneSequence_Cov, OneSequence_Lags] = xcov(Sequence_Sum, corrTemplate, MaxLags, 'none');

           % [OneSequence_Cov OneSequence_Lags] = xcorr(Sequence_Sum, corrTemplate, MaxLags, 'none');

        %    [OneSequence_Cov OneSequence_Lags] = xcov(Sequence_Sum, corrTemplate, length(Sequence_Sum), 'none');

        % figure, plot(OneSequence_Lags, OneSequence_Cov, '*-');
        % figure;xdata=1:length(Sequence_Sum); [AX,H1,H2]=plotyy(xdata,Sequence_Sum,xdata,OneSequence_Cov(xdata+MaxLags));ylabel(AX(1),'\DeltaF');

        % b) Find max values and indices
        [OneSequenceCov_PeakValues, OneSequenceCov_PeakIndices, xmin, imin] = extrema(OneSequence_Cov);
        if (length(OneSequenceCov_PeakValues)==0)
            break
        end

        % c) look at largest Max value and index
        % continue if value is large enough and index is within range

        LastMaxIndexNumber = length(OneSequenceCov_PeakValues); 
        for MaxIndexNumber=1:LastMaxIndexNumber
             MaxIndex = OneSequenceCov_PeakIndices(MaxIndexNumber);
             MaxValue = OneSequenceCov_PeakValues(MaxIndexNumber);


             if ((MaxValue > Corr_Thresh) && (MaxValue > (StdValue * StdFactor)) && (MaxIndex >= FirstIndex) && (MaxIndex <= SecondIndex))
                 % check that new response is at least MinGap away from
                 % previously identified responses
                 % Go over all elements in CorrLags and check their distance to
                 % the new response
                 NewResponseFlag = 1;
                 MaxLag = OneSequence_Lags(MaxIndex);
                 LastLagNumber = length(CorrLags);
                 for LagNumber=1:LastLagNumber
                     MaxDistance = abs(MaxLag - CorrLags(LagNumber));
                     if (MaxDistance <= MinGap)
                         NewResponseFlag = 0;
                     end                
                 end

                 if (NewResponseFlag) % keep response only if it is new
                    cont = 1;

                    CorrAmp = MaxValue;   
                    CorrAmps = [CorrAmps CorrAmp]; 
                    CorrLags = [CorrLags MaxLag];

                    % subtract TemplateResponse
                    ShiftBy = MaxLag - ShiftValue;  % assumes that ShiftValue is positive - corrTemplate is at left edge and ResponseTemplate is at center 
                    Shifted_Response = circshift(TemplateResponse, ShiftBy);
                    Shifted_Response(1:ShiftBy) = 0;

                    %Sequence_Sum = Sequence_Sum - (CorrAmp * Shifted_Response);

                    break % stop for loop
                 end
             end
        end  
    end
end

