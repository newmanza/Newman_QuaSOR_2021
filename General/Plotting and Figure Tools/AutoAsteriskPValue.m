function SigCat=AutoAsteriskPValue(p)
SigCat=[];
if ~isempty(p)
    if p<0.05&&p>=0.01
        SigCat='*';
    elseif p<0.01&&p>=0.001
        SigCat='**';
    elseif p<0.001&&p>=0.0001
        SigCat='***';
    elseif p<0.0001
        SigCat='****';
    else

    end
end