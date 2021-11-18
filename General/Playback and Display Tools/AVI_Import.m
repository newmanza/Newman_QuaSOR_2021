function [ImageArray,AVI_Info,FPS]=AVI_Import(FileName)
    clear depVideoPlayer videoFReader
    warning on all
    warning off verbose
    warning off backtrace
    warning off
    AVI_Info=aviinfo(FileName);
    warning on
    FPS=AVI_Info.FramesPerSecond;
    videoFReader = vision.VideoFileReader(FileName);
    try
        ImageArray=zeros(AVI_Info.Height,AVI_Info.Width,3,AVI_Info.NumFrames,'single');
    catch
        warning('Problem initializing data structure, trying alternative...')
        progressbar('Initializing')
        for z=1:AVI_Info.NumFrames
            progressbar(z/AVI_Info.NumFrames)
            ImageArray(:,:,:,z)=zeros(AVI_Info.Height,AVI_Info.Width,3,'single');
        end
    end
    progressbar('Importing Data')
    for i=1:AVI_Info.NumFrames
        progressbar(i/AVI_Info.NumFrames)
        ImageArray(:,:,:,i) = step(videoFReader);
    end
    release(videoFReader);
    clear videoFReader
end