%EstimateFrequencyOffset

function [stream_out, freqOff] = CorrectFrequency(stream_in)
    %Look at angle of each symbol compared to the nearest ideal constellation point
    
    stream_out = zeros(1,length(stream_in));
    
%V1 code: looks at the whole thing    
    %Ideal constellation points
    Nbits = 3;
    rts = (1:(2^Nbits)) / (2^Nbits);
    points = exp(sqrt(-1)*(2*pi*rts));
    
    %Measure angle for each point
    offsets = zeros(1,length(stream_in));
    for n = 1:length(stream_in)
        %Find closest point
        closest = 0;
        angmin = 10;
        for m = 1:8
            angtemp = abs(angle(points(1,m)) - angle(stream_in(1,n)));
            if(angtemp < angmin)
                angmin = angtemp;
                closest = m;
            end           
        end
        
        offsets(1,n) = angle(points(1,closest)) - angle(stream_in(1,n));
        
%         if(offsets(1,n) > 0.5)
%             derp = 1;
%         end
    end
    
    %Look at rate of change of offset
    offsetdiff = zeros(1,length(stream_in));
    for n = 2:length(stream_in)
        offsetdiff(1,n) = offsets(1,n) - offsets(1,n-1);
    end
    plot(offsetdiff,'*');
    
    
    %Calculate mean rate of change, ignoring the huge random spikes
    freqOff = 0;
    count = 0;
    clamp = 0.2;
    for n = 1:length(offsetdiff)
        if(abs(offsetdiff(1,n)) < clamp)
            freqOff = freqOff + offsetdiff(1,n);
            count = count + 1;
        end
    end
    freqOff = freqOff / count

% %V2 code: windows through the stream_in; UNFINISHED
%     %Window through the symbols and estimate the rate of change of phase
%     windsize = 10;
%     offsets = zeros(1,windsize-1);
%     for n = 1:length(stream_in)-windsize;
%         %Window
%         windy = stream_in(1,n:n+windsize);
%         
%         %For each point in the window,
%         %calculate the average rate of change of phase
%         offsets = zeros(1,windsize);
%         for m = 1:windsize
%             closest = 0;
%             angmin = 10;
%             for p = 1:8
%                 angtemp = abs(angle(points(1,p)) - angle(windy(1,m)));
%                 if(angtemp < angmin)
%                     angmin = angtemp;
%                     closest = p;
%                 end           
%             end
%                                 
%         end
%         
% 
%         
%         %Get angle change
%         for m = 2:windsize
%             offsets(1,m) = windy(1,m) - windy(1,m-1);
%         end
%     end
    
end