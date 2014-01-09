function y = PSK_Slicer(Y,Nbits,phase_offset);
% y = PSK_Slicer(Y,Nbits,phase_offset);
%
% Slices a PSK signal with Nbits per symbol.
%
if nargin < 3
  phase_offset = 0;
end

y = zeros(1,length(Y));

rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

split_angle = pi/(2^Nbits);

% Re-position the constellation points
for n = 1:(2^Nbits)-1
  y(warg(Y) > warg(points(n), -split_angle) &
    warg(Y) < warg(points(n+1), -split_angle)) = points(n);
end

% Do the last one specially
y(warg(Y) > warg(points(2^Nbits), -split_angle) |
  warg(Y) < warg(points(1), -split_angle)) = points(2^Nbits);
