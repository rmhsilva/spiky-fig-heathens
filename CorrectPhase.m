%CorrectPhase

%Splits up the input stream into columns
%The number of columns is based on the pilot frequency

%Each column then has an average per-row deviation calculated
%The column with the smallest deviation is assumed to be the one with the pilots

%The mean of the pilot column elements is taken and compared with the ideal pilot
%The phase angle is then calculated and the inverse is applied to all symbols

%The result should be a phase corrected signal
%The column index is also returned as the pilot symbol start index

%NOTE: matrix notation is rows x columns

function [stream_out,initial] = CorrectPhase(stream_in, factor, pilotSymbol)
    
    mat = reshape(stream_in,factor,length(stream_in)/factor)';
    
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
    
    %Find a mean average of the pilots
    tot = 0;
    for n = 1:row
        tot = tot + mat(n,initial);
    end
    meanPilot = tot / row;
    
    %Calculate offset and reverse it
    offset = meanPilot/pilotSymbol;
    stream_out = -(stream_in/offset);    
end