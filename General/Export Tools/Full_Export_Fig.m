function Full_Export_Fig(Fig_Handle,Fig_Axes_Handles,Fig_Dir_Name,Fig_SaveOption)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Fig_SaveOption = 0 Vector (.eps .pdf) ONLY
    %Fig_SaveOption = 1 Bitmap (.png .tif) and Vector (.eps .pdf)
    %Fig_SaveOption = 2 Bitmap (.png .tif) and Vector (.eps .pdf) with Painters renderer for surface/3d plots
    %Fig_SaveOption = 3 Bitmap (.png) and Vector (.eps .pdf)
    %Fig_SaveOption = 4 Bitmap (.png .tif) ONLY
    %Fig_SaveOption = 5 png ONLY
    %Fig_SaveOption = 6 tif ONLY
    %Fig_SaveOption = 7 eps ONLY
    %Fig_SaveOption = 8 pdf ONLY
    %Fig_SaveOption = 10 Alternate eps ONLY
    %Fig_SaveOption = 11 Print eps ONLY Useful for transparent
    %Fig_SaveOption = 12 Print pdf ONLY Useful for transparent
    %Fig_SaveOption = 13 Bitmap (.png) and Vector (.eps .pdf) with Painters renderer for surface/3d plots
    %Fig_SaveOption = 14 Vector (.eps .pdf) with Painters renderer for surface/3d plots
    %Fig_SaveOption = 15 Vector (.eps) with Painters renderer for surface/3d plots
    %Fig_SaveOption = 16 Vector (.pdf) with Painters renderer for surface/3d plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    WarningState=warning;
    warning off all
    switch Fig_SaveOption
        case 0
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 1
            export_fig( [Fig_Dir_Name, '.png'],'-png','-tif','-nocrop','-q101','-native');          
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 2
            export_fig( [Fig_Dir_Name, '.png'],'-png','-tif','-nocrop','-q101','-native');          
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap','-painters');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 3
            export_fig( [Fig_Dir_Name, '.png'],'-png','-nocrop','-q101','-native');          
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 4
            warning('Only Exporting bitmap images...')
            export_fig( [Fig_Dir_Name, '.png'],'-png','-tif','-nocrop','-q101','-native');          
        case 5
            warning on
            warning('Only Exporting png image...')
            export_fig( [Fig_Dir_Name, '.png'],'-png','-nocrop','-q101','-native');          
        case 6
            warning on
            warning('Only Exporting tif image...')
            export_fig( [Fig_Dir_Name, '.tif'],'-tif','-nocrop','-q101','-native'); 
        case 7
            warning on
            warning('Only Exporting eps image...')
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-nocrop','-transparent','-nofontswap');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 8
            warning on
            warning('Only Exporting pdf image...')
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.pdf'], '-pdf','-nocrop','-transparent','-nofontswap');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 10
            warning on
            warning('Exporting EPS with saveas...')
            saveas(gcf, [Fig_Dir_Name, '.eps'],'epsc');
        case 11
            warning on
            warning('Exporting EPS with print...')
            print(gcf,'-depsc','-painters','-r300',[Fig_Dir_Name, '.eps'])
            
        case 12
            warning on
            warning('Exporting PDF with print...')
            print(gcf,'-dpdf','-painters','-r300',[Fig_Dir_Name, '.pdf'])
        case 13
            export_fig( [Fig_Dir_Name, '.png'],'-png','-nocrop','-q101','-native');          
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap','-painters');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 14
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-pdf','-nocrop','-transparent','-nofontswap','-painters');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 15
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.eps'], '-eps','-nocrop','-transparent','-nofontswap','-painters');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end
        case 16
            set(Fig_Handle, 'color', 'none');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'none');
                catch
                    warning('Missing Axis...')
                end
            end
            export_fig( [Fig_Dir_Name, '.pdf'], '-pdf','-nocrop','-transparent','-nofontswap','-painters');     
            set(Fig_Handle, 'color', 'w');
            for ax=1:length(Fig_Axes_Handles)
                try
                    axes(Fig_Axes_Handles(ax))
                    set(Fig_Axes_Handles(ax), 'color', 'w');
                catch
                    warning('Missing Axis...')
                end
            end

            
    end
    try
        if strcmp(WarningState.state,'on')
            warning on
        else
            warning off
        end
    catch
    end
end