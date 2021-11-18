function SafeAxisLimAdjust(Axes2Adjust,Limits)
    if size(Limits,2)~=2&&size(Limits,1)~=1
        warning on
        warning('Not providing proper limits [low high]')
    else
        if Limits(1)<Limits(2)
            if any(strfind(Axes2Adjust,'x'))||any(strfind(Axes2Adjust,'X'))
                xlim([Limits(1),Limits(2)])
            elseif any(strfind(Axes2Adjust,'y'))||any(strfind(Axes2Adjust,'Y'))
                ylim([Limits(1),Limits(2)])
            elseif any(strfind(Axes2Adjust,'z'))||any(strfind(Axes2Adjust,'Z'))
                zlim([Limits(1),Limits(2)])
            end
        else
            warning on
            warning('No difference in limits, not adjusting!')
        end
    end
end