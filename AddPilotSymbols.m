%AddPilotSymbols
%Inputs: 
%syms_in: array of integers 0 to 7
%pilotFrequency: 1 in X symbols are a pilot
%fistPilotIndex: Location of the first pilot symbol

%Outputs:
%syms_out: syms_in with pilots added as specified

function syms_out = AddPilotSymbols(syms_in, pilotSymbol, pilotFrequency, firstPilotIndex)
    syms_out = zeros(1,length(syms_in) + length(syms_in)*(1.0/(pilotFrequency - 1)));
    
    %Cycle through the symbols
    c = 0;
    d = 1;
    injecting = 0;
    for n = 1:length(syms_out)
        if(injecting == 0)
            if(n == firstPilotIndex)
                syms_out(1,n) = pilotSymbol;
                injecting = 1;
            else
                syms_out(1,n) = syms_in(1,d);
                d = d + 1;
            end
        else
            if(c == (pilotFrequency - 1))
                syms_out(1,n) = pilotSymbol;
                c = 0;
            else
                syms_out(1,n) = syms_in(1,d);
                d = d + 1;
                c = c + 1;
            end
        end
    end
end