function [varargout]=errorbarxy_ZN_Full(x, y, lerrx, uerrx, lerry, uerry, xcap, ycap, MarkerColor, XErrorLineColor, YErrorLineColor, ErrorLineStyle, MarkerStyle, MarkerSize, LineWidth)
                            


%   ERRORBARXY is a function to generate errorbars on both x and y axes 
%   with specified errors modified from codes written by Nils Sjöberg 
%   (http://www.mathworks.com/matlabcentral/fileexchange/5444-xyerrorbar)
%  
%   errorbarxy(x, y, lerrx, uerrx, lerry, uerry) plots the data with errorbars on both 
%   x and y axes with error bars [x-lerrx, x+uerrx] and [y-lerry, y+uerry]. If there is
%   no error on one axis, set corresponding lower and upper bounds to [].
%
%   errorbarxy(x, y, errx, erry) plots the data with errorbars on both x and
%   y axes with error bars [x-errx, x+errx] and [y-erry, y+erry]. If there 
%   is no error on one axis, set corresponding errors to [].
%   
%   errorbarxy(..., S) plots data as well as errorbars using specified
%   formatting string. S is a cell array of 3 element, {sData, cEBx, cEBy},
%   where sData specifies the format of main plot, cEBx specifies the 
%   color of errorbars along x axis and cEBy specifies the color of 
%   errorbars along y axis. The formatting string for the main plot made 
%   from one element from any or all the following 3 columns, while the 
%   other two strings made only from the first colume (color):
%            b     blue          .     point              -     solid
%            g     green         o     circle             :     dotted
%            r     red           x     x-mark             -.    dashdot 
%            c     cyan          +     plus               --    dashed   
%            m     magenta       *     star             (none)  no line
%            y     yellow        s     square
%            k     black         d     diamond
%            w     white         v     triangle (down)
%                                ^     triangle (up)
%                                <     triangle (left)
%                                >     triangle (right)
%                                p     pentagram
%                                h     hexagram
% 
%   
%   errorbarxy(AX,...) plots into AX instead of GCA.
%   
%   H = errorbar(...) returns a vector of errorbarseries handles in H,
%   within which the first element is the handle to the main data plot and
%   the remaining elements are handles to the rest errorbars.
%   H is organized as follows:
%   H.hMain is the handle of the main plot
%   H.hErrorbar is a Nx6 matrix containing handles for all error bar lines,
%               where N is the number of samples. For each sample, 6
%               errorbar handles are saved in such an order:
%               [Horizontal bar, H bar left cap, H bar right cap, 
%                Vertical bar, V bar lower cap, V bar upper cap]
%


% plot data and errorbars
lx=x-lerrx;
ux=x+uerrx;
ly=y-lerry;
uy=y+uerry;

allh=nan(length(x), 6); % all errorbar handles
for k=1:length(x)
    l1=line([lx(k) ux(k)],[y(k) y(k)],'LineWidth',LineWidth);
    hold on;
    l2=line([lx(k) lx(k)],[y(k)-xcap y(k)+xcap],'LineWidth',LineWidth);
    l3=line([ux(k) ux(k)],[y(k)-xcap y(k)+xcap],'LineWidth',LineWidth);
    l4=line([x(k) x(k)],[ly(k) uy(k)],'LineWidth',LineWidth);
    l5=line([x(k)-ycap x(k)+ycap],[ly(k) ly(k)],'LineWidth',LineWidth);
    l6=line([x(k)-ycap x(k)+ycap],[uy(k) uy(k)],'LineWidth',LineWidth);
    allh(k, :)=[l1, l2, l3, l4, l5, l6];
    h1=[l1, l2, l3]; % all handles
    set(h1, 'color', XErrorLineColor,'linestyle', ErrorLineStyle);
    h1=[l4, l5, l6]; % all handles
    set(h1, 'color', YErrorLineColor,'linestyle', ErrorLineStyle);
end
if any(strfind(MarkerStyle,'o'))||any(strfind(MarkerStyle,'s'))||...
        any(strfind(MarkerStyle,'d'))||any(strfind(MarkerStyle,'v'))||...
        any(strfind(MarkerStyle,'^'))||any(strfind(MarkerStyle,'<'))||...
        any(strfind(MarkerStyle,'>'))||any(strfind(MarkerStyle,'p'))||any(strfind(MarkerStyle,'h'))
    for k=1:length(x)
        if ~isnan(x(k))&&~isnan(y(k))
            h.k(k)=plot(x(k),y(k), MarkerStyle, 'color', MarkerColor,'MarkerSize',MarkerSize,'MarkerFaceColor','w'); % main plot
        end
    end
else
    for k=1:length(x)
        if ~isnan(x(k))&&~isnan(y(k))
            h.k(k)=plot(x(k),y(k), MarkerStyle, 'color', MarkerColor,'MarkerSize',MarkerSize,'MarkerFaceColor',MarkerColor); % main plot
        end
    end
   % h=plot(x,y, MarkerStyle, 'color', MarkerColor,'MarkerSize',MarkerSize); % main plot
end
arrayfun(@(d) set(get(get(d,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off'), allh); % exclude errorbars from legend
if exist('h')
    out.hMain=h;
else
    out.hMain=[];
end
out.hErrorbar=allh;
hold off

% handle outputs
if nargout>0
    varargout{1}=out;
end




















