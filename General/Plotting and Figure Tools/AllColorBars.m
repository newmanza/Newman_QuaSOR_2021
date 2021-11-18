FigName=['Colorbars'];
figure
set(gcf,'color','w')
set(gcf,'position',[100 100 1500 500])
%%%%%%%%
ax(1)=subplot(1,10,1);
imagesc(fliplr([0:0.01:1])')
colormap('jet')
TempPos=get(ax(1),'position');
set(ax(1),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(2)=subplot(1,10,2);
imagesc(fliplr([0:0.01:1])')
colormap('parula')
TempPos=get(ax(2),'position');
set(ax(2),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(3)=subplot(1,10,3);
imagesc(fliplr([0:0.01:1])')
colormap('hot')
TempPos=get(ax(3),'position');
set(ax(3),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(4)=subplot(1,10,4);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('w'), 100))
TempPos=get(ax(4),'position');
set(ax(4),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(5)=subplot(1,10,5);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('r'), 100))
TempPos=get(ax(5),'position');
set(ax(5),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(6)=subplot(1,10,6);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('g'), 100))
TempPos=get(ax(6),'position');
set(ax(6),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(7)=subplot(1,10,7);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('b'), 100))
TempPos=get(ax(7),'position');
set(ax(7),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(8)=subplot(1,10,8);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('c'), 100))
TempPos=get(ax(8),'position');
set(ax(8),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(9)=subplot(1,10,9);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('m'), 100))
TempPos=get(ax(9),'position');
set(ax(9),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
ax(10)=subplot(1,10,10);
imagesc(fliplr([0:0.01:1])')
colormap(makeColorMap([0,0,0], ColorDefinitions('y'), 100))
TempPos=get(ax(10),'position');
set(ax(10),'position',[TempPos(1),TempPos(2),0.05,0.8]);
set(gca,'xtick',[]),set(gca,'ytick',[])
freezeColors
%%%%%%%%
set(gcf,'color','w')
export_fig( ['Z:\Image Analysis Compiled Data',dc, FigName, '.eps'], '-eps','-pdf','-nocrop','-transparent');        

