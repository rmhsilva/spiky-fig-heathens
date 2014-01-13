%BitsToSymbols
%Input: array of 0s and 1s of length 3L, where L is an integer
%Output: array of 0-7 of length L

%Note: zeros appended to the end where needed

function syms_out = BitsToSymbols(bits_in)
    
    %Create look up table. 
    %Mimics the approach which would be used in hardware
    LUT = [0 0 0 0; 1 0 0 1; 2 0 1 1; 3 0 1 0; 4 1 1 0; 5 1 1 1; 6 1 0 1; 7 1 0 0; ];
    
    len = length(bits_in) + (3-mod(length(bits_in),3));
    syms_out = zeros(1,len/3);
    %syms_out = zeros(1,length(bits_in)/3);
    for n = 1:length(syms_out)
        for m = 1:8
            if((3*n) < len)
                if((bits_in(1,(3*n)-2) == LUT(m,2)) && (bits_in(1,(3*n)-1) == LUT(m,3)) && (bits_in(1,3*n) == LUT(m,4)))
                    syms_out(1,n) = LUT(m,1);
                end
            end
        end
    end
end