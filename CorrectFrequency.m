%EstimateFrequencyOffset

function [stream_out, freqOff] = CorrectFrequency(stream_in_full, phase_offset)
    %Look at angle of each symbol compared to the nearest ideal constellation point
    
     stream_in = stream_in_full(1,1:100);
     stream_out = zeros(1,length(stream_in_full));
     freqOff = 0;
    
%V1 code: looks at the whole thing    
%     %Ideal constellation points
%     Nbits = 3;
%     rts = (1:(2^Nbits)) / (2^Nbits);
%     points = exp(sqrt(-1)*(2*pi*rts));
%     
%     %Measure angle for each point
%     offsets = zeros(1,length(stream_in));
%     for n = 1:length(stream_in)
%         %Find closest point
%         closest = 0;
%         angmin = 10;
%         for m = 1:8
%             angtemp = abs(angle(points(1,m)) - angle(stream_in(1,n)));
%             if(angtemp < angmin)
%                 angmin = angtemp;
%                 closest = m;
%             end           
%         end
%         
%         offsets(1,n) = angle(points(1,closest)) - angle(stream_in(1,n));
%         
% %         if(offsets(1,n) > 0.5)
% %             derp = 1;
% %         end
%     end
%     plot(offsets);
%     
%     %Look at rate of change of offset
%     offsetdiff = zeros(1,length(stream_in));
%     for n = 2:length(stream_in)
%         offsetdiff(1,n) = offsets(1,n) - offsets(1,n-1);
%     end
%     %plot(offsetdiff,'*');
%     
%     
%     %Calculate mean rate of change, ignoring the huge random spikes
%     freqOff = 0;
%     count = 0;
%     clamp = 0.2;
%     for n = 1:length(offsetdiff)
%         if(abs(offsetdiff(1,n)) < clamp)
%             freqOff = freqOff + offsetdiff(1,n);
%             count = count + 1;
%         end
%     end
%     freqOff = freqOff / count;
%     
%     %Correct the offset
%     stream_out = CarrierOffset(stream_in_full, freqOff/(2*pi));


%V2 code: windows through the stream_in, looking at 10 symbols at a time
% %Take the mean average of the offset over 10 symbols
% 
%     %Ideal constellation points
%     Nbits = 3;
%     rts = (1:(2^Nbits)) / (2^Nbits);
%     points = warg(exp(sqrt(-1)*(2*pi*rts + phase_offset)));
%     %points = (exp(sqrt(-1)*(2*pi*rts)));
%     
%     %Get angles of the incoming stream
%     angles = warg(stream_in_full);
%     
%     %Calculate angle offsets
%     offsets = zeros(1,length(angles));
%     for n = 1:length(angles)
%         %Find closest point
%         closest = 0;
%         angmin = 10;
%         tempres = zeros(1,8);
%         for m = 1:8
%             %angtemp = abs(angle(points(1,m)) - angle(stream_in(1,n)));
%             angtemp = abs(points(1,m) - angles(1,n));
%             tempres(1,m) = angtemp;
%             if(angtemp < angmin)
%                 angmin = angtemp;
%                 closest = m;
%             end           
%         end
%         offsets(1,n) = points(1,closest) - angles(1,n);
%     end
%     
%     %Take rate of change
%     diffs = diff(offsets);
%     figure(1); plot(diffs);
%     
%     %Window the rate of change and apply mean offset to the next symbol
%     windowlen = 20;
%     thresh = 0.2;
%     avgs = zeros(1,length(diffs));
%     for n = 1:length(diffs)-windowlen
%         var = 0;
%         count = 0;
%         for m = 0:windowlen
%             if(abs(diffs(1,n+m)) < thresh)
%                 var = var + diffs(1,n+m);
%                 count = count + 1;
%             end
%         end
%         avgs(1,n) = var / count;
%     end
%     figure(2); plot(avgs);
    

% V3

    Nbits = 3;
    rts = (1:(2^Nbits)) / (2^Nbits);
    point_angles = warg(exp(sqrt(-1)*(2*pi*rts + phase_offset)));

    winsize = 10;
    e = 0;
    errors = zeros(1,length(stream_in_full)-winsize);
    prev_offset = 0;
    freq_diff = zeros(1,winsize);
    thresh = pi/8;
    Kp = 0.1;
    Ki = 0.3;
    Kd = 0.1;
    blash = zeros(1,length(errors));
    
    for n=1:length(stream_in_full)-winsize
        stream_out(1,n) = stream_in_full(1,n) * exp(-sqrt(-1)*e);
        
        % Get phase offset in radians
        offset = calc_offset(stream_out(1,n));
        
        % Differentiate to get freq offset
        freq_offset = offset - prev_offset;
        
        % Clamp large changes in freq offset
        if (abs(freq_offset) > thresh)
            freq_offset = freq_diff(mod(n-1,winsize)+1);
        end

        freq_diff(mod(n,winsize)+1) = freq_offset;

        % Save previous offset for next loop
        prev_offset = offset;
        
        % Derivative
        diff = freq_diff(mod(n,winsize)+1) - freq_diff(mod(n-1,winsize)+1);
        
        % error
        e = Kp*freq_offset + Ki*sum(freq_diff) + Kd*diff;
        errors(n) = e;
        blash(n) = freq_offset;
    end
    figure(1); plot(1:length(errors),errors,1:length(blash),blash);
    legend('Error (Rad)','Frequency Offset (Rad/Sym)');
    title('Tan locked loop');
    xlabel('Symbols');
    mean(blash)
    
    function error = calc_offset(point)
        angle = warg(point);
        
        %Find closest point
        closest = 0;
        angmin = 10;
        tempres = zeros(1,8);
        for p = 1:8
            angtemp = abs(point_angles(1,p) - angle);
            tempres(1,p) = angtemp;
            if(angtemp < angmin)
                angmin = angtemp;
                closest = p;
            end           
        end
        error = point_angles(1,closest) - angle;
    end
end
