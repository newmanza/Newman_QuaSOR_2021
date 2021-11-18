%--------------------------------------------------------------------
function y_filt = Zach_MovingAvgFilter_Exclusions(y,span,exclude)
% moving average of the data.
    span_halfish=floor(span/2);
    exclude=logical(exclude);
    y_nan=y;
    %set all exclusions as nan as well as a ~half span +/-
    for i=1:length(y_nan)
        if exclude(i)
            y_nan(i)=NaN;
            for j=1:span_halfish
                if i-j>0
                    y_nan(i-j)=NaN;
                end
                if i+j<length(y_nan)
                    y_nan(i+j)=NaN;
                end
            end
        end
    end
    y_filt=y_nan;
    %use nanmean to not smooth any exclusions+span adjustments
    for k=span_halfish+1:length(y)-span_halfish
        y_filt(k)=nanmean(y_nan(k-span_halfish:k+span_halfish));
    end
    %Add back original values for excluded regions
    for i=1:length(y_filt)
        if isnan(y_nan(i))
            y_filt(i)=y(i);
        end
    end
%figure, plot(exclude),hold on, plot(y),hold on, plot(y_filt)


end
%--------------------------------------------------------------------