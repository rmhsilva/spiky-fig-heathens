%RemovePilotSymbols
%Removes one in ten symbols from an array from a user define start point

function syms_out = RemovePilotSymbols(syms_in, pilotFrequency, firstPilotIndex)
%V4 code
    %Work out how many pilot symbols there are
    a = 0;
    for n = firstPilotIndex:pilotFrequency:length(syms_in)
        a = a + 1;
    end
    
    %Temp, used to check the above method works
    b = 0;
    for n = firstPilotIndex:pilotFrequency:length(syms_in)
       b = b + 1;
    end

    %Create output array based on this information
    syms_out = zeros(1,length(syms_in) - a);
    
    %Interate over the array and extract the elements we want
    c = 1;
    for n = 1:length(syms_in)
        if(mod(n + firstPilotIndex - 2,pilotFrequency) == 0)
            
        else
            syms_out(1,c) = syms_in(1,n);
            c = c + 1;
        end
    end

%V3 code
%     syms_out = zeros(1,length(syms_in) / (1 + (1/pilotFrequency)));
% 
%     c = 1;
%     derp = 0;
%     for n = 1:length(syms_in)
%         if(n == 9900)
%             derp = 0;
%         end
%         if(rem(n + firstPilotIndex - 2,pilotFrequency) == 0) %If on a pilot
%             
%         else
%             syms_out(1,c) = syms_in(1,n);
%             c = c + 1;
%         end
%     end
%    derp = 1;

%V1 code
%     c = 0;
%     d = 1;
%     removing = 0;
%     for n = 1:length(syms_in)
%         if(removing == 0)
%             if(n == firstPilotIndex)
%                 removing = 1;
%             else
%                 syms_out(1,d) = syms_in(1,n);
%                 d = d + 1;
%             end
%         else
%             if(c == (pilotFrequency - 1))
%                 c = 0;
%             else
%                 syms_out(1,d) = syms_in(1,n);
%                 c = c + 1;
%                 d = d + 1;
%             end 
%         end
%     end

%V2 code
%     pilots = firstPilotIndex:pilotFrequency:length(syms_in);
%     syms_in(pilots) = [];
%     syms_out = syms_in;

end