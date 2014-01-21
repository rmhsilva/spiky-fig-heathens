%CorrectPhase

%Splits up the input stream into groups of columns
%The number of columns is based on the pilot frequency

%Each column then has an average per-row deviation calculated
%The column with the smallest deviation is assumed to be the one with the pilots

%The mean of the pilot column elements is taken and compared with the ideal pilot
%The phase angle is then calculated and the inverse is applied to all symbols in the group

%This not only corrects fixed phase offset but also frequency offset

%The result should be a phase corrected signal
%The column index is also returned as the pilot symbol start index

%NOTE: matrix notation is rows x columns

function [stream_out,first_pilot] = CorrectPhase(stream_in_full, factor, pilotSymbol)
    
    % stream_in = zeros(1,factor*5);
    % stream_in = stream_in_full(1,1:factor*5);
    % mat = reshape(stream_in,factor,length(stream_in)/factor).';

    % %For each column, calculate the average mag. change between rows
    % [row,col] = size(mat);
    % avgs = zeros(1,factor);
    % tot = 0;
    % for n = 1:col
    %     for m = 2:row
    %         tot = tot + abs(mat(m,n)-mat(m-1,n));
    %     end
    %     avgs(1,n) = tot/row;
    % end
    
    % %Find column with min average, this should contain the pilots    
    % [temp,initial] = min(avgs);
    
    % %Find a mean average of the pilots
    % tot = 0;
    % for n = 1:row
    %     tot = tot + mat(n,initial);
    % end
    % meanPilot = tot / row;

    % %Calculate offset and reverse it
    % offset = meanPilot/pilotSymbol;
    % stream_out = stream_in_full/offset;
    stream_out = zeros(1,length(stream_in_full));

    blocksize = 5*factor;
    mycounter = 1;
    offset = 0;
    first_pilot = 0;
    numOfBlocks = floor(length(stream_in_full)/blocksize)-1;
    offsetList = zeros(1,numOfBlocks);

    for mycounter = 0:numOfBlocks
        % This will loop to cover *most* of the stream in

        mat = reshape(stream_in_full((mycounter*blocksize)+1:(mycounter+1)*blocksize), factor, blocksize/factor).';

        %For each column, calculate the average mag. change between rows
        [row,col] = size(mat);
        avgs = zeros(1,factor);
        tot = 0;
        for n = 1:col
            for m = 2:row
                tot = tot + abs(mat(m,n)-mat(m-1,n));
            end
            avgs(1,n) = tot/row;
        end

        %Find column with min average, this should contain the pilots
        [temp,initial] = min(avgs);

        if (first_pilot == 0)
            first_pilot = initial;
        end

        %Find a mean average of the pilots
        tot = 0;
        for n = 1:row
            tot = tot + mat(n,initial);
        end
        meanPilot = tot / row;

        %Calculate offset and reverse it
        offset = meanPilot/pilotSymbol;
        stream_out((mycounter*blocksize)+1:(mycounter+1)*blocksize) = stream_in_full((mycounter*blocksize)+1:(mycounter+1)*blocksize)/offset;
        
        %Add the offset to the list
        offsetList(1,mycounter+1) = offset;
    end

    % Deal with leftover elements
    mycounter = mycounter+1;
    stream_out(mycounter*blocksize:end) = stream_in_full(mycounter*blocksize:end)/offset;
    
%     freqOff = (angle(offsetList(1,1))-angle(offsetList(1,2)))/blocksize;
%     freqOff = 0;
%     for n = first_pilot:factor:length(stream_in_full)
%         a = stream_in_full(1,n);
%         b = stream_in_full(1,n+1);
%         diff = angle(a) - angle(b);
%         freqOff = freqOff + diff;
%     end
%     freqOff = (freqOff*factor) / length(stream_in_full);
    
    
end