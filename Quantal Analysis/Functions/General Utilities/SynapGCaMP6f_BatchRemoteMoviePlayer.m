MovieName=' Raw vs Current Corrected First Images Record.avi'
TempDir='/Users/newmanza/Desktop/Temp Files/';
mkdir(TempDir)
clearvars -except NumSequences FramesPerSequence ParentDir TemplateDir Recording currentFolder dc TempDir MovieName
for RecordingNum=1:size(Recording,2)
    cd([Recording(RecordingNum).dir]);
    jheapcl
    disp(['Copying ',MovieName,' for File#',num2str(RecordingNum),' ',Recording(RecordingNum).StackSaveName]);

    StackSaveName=Recording(RecordingNum).StackSaveName;
    MovieDir='Registration Reference Movies';
    ScreenSize=get(0,'ScreenSize');
    ScaleFactor=0.5;

    if exist([MovieDir,dc,StackSaveName , MovieName])
        copyfile([MovieDir,dc,StackSaveName , MovieName],TempDir)
                FileInfo = dir([MovieDir,dc,StackSaveName , MovieName]);
        TimeStamp = FileInfo.date;
        disp(['File: ',StackSaveName,' (',TimeStamp,')']);
        ready=input('<Enter> to continue or <1> to repeat');
        
        cont1=1;
        while cont1
            videoFReader   = vision.VideoFileReader([TempDir,StackSaveName , ' Registration Record.avi']);
            depVideoPlayer = vision.DeployableVideoPlayer;
            set(depVideoPlayer,'Size','Custom','CustomSize',[ScreenSize(3)*ScaleFactor,ScreenSize(4)*ScaleFactor]);
            cont = ~isDone(videoFReader);
              while cont
                frame = step(videoFReader);
                step(depVideoPlayer, frame);
                cont = ~isDone(videoFReader) && isOpen(depVideoPlayer);
              end
            release(videoFReader);
            release(depVideoPlayer);
            clear depVideoPlayer videoFReader
            cont1=input('<Enter> to continue or <1> to repeat');
        end
    end
    delete(['/Users/newmanza/Desktop/Temp Files/',StackSaveName , ' Registration Record.avi'])

end
rmdir(TempDir,'s');
clearvars -except NumSequences FramesPerSequence ParentDir TemplateDir Recording currentFolder dc
