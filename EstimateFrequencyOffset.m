%EstimateFrequencyOffset

function [freqOff] = EstimateFrequencyOffset(stream_in)
    %Look at angle of each symbol compared to the nearest ideal constellation point
    
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
    
end