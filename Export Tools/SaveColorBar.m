function SaveColorBar(SaveName, Limits, CTicks, Label,LoadingColorMap)

% Limits=[0 20];
% CTicks=[0 20];
% Label='\DeltaF/F_0';

fig1=figure;
hold on
left=100; bottom=100 ; width=600 ; height=600;
pos=[left bottom width height];
axis off
caxis(Limits)
if ~isempty(LoadingColorMap)
colormap(LoadingColorMap);
end
hcb=colorbar('position',[0.1  0.15  0.1  0.8]);    
y=ylabel(hcb, Label);
set(hcb,'fontsize',20,'FontName','Arial');
set(y,'fontsize',28,'FontName','Arial');
set(y, 'Units', 'Normalized', 'Position', [0.3, 0.5, 0]);
set(hcb,'YTick',CTicks);
set(fig1,'OuterPosition',pos) ;
iptsetpref('ImshowBorder','tight');
set(gcf, 'color', 'white');
set(gcf,'units','centimeters');
set(gcf,'papersize',[5,2]);
saveas(gcf, [SaveName , '.fig']);
saveas(gcf, [SaveName , '.eps'],'epsc');
saveas(gcf, [SaveName , '.tif']);
close(fig1)
fig1=figure;
hold on
left=100; bottom=100 ; width=600 ; height=600;
pos=[left bottom width height];
axis off
caxis(Limits)
if ~isempty(LoadingColorMap)
colormap(LoadingColorMap);
end
hcb=colorbar('position',[0.1  0.15  0.2  0.8]);    
y=ylabel(hcb, Label);
set(hcb,'fontsize',20,'FontName','Arial');
set(y,'fontsize',28,'FontName','Arial');
set(y, 'Units', 'Normalized', 'Position', [0.3, 0.5, 0]);
set(hcb,'YTick',CTicks);
set(fig1,'OuterPosition',pos) ;
iptsetpref('ImshowBorder','tight');
set(gcf, 'color', 'white');
set(gcf,'units','centimeters');
set(gcf,'papersize',[5,2]);

hold off
export_fig( [SaveName , ' V2.eps'], '-eps','-tif','-nocrop','-transparent');


end



    