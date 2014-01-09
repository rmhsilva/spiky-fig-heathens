%AddPilotSymbols
%Inputs: 
%syms_in: array of integers 0 to 7
%pilotFrequency: 1 in X symbols are a pilot
%fistPilotIndex: Location of the first pilot symbol

%Outputs:
%syms_out: syms_in with pilots added as specified

%Note: length does not have to be a multiple of the pilot frequency
%Keeps on adding pilots until the end is reached

function syms_out = AddPilotSymbols(syms_in, pilotSymbol, pilotFrequency, firstPilotIndex)
    
    %Work out how many pilots to add
    a = 0;
    for n = firstPilotIndex:(pilotFrequency-1):length(syms_in)
        a = a + 1;
    end

    syms_out = zeros(1,length(syms_in) + a);
    %syms_out = zeros(1,length(syms_in) + length(syms_in)*(1.0/(pilotFrequency - 1)));
    
    %Cycle through the symbols
    c = 1;
    for n = 1:length(syms_out)
        if(mod(n + firstPilotIndex - 2,pilotFrequency) == 0)
            syms_out(1,n) = pilotSymbol;
        else
            syms_out(1,n) = syms_in(1,c);
            c = c + 1;
        end
    end
    
    
%V1 cycling code
%     c = 0;
%     d = 1;
%     injecting = 0;
%     for n = 1:length(syms_out)
%         if(injecting == 0)
%             if(n == firstPilotIndex)
%                 syms_out(1,n) = pilotSymbol;
%                 injecting = 1;
%             else
%                 syms_out(1,n) = syms_in(1,d);
%                 d = d + 1;
%             end
%         else
%             if(c == (pilotFrequency - 1))
%                 syms_out(1,n) = pilotSymbol;
%                 c = 0;
%             else
%                 syms_out(1,n) = syms_in(1,d);
%                 d = d + 1;
%                 c = c + 1;
%             end
%         end
%     end
end