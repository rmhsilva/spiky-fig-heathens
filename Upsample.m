%Upsample
%Upsample by an integer amount
function stream_out = Upsample(stream_in, factor)
    stream_out = zeros(1,length(stream_in)*factor);
    
    c = 1;
    for n = 1:length(stream_in)
        stream_out(1,c) = stream_in(1,n);
        c = c + factor;
    end
end