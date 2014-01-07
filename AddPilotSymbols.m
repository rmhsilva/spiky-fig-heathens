%AddPilotSymbols
%Input: array of 0-7 of length 9L, where L is an integer
%Output: array of 0-7 of length 10L, where L is an integer

function syms_out = AddPilotSymbols(syms_in)
    %New array 
    syms_out = zeros(1,length(syms_in) + length(syms_in)*(1.0/9.0));
end