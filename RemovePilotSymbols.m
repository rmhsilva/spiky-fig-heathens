%RemovePilotSymbols
%Removes one in ten symbols from an array from a user define start point

function syms_out = RemovePilotSymbols(syms_in, pilotFrequency, firstPilotIndex)
    syms_out = zeros(1,length(syms_in) * (1 - (1/pilotFrequency)));
    
    c = 0;
    d = 1;
    removing = 0;
    for n = 1:length(syms_in)
        if(removing == 0)
            if(n == firstPilotIndex)
                removing = 1;
            else
                syms_out(1,d) = syms_in(1,n);
                d = d + 1;
            end
        else
            if(c == (pilotFrequency - 1))
                c = 0;
            else
                syms_out(1,d) = syms_in(1,n);
                c = c + 1;
                d = d + 1;
            end 
        end
    end
end