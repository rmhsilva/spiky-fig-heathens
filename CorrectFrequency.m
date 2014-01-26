%EstimateFrequencyOffset

function [stream_out, freqOff] = CorrectFrequency(stream_in_full, phase_offset)
    %Look at angle of each symbol compared to the nearest ideal constellation point
    
     %stream_in = stream_in_full(1,1:100);
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


%V2 code: windows through the stream_in, looking at a group of symbols at a time
%Take the mean average of the offset over the window

    %Ideal constellation points
    Nbits = 3;
    rts = (1:(2^Nbits)) / (2^Nbits);
    points = warg(exp(sqrt(-1)*(2*pi*rts + phase_offset)));
    %points = (exp(sqrt(-1)*(2*pi*rts)));
    
    %Get angles of the incoming stream
    angles = warg(stream_in_full);
    
    %Calculate angle offsets
    offsets = zeros(1,length(angles));
    for n = 1:length(angles)
        %Find closest point
        closest = 0;
        angmin = 10;
        tempres = zeros(1,8);
        for m = 1:8
            %angtemp = abs(angle(points(1,m)) - angle(stream_in(1,n)));
            angtemp = abs(points(1,m) - angles(1,n));
            tempres(1,m) = angtemp;
            if(angtemp < angmin)
                angmin = angtemp;
                closest = m;
            end           
        end
        offsets(1,n) = points(1,closest) - angles(1,n);
    end
    
    %Take rate of change
    diffs = diff(offsets);
    %figure(1); plot(diffs);
    
    %Window the rate of change and apply mean offset to the next symbol
    windowlen = 3000;
    thresh = 0.15;
    lastavg = 0; %Placeholder due to simulation limitations
    avgs = zeros(1,length(diffs)+1);
    for n = 1:length(avgs)
        var = 0;
        count = 0;
        for m = 0:windowlen
            if((m+n) < (length(diffs)-windowlen+1)) %If normal windowing...
                if(abs(diffs(1,n+m)) < thresh) %Ignoring big spikes
                    var = var + diffs(1,n+m);
                    if(n>1)
                        lastavg = avgs(1,n-1);
                    end
                    count = count + 1;
                end
            else %else use the last known average
                var = var + lastavg;
                count = count + 1;
            end
        end
        avgs(1,n) = var / (count);
    end
%      figure(2); plot(avgs);
    %figure(2); plot(1:length(avgs),avgs,1:length(stream_in_full),abs(stream_in_full));
    
    %Apply offsets to stream_in_full
    freqOff = mean(avgs);
%     stream_out = CarrierOffset(stream_in_full,-100/6666);
    for n = 1:length(stream_in_full)
%          stream_out(1,n) = stream_in_full(1,n).*exp(1i*avgs(1,n)*n);
         stream_out(1,n) = stream_in_full(1,n).*exp(1i*avgs(1,n)*n); %.*exp(1i*-0.0942*n); 
    end
    
    
% V3

%     Nbits = 3;
%     rts = (1:(2^Nbits)) / (2^Nbits);
%     point_angles = warg(exp(sqrt(-1)*(2*pi*rts + current_phase_offset)));

%     winsize = 10;
%     e = 0;
%     fdiff = 0;
%     offset = 0;
%     freq_offset = 0;
%     errors = zeros(1,length(stream_in_full));
%     prev_offset = 0;
%     freq_diff = zeros(1,winsize);
%     thresh = pi/8;
%      Kp = 0.1;
%      Ki = 0.2;
%      Kd = 0.0001;
%     blash = zeros(1,length(errors));
%     
%     for n=1:length(stream_in_full)
%         stream_out(1,n) = stream_in_full(1,n) * exp(sqrt(-1)*e*n);
%         
%         % Get phase offset in radians
%         offset = calc_offset(stream_out(1,n));
%         
%         % Differentiate to get freq offset
%         freq_offset = offset - prev_offset;
%         
%         % Clamp large changes in freq offset
%         if (abs(freq_offset) > thresh)
%             freq_offset = freq_diff(mod(n-1,winsize)+1);
%         end
% 
%         freq_diff(mod(n,winsize)+1) = freq_offset;
% 
%         % Save previous offset for next loop
%         prev_offset = offset;
%         
%         % Derivative
%         fdiff = freq_diff(mod(n,winsize)+1) - freq_diff(mod(n-1,winsize)+1);
%         
%         % error
%         e = Kp*freq_offset + Ki*sum(freq_diff) + Kd*fdiff;
%         errors(n) = e;
%         blash(n) = freq_offset;
%     end
    
