function [y,sliced] = PSK_DemodEuc(X,Nbits,phase_offset);
% y = PSK_Demod(X,Nbits,phase_offset);
%
% Converts a complex PSK signal into symbols
%
if nargin < 3
  phase_offset = 0;
end

y = zeros(1,length(X));
sliced = zeros(1,length(X));

rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));


for n=1:length(X)
  [val,index] = min(abs(X(n) - points));

  sliced(n) = points(index);
  y(n) = index-1;
end
