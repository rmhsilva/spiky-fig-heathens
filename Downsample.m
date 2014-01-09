%Downsample
%Downsample by an integer amount, using a given start point

function stream_out = Downsample(stream_in, factor, first)
    stream_out = stream_in(1,first:factor:end);
end