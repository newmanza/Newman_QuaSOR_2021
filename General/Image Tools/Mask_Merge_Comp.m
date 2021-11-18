function [StackMerge]=Mask_Merge_Comp(Stack1,Stack2)
    if any(size(Stack1)~=size(Stack2))
        error('Size Mismatch!')
    else
        if size(Stack1,3)>1
            StackMerge=zeros(size(Stack1,1),size(Stack1,2)*2,size(Stack1,3));
            for z=1:size(Stack1,3)
                StackMerge(1:size(Stack1,1),1:size(Stack1,2),z)=...
                    Stack1(:,:,z);
                StackMerge(1:size(Stack1,1),size(Stack1,2)+1:size(Stack1,2)*2,z)=...
                    Stack2(:,:,z);
            end
        else
            StackMerge=zeros(size(Stack1,1),size(Stack1,2)*2,size(Stack1,3));
            StackMerge(1:size(Stack1,1),1:size(Stack1,2))=...
                Stack1(:,:);
            StackMerge(1:size(Stack1,1),size(Stack1,2)+1:size(Stack1,2)*2)=...
                Stack2(:,:);
        end
    end
end
