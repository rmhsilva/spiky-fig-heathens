%Downsample
%Downsample by an integer amount, using a given start point

function stream_out = Downsample(stream_in, factor, initial)
    stream_out = stream_in(1,initial:factor:end);
end