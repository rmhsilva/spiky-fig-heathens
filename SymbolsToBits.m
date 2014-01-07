%SymbolsToBits
%Input: array of 0-7 of length L, where L is an integer
%Output: array of 0s and 1s of length 3L

function bits_out = SymbolsToBits(syms_in)
    
    %Create look up table. 
    %Mimics the approach which would 
    LUT = [0 0 0 0; 1 0 0 1; 2 0 1 0; 3 0 1 1; 4 1 0 0; 5 1 0 1; 6 1 1 0; 7 1 1 1;];
    
    bits_out = zeros(1,length(syms_in)*3);
    for n = 1:length(syms_in)
        for m = 1:8
            if(syms_in(1,n) == LUT(n,1))
                bits_out(1,(3*n)-2) = LUT(n,2);
                bits_out(1,(3*n)-1) = LUT(n,3);
                bits_out(1,3*n) = LUT(n,4);
            end
        end
    end
end