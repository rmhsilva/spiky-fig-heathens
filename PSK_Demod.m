function y = PSK_Demod(Y,Nbits,phase_offset);
% y = PSK_Demod(Y,Nbits,phase_offset);
%

y = zeros(1,length(Y));

rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

for n = 1:(2^Nbits)
  y(arg(Y) == arg(points(n))) = n-1;
end