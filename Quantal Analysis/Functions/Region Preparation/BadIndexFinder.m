function [NewGoodIndexNumbers]=BadIndexFinder(IndexNumbersToDelete,GoodIndexNumbers)

count=1;
for i=1:length(GoodIndexNumbers)
    if any(IndexNumbersToDelete==i)
    else
        NewGoodIndexNumbers(count)=i;
        count=count+1;
    end
end

end