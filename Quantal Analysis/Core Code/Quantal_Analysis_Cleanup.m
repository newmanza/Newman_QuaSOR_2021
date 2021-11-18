for RecordingNum=1:length(Recording)
    warning(['Cleanup for Rec#',num2str(RecordingNum)])
    if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc])
        warning('Deleting Temp File Directory...')
        rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc,'TempFiles',dc],'s');
    end
    if exist([ScratchDir,Recording(RecordingNum).StackSaveName,dc])
        warning('Deleting StackSaveName-Specific ScratchDir Directory...')
        rmdir([ScratchDir,Recording(RecordingNum).StackSaveName,dc],'s');
    end
    if exist([ScratchDir,Recording(RecordingNum).ImageSetSaveName,dc])
        warning('Deleting ImageSetSaveName-Specific ScratchDir Directory...')
        rmdir([ScratchDir,Recording(RecordingNum).ImageSetSaveName,dc],'s');
    end
    if exist([ScratchDir,Recording(RecordingNum).SaveName,dc])
        warning('Deleting SaveName-Specific ScratchDir Directory...')
        rmdir([ScratchDir,Recording(RecordingNum).SaveName,dc],'s');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clearvars -except myPool dc OS compName MatlabVersion MatlabVersionYear ScreenSize CurrentScratchDir ScratchDir...
        CurrentParentDir ParentDir ParentDir1 ParentDir2 ParentDir3...
        Recording currentFolder File2Check AnalysisLabel AnalysisLabelShort AnalysisParts BatchChoice BatchChoiceOptions AnalysisPartsChoiceOptions RecordingChoiceOptions Function RecordingNum LastRecording...
        LoopCount File2Check AnalysisLabel AnalysisLabelShort Function ErrorTolerant BufferSize Port PortRange PortChoice PortOptions TimeOut NumLoops ServerIP ServerName DateNumCutoff DateTimeCutoff BadConnection ConnectionAttempts OverwriteData AllRecordingStatuses...
        RunningTimeHandle OverallTimeHandle OverallTimer FlaggedRecordings FlaggedCount CheckingMode AdjustOnly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
