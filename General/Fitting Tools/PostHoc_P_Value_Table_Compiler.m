function P_Value_Table=PostHoc_P_Value_Table_Compiler(c)

    NumGroups=max(max(c(:,1)),max(c(:,2)));
    P_Value_Table=double(zeros(NumGroups,NumGroups));
    for i=1:size(c,1)
        P_Value_Table(c(i,1),c(i,2))=c(i,6);
    end
    for i=1:size(c,1)
        P_Value_Table(c(i,2),c(i,1))=c(i,6);
    end

end
