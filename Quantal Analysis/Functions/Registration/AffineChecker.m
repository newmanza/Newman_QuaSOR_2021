PlaybackFrameInterval=5;

fileNames = uigetfile('registerNMJ_*.mat','Select registerNMJ Files','MultiSelect', 'on');
if ischar(fileNames)
    temp=fileNames;clear fileNames
    fileNames{1}=temp;
    clear temp
end
disp('Checking file contents...')
for i=1:length(fileNames)
    TempData(i).vars = whos('-file',fileNames{i});
    if ismember('track', {TempData(i).vars.name})
        TempData(i).TrackCompleted=1;
        disp(['Track Data Found for: ',fileNames{i}])
    else
        TempData(i).TrackCompleted=0;
        warning(['Track Data MISSING for: ',fileNames{i}])
    end
    if ismember('affine', {TempData(i).vars.name})
        TempData(i).AffineCompleted=1;
        disp(['Affine Data Found for: ',fileNames{i}])
    else
        TempData(i).AffineCompleted=0;
        warning(['Affine Data MISSING for: ',fileNames{i}])
    end
    if ismember('demon', {TempData(i).vars.name})
        TempData(i).DemonCompleted=1;
        disp(['Demon Data Found for: ',fileNames{i}])
    else
        TempData(i).DemonCompleted=0;
        warning(['Demon Data MISSING for: ',fileNames{i}])
    end
end
%Track
for i=1:length(fileNames)
    if TempData(i).TrackCompleted
        disp(['Loading Track: ',fileNames{i}])
        load(fileNames{i},'track','maxFrameNum')
        TempData(i).track=track;
        TempData(i).maxFrameNum=maxFrameNum;
        TempData(i).maxFrameTrack=track(:,:,maxFrameNum);
        disp(['MaxFrameNum=',num2str(maxFrameNum)]);
        clear track maxFrameNum
        for z=1:size(TempData(i).track,3)
            TempImage=double(TempData(i).track(:,:,z));
            TempImage(TempImage==0)=NaN;
            TempData(i).vector(z)=nanmean(TempImage(:));
        end
    end
end
for i=1:length(fileNames)
    if TempData(i).TrackCompleted
        figure('name',fileNames{i}), imshow(TempData(i).maxFrameTrack,[]);set(gcf,'position', [10+(i-1)*450   200   560   420]);title(['Max Frame Track: ',fileNames{i}],'Interpreter', 'none'); 
    end
end
for i=1:length(fileNames)
    if TempData(i).TrackCompleted
        figure('name',fileNames{i}), plot(TempData(i).vector,'color','k');hold on;plot(TempData(i).maxFrameNum,TempData(i).vector(TempData(i).maxFrameNum),'.','color','r','MarkerSize',20);set(gcf,'position', [10+(i-1)*450   600   560   420]);title(['Mean Track Data for: ',fileNames{i}],'Interpreter', 'none');   
    end
end
for i=1:length(fileNames)
    if TempData(i).TrackCompleted
    cont=1;
    while cont
        disp(['Playing Track Data for: ',fileNames{i}])
        AutoPlaybackNew(TempData(i).track,PlaybackFrameInterval,0.01,[0,max(TempData(i).track(:))*0.8],'gray')
        cont=input(['Enter 1 to repeat playback of: ', fileNames{i}]);
    end
    end
end
close all
%Affine
for i=1:length(fileNames)
    if TempData(i).AffineCompleted
    disp(['Loading affine: ',fileNames{i}])
    load(fileNames{i},'affine','maxFrameNum')
    TempData(i).affine=affine;
    TempData(i).maxFrameNum=maxFrameNum;
    TempData(i).maxFrameAffine=affine(:,:,maxFrameNum);
    clear affine maxFrameNum
    for z=1:size(TempData(i).affine,3)
        TempImage=double(TempData(i).affine(:,:,z));
        TempImage(TempImage==0)=NaN;
        TempData(i).vector(z)=nanmean(TempImage(:));
    end
    end
end
for i=1:length(fileNames)
    if TempData(i).AffineCompleted
    figure('name',fileNames{i}), imshow(TempData(i).maxFrameAffine,[]);set(gcf,'position', [10+(i-1)*450   200   560   420]);title(['Max Frame Affine: ',fileNames{i}],'Interpreter', 'none');
    end
end
for i=1:length(fileNames)
    if TempData(i).AffineCompleted
    figure('name',fileNames{i}), plot(TempData(i).vector,'color','k');hold on;plot(TempData(i).maxFrameNum,TempData(i).vector(TempData(i).maxFrameNum),'.','color','r','MarkerSize',20);set(gcf,'position', [10+(i-1)*450   600   560   420]);title(['Mean Affine Data for: ',fileNames{i}],'Interpreter', 'none');
    end
end
for i=1:length(fileNames)
    if TempData(i).AffineCompleted
    cont=1;
    while cont
        disp(['Playing Affine Data for: ',fileNames{i}])
        AutoPlaybackNew(TempData(i).affine,PlaybackFrameInterval,0.01,[0,max(TempData(i).affine(:))*0.8],'gray')
        cont=input(['Enter 1 to repeat playback of: ', fileNames{i}]);
    end
    end
end
close all
%Demon
for i=1:length(fileNames)
    if TempData(i).DemonCompleted
    disp(['Loading Demon: ',fileNames{i}])
    load(fileNames{i},'demon','maxFrameNum')
    TempData(i).demon=demon;
    TempData(i).maxFrameDemon=demon(:,:,maxFrameNum);
    clear demon maxFrameNum
    for z=1:size(TempData(i).demon,3)
        TempImage=double(TempData(i).demon(:,:,z));
        TempImage(TempImage==0)=NaN;
        TempData(i).vector(z)=nanmean(TempImage(:));
    end
    end
end
for i=1:length(fileNames)
    if TempData(i).DemonCompleted
    figure('name',fileNames{i}), imshow(TempData(i).maxFrameDemon,[]);set(gcf,'position', [10+(i-1)*450   200   560   420]);title(['Max Frame Demon: ',fileNames{i}],'Interpreter', 'none');
    end
end
for i=1:length(fileNames)
    if TempData(i).DemonCompleted
    figure('name',fileNames{i}), plot(TempData(i).vector,'color','k');hold on;plot(TempData(i).maxFrameNum,TempData(i).vector(TempData(i).maxFrameNum),'.','color','r','MarkerSize',20);set(gcf,'position', [10+(i-1)*450   600   560   420]);title(['Mean Demon Data for: ',fileNames{i}],'Interpreter', 'none');
    end
end
for i=1:length(fileNames)
    if TempData(i).DemonCompleted
    cont=1;
    while cont
        disp(['Playing Demon Data for: ',fileNames{i}])
        AutoPlaybackNew(TempData(i).demon,PlaybackFrameInterval,0.01,[0,max(TempData(i).demon(:))*0.8],'gray')
        cont=input(['Enter 1 to repeat playback of: ', fileNames{i}]);
    end
    end
end
close all
clear TempData