%     
%     ref = 0;
%     new_fo = 0;
%     current_phase_offset = 0;
%     prev_phase_offset = 0;
%     freq_offset = 0;
%     prev_freq_offset = 0;
%     winsize = 1000;
%     thresh = pi/8;
%     prev_e = zeros(1,winsize);
%     ediff = 0;
%     e = 0;
%     Kp = 0;
%     Ki = 1/winsize;
%     Kd = 0.0;
%     
%     errors = zeros(1,length(stream_in_full));
%     blash = zeros(1,length(stream_in_full));
%     hoooga = zeros(1,length(blash));
%     
%     for n=1:length(stream_in_full)
%         stream_out(1,n) = stream_in_full(1,n) * exp(sqrt(-1)*new_fo*n);
%         
%         % Get phase offset in radians
%         current_phase_offset = calc_offset(stream_in_full(1,n));
%         hoooga(n) = current_phase_offset;
%         
%         % Differentiate to get freq offset
%         freq_offset = current_phase_offset - prev_phase_offset;
%         
%         % Clamp large changes in freq offset
%         if (abs(freq_offset) > thresh)
%             freq_offset = prev_freq_offset;
%         end
%         
%         % Save previous offset for next loop
%         prev_phase_offset = current_phase_offset;
%         prev_freq_offset = freq_offset;
%         
%         
%         % Calculate error
%         e = freq_offset;
%         new_fo = Kp*e + Ki*sum(prev_e) + Kd*ediff;
%         errors(n) = e;
%         blash(n) = new_fo;
%         
%         % For integral
%         prev_e(mod(n,winsize)+1) = e;
%         
%         % For derivative
%         ediff = e - prev_e(mod(n-1,winsize)+1);
%     end
%     
%     %%%%
%     
% %     figure(1); plot(1:length(errors),hoooga,1:length(blash),blash);
% %     legend('Error (Rad)','Frequency Offset (Rad/Sym)');
% %     title('Tan locked loop');
% %     xlabel('Symbols');
%     freqOff = mean(blash);
%     
%     function error = calc_offset(point)
%         angle = warg(point);
%         
%         %Find closest point
%         closest = 0;
%         angmin = 10;
%         tempres = zeros(1,8);
%         for p = 1:8
%             angtemp = abs(point_angles(1,p) - angle);
%             tempres(1,p) = angtemp;
%             if(angtemp < angmin)
%                 angmin = angtemp;
%                 closest = p;
%             end           
%         end
%         error = point_angles(1,closest) - angle;
%     end

%V4 code
%Take an incremental average of phase offset through the signal
%    %Ideal constellation points
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
%     %figure(1); plot(diffs);
%     
%     %Apply running average offset to stream_in_full
%     avg = diffs(1,1);
%     avgs = zeros(1,length(diffs)+1);
%     thresh = 0.2;
%     for n = 1:length(stream_in_full)-1
%         if(abs(diffs(1,n) < thresh))
%             avg = (avg + (diffs(1,n)/n))/2;
%         end
%         avgs(1,n) = avg;
%          stream_out(1,n) = stream_in_full(1,n).*exp(1i*avg*n);
%     end
%     figure(2); plot(avgs);

end
