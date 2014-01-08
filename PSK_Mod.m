function X = PSK_Mod(x,Nbits,phase_offset);
% X = PSK_Mod(x,Nbits,phase_offset);
% Modulates x using PSK with Nbits per symbol
% e.g., PSK_Mod(x,3) would do 8-PSK on x
% x is a vector of symbols
% phase_offset is a phase offset, default 0 radians
%
if nargin < 3
  phase_offset = 0;
end

Lx = length(x);

rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

% TODO gray coding here??


X = points(x+1);