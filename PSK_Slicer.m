function y = PSK_Slicer(Y,Nbits,phase_offset);
% y = PSK_Slicer(Y,Nbits,phase_offset);
%
% Slices a PSK signal with Nbits per symbol.
%

y = zeros(1,length(Y));

rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

split_angle = pi/(2^Nbits);


% Re-position the constellation points
for n = 1:(2^Nbits)
  y(arg(Y) > (arg(points(n)) - split_angle) & 
    arg(Y) < (arg(points(n)) + split_angle)) = points(n);
end
