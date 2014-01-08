%RootRaisedCosineFilter
%Applied specified filter to the input stream according to parameters
%Using implementation from coursework 1 as template

function stream_out = RootRaisedCosineFilter(stream_in, factor, order)
    h = sqrt(factor)*firrcos(order,1/factor,0.5,2,'rolloff','sqrt');
    stream_out = filter(h,1,stream_in);
end