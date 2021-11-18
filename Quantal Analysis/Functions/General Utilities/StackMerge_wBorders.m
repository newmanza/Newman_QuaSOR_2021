function [MergedStack] = StackMerge_wBorders(FileID,Stack1_Input,Stack2_Input,Borders,Limits)
%this will load in two stacks and merge them vertically and help avoid
%memory loading issues if large stacks

if length(Limits)~=1
    
    Stack1=load(FileID,Stack1_Input);
    Stack1_Name = fieldnames(Stack1);
    Stack1 = Stack1.(Stack1_Name{1});
    disp(['Stack1_Name = ',Stack1_Name]);
    TempStack1=Stack1(:,:,Limits);
    TempMax=max(TempStack1(:));
    for i=1:size(TempStack1,3)
        TempImage=TempStack1(:,:,i);
        TempImage(Borders)=TempMax;
        TempStack1(:,:,i)=TempImage;
    end
    clear Stack1
    ArraySize=size(TempStack1);
    if ArraySize(2)>ArraySize(1)
        disp('Vertical Merge')
        MergedStack=zeros(ArraySize(1)*2,ArraySize(2),ArraySize(3));
    else
        disp('Horizontal Merge')
        MergedStack=zeros(ArraySize(1),ArraySize(2)*2,ArraySize(3));
    end
    progressbar('Stack 1 Loading Image #')
    for i=1:ArraySize(3)
        MergedStack(1:ArraySize(1),1:ArraySize(2),i)=TempStack1(1:ArraySize(1),1:ArraySize(2),i);
        progressbar(i/ArraySize(3))
    end
    clear TempStack1

    Stack2=load(FileID,Stack2_Input);
    Stack2_Name = fieldnames(Stack2);
    disp(['Stack2_Name = ',Stack2_Name]);
    Stack2 = Stack2.(Stack2_Name{1});
    TempStack2=Stack2(:,:,Limits);
    TempMax=max(TempStack2(:));
    for i=1:size(TempStack2,3)
        TempImage=TempStack2(:,:,i);
        TempImage(Borders)=TempMax;
        TempStack2(:,:,i)=TempImage;
    end
    clear Stack2
    progressbar('Stack 2 Loading Image #')
    for i=1:ArraySize(3)
        if ArraySize(2)>ArraySize(1)
            MergedStack((ArraySize(1)+1):(ArraySize(1)*2),1:ArraySize(2),i)=TempStack2(:,:,i);
        else
            MergedStack(1:ArraySize(1),(ArraySize(2)+1):(ArraySize(2)*2),i)=TempStack2(:,:,i);
        end
        progressbar(i/ArraySize(3))
    end
    clear TempStack2
    
else
    Stack1=load(FileID,Stack1_Input);
    Stack1_Name = fieldnames(Stack1);
    Stack1 = Stack1.(Stack1_Name{1});
    TempStack1=Stack1(:,:,Limits);
    TempMax=max(TempStack1(:));
    for i=1:size(TempStack1,3)
        TempImage=TempStack1(:,:,i);
        TempImage(Borders)=TempMax;
        TempStack1(:,:,i)=TempImage;
    end
    clear Stack1
    ArraySize=size(TempStack1);
    if ArraySize(2)>ArraySize(1)
        MergedStack=zeros(ArraySize(1)*2,ArraySize(2),1);
        MergedStack(1:ArraySize(1),1:ArraySize(2),1)=TempStack1(1:ArraySize(1),1:ArraySize(2),1);
    else
        MergedStack=zeros(ArraySize(1),ArraySize(2)*2,1);
        MergedStack(1:ArraySize(1),1:ArraySize(2),1)=TempStack1(1:ArraySize(1),1:ArraySize(2),1);
    end
    clear TempStack1
    Stack2=load(FileID,Stack2_Input);
    Stack2_Name = fieldnames(Stack2);
    Stack2 = Stack2.(Stack2_Name{1});
    TempStack2=Stack2(:,:,Limits);
    TempMax=max(TempStack2(:));
    for i=1:size(TempStack2,3)
        TempImage=TempStack2(:,:,i);
        TempImage(Borders)=TempMax;
        TempStack2(:,:,i)=TempImage;
    end
    clear Stack2
    if ArraySize(2)>ArraySize(1)
        MergedStack((ArraySize(1)+1):(ArraySize(1)*2),1:ArraySize(2),1)=TempStack2(:,:,1);
    else
        MergedStack(1:ArraySize(1),(ArraySize(2)+1):(ArraySize(2)*2),1)=TempStack2(:,:,1);
    end
    
    clear TempStack2

end
    
   

end