function ConsolidateMemory(WriteDir)
    
    cwd = pwd;
    cd(WriteDir);
    pack('Temporary File Rearrangement File')
    cd(cwd)
end
