function DisplayVariableValue(Variable)
    
    varToStr = @(x) inputname(1);
    VarString = varToStr(Variable);

    
    disp([VarString,' = ',num2str(Variable)]);
    
end
