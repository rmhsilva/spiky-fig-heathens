function [start_point,N] = EstimateNinitBetter( s, Nbits )
%EstimateNinit Estimates the optimal value for Ninit
%   s: the time domain signal
%   Nbits: the number of bits per sample

Ls = length(s);
avg_pwr = zeros(1,Nbits);

% TODO: eliminate noise at start of signal. Check power level.
start_point = 1;
for n = 1:Ls
    if norm(s(n)) > 0.5
      start_point = n;
      break;
    end
end

% Sample the signal and calculate the average power for each Ninit:
for Ninit = 1:Nbits
    sdn = s(start_point+Ninit:Nbits:end);
    avg_pwr(Ninit) = sum(norm(sdn).^2) / Ls;
end

figure(3); clf;
bar(avg_pwr);
xlabel('Value of Ninit'); ylabel('Average signal power');
title('Signal power as initial sampling point changes');

[~, N] = max(avg_pwr);

end

