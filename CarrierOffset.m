function S = CarrierOffset(s,offset)
% S = CarrierOffset(s, offset)
%
% Adds a carrier offset to a time signal s

Ls = length(s);
j = sqrt(-1);
Exp = exp(j*2*pi*offset*(0:Ls-1));

S = s.*Exp;

end

