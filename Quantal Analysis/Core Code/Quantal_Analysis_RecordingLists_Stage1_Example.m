%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run This First then Select your List Below
close all
jheapcl
clearvars -except myPool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LabDefaults=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScratchDir='<ScratchDir>'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[OS,dc,compName,MatlabVersion,MatlabVersionYear,ScreenSize]=WhereAmIRunning(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear Recording
RecNum=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrentParentDir='<ParentDir>'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RecNum=RecNum+1;
Recording(RecNum).dir=               [CurrentParentDir,'<PATH>'];
Recording(RecNum).SaveName=          'GC6_Spont_Evoked_1';
Recording(RecNum).ModalitySuffix=    '_02Hz';
Recording(RecNum).BoutonSuffix=      '_Ib';
Recording(RecNum).ImageSetSaveName=  'GC6_Spont_Evoked_1_02Hz';
Recording(RecNum).StackSaveName=     'GC6_Spont_Evoked_1_02Hz_Ib';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RecNum=RecNum+1;
Recording(RecNum).dir=               [CurrentParentDir,'<PATH>'];
Recording(RecNum).SaveName=          'GC6_Spont_Evoked_1';
Recording(RecNum).ModalitySuffix=    '_02Hz';
Recording(RecNum).BoutonSuffix=      '_Is';
Recording(RecNum).ImageSetSaveName=  'GC6_Spont_Evoked_1_02Hz';
Recording(RecNum).StackSaveName=     'GC6_Spont_Evoked_1_02Hz_Is';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RecNum=RecNum+1;
Recording(RecNum).dir=               [CurrentParentDir,'<PATH>'];
Recording(RecNum).SaveName=          'GC6_Spont_Evoked_1';
Recording(RecNum).ModalitySuffix=    '_Spont';
Recording(RecNum).BoutonSuffix=      '_Ib';
Recording(RecNum).ImageSetSaveName=  'GC6_Spont_Evoked_1_02Hz';
Recording(RecNum).StackSaveName=     'GC6_Spont_Evoked_1_02Hz_Ib';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RecNum=RecNum+1;
Recording(RecNum).dir=               [CurrentParentDir,'<PATH>'];
Recording(RecNum).SaveName=          'GC6_Spont_Evoked_1';
Recording(RecNum).ModalitySuffix=    '_Spont';
Recording(RecNum).BoutonSuffix=      '_Is';
Recording(RecNum).ImageSetSaveName=  'GC6_Spont_Evoked_1_02Hz';
Recording(RecNum).StackSaveName=     'GC6_Spont_Evoked_1_02Hz_Is';

