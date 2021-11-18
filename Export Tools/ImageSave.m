
function ImageSave(ImageTitle,FigureHandle,SaveDir,StackSaveName,SaveFormats)
    % SaveFormats={'.fig','.tif'};
    % SaveFormats={'.fig','.tif','.eps'};
    dc = '/';

    %Save in designated formats
    for i=1:length(SaveFormats)
        disp(['SAVING: ',SaveDir , dc , StackSaveName , ' ',ImageTitle , SaveFormats{i}])
        if strcmp(SaveFormats{i},'.eps')
            saveas(FigureHandle, [SaveDir , dc , StackSaveName , ' ',ImageTitle , SaveFormats{i}],'epsc');
        else
            saveas(FigureHandle, [SaveDir , dc , StackSaveName , ' ',ImageTitle , SaveFormats{i}]);
        end
    end


end