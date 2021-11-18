close all
jheapcl
clear
OS=computer;
if strcmp(OS,'MACI64')
    dc='/';
else
    dc='\';
end
CurrentDir=cd;

Text2Find='ScaleBar.mat'
LogFileID='Updating Scale Factor For All Post Paper Files'
VariableName2Fix='ScaleBar.ScaleFactor'
Variable2Fix=0.21164; %um per pixel {ENTERPRISE 63x,1.0NA+1.2x Adapter}=0.21164um/px OR {ENTERPRISE 63x,1.0NA+1.0x Adapter}=0.253968um/px {5-LIVE 0.1803 for 1.2x zoom use 0.31 for 0.7x zoom}  


DirList=uipickfiles();
TotalNumFiles=0;
progressbar('Directory')
for i=1:length(DirList)
    progressbar(i/length(DirList))
    DirStruct(i).MatchedFiles=dir([DirList{i},dc,['/*',Text2Find]]);
    DirStruct(i).dir=DirList{i};
    TotalNumFiles=TotalNumFiles+length(DirStruct(i).MatchedFiles);
end
disp(['Found ',num2str(TotalNumFiles),' ',Text2Find,' Files'])

LogFile_Dir=['LOG Files'];
if ~exist(LogFile_Dir)
    mkdir(LogFile_Dir)
end
CurrentDateTime=clock;
Year=num2str(CurrentDateTime(1)-2000);Month=num2str(CurrentDateTime(2));Day=num2str(CurrentDateTime(3));Hour=num2str(CurrentDateTime(4));Minute=num2str(CurrentDateTime(5));Second=num2str(CurrentDateTime(6));
if length(Month)<2;Month=['0',Month];end;if length(Day)<2;Day=['0',Day];end



clear LogFile
CurrentLine=1;
LogFile{CurrentLine,1}=[(Year),(Month),(Day),' ',LogFileID];
CurrentLine=CurrentLine+1;
TimeStamp=[Hour,':',Minute,':',Second];
LogFile{CurrentLine,1}=['Time Stamp: ',TimeStamp];
CurrentLine=CurrentLine+1;
LogFile{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
CurrentLine=CurrentLine+1;
LogFile{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
CurrentLine=CurrentLine+1;
%progressbar('Directory','File')
for i=1:length(DirStruct)
    Directory=DirStruct(i).dir;
    [filepath,lastfolder] = fileparts(Directory);
    fprintf(['Directory # ',num2str(i),'/',num2str(length(DirStruct)),'\n'])
    fprintf(['Fixing ',Text2Find,' files in Directory: ',lastfolder,'\n'])
    fprintf(['File: '])
    for j=1:length(DirStruct(i).MatchedFiles)
        %progressbar(i/length(DirStruct),j,length(DirStruct(i).MatchedFiles))
        FileName=DirStruct(i).MatchedFiles(j).name;
        fprintf([FileName])
        try
            load([Directory,dc,FileName],'ScaleBar')
        
            ScaleBar.ScaleFactor=Variable2Fix;
            ScaleBar.Width=1;
            
            if strcmp(ScaleBar.PointerSide,'L')
                ScaleBar.XData=[ScaleBar.XCoordinate ScaleBar.XCoordinate+ScaleBar.Length/ScaleBar.ScaleFactor];
            elseif strcmp(ScaleBar.PointerSide,'R')
                ScaleBar.XData=[ScaleBar.XCoordinate-ScaleBar.Length/ScaleBar.ScaleFactor ScaleBar.XCoordinate];
            end
            ScaleBar.YData=[ScaleBar.YCoordinate ScaleBar.YCoordinate];
            ScaleBar.PixelLength=round(ScaleBar.Length/ScaleBar.ScaleFactor);
            ScaleBar.ScaleBarMask=zeros(size(ScaleBar.ScaleBarMask));
            if strcmp(ScaleBar.PointerSide,'L')
                ScaleBar.ScaleBarMask(round(ScaleBar.YCoordinate):round(ScaleBar.YCoordinate)+ScaleBar.PixelWidth-1,round(ScaleBar.XCoordinate):round(ScaleBar.XCoordinate)+ScaleBar.PixelLength)=1;
            elseif strcmp(ScaleBar.PointerSide,'R')
                ScaleBar.ScaleBarMask(round(ScaleBar.YCoordinate):round(ScaleBar.YCoordinate)+ScaleBar.PixelWidth-1,round(ScaleBar.XCoordinate)-ScaleBar.PixelLength:round(ScaleBar.XCoordinate))=1;
            end
            ScaleBar.ScaleBarMask=logical(ScaleBar.ScaleBarMask);
%             %figure, imagesc((ScaleBar.ScaleBarMask)), axis equal tight;
            save([Directory,dc,FileName],'ScaleBar','-append');
            pause(0.1)
            LogFile{CurrentLine,1}=['Directory: ',Directory];
            CurrentLine=CurrentLine+1;
            LogFile{CurrentLine,1}=['FileName: ',FileName];
            CurrentLine=CurrentLine+1;
            LogFile{CurrentLine,1}=['Updated <',VariableName2Fix,'> to: ',num2str(Variable2Fix)];
            CurrentLine=CurrentLine+1;
            LogFile{CurrentLine,1}='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
            CurrentLine=CurrentLine+1;
        catch
            warning(['Problem loading: ',[Directory,dc,FileName]])
        end
        for z=1:length(FileName)
            fprintf('\b')
        end
        clear ScaleBar FileName 
    end
    clear Directory filepath lastfolder
    fprintf('Finished Directory!\n')
    fprintf('====================================================\n')
end


dlmcell([LogFile_Dir,dc,(Year),(Month),(Day),' ',LogFileID,'.txt'], LogFile);
save([LogFile_Dir,dc,(Year),(Month),(Day),' ',LogFileID,'.mat'])
