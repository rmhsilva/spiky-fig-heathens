function [start_point,N] = EstimateNinitBetter( s, factor )
%EstimateNinit Estimates the optimal value for Ninit
%   s: the time domain signal
%   factor: the oversampling factor

Ls = length(s);
avg_pwr = zeros(1,factor);

% TODO: eliminate noise at start of signal. Check power level.
start_point = 160;
% for n = 1:Ls
%     if mean(norm(s(n+20))) > 0.05
%       start_point = n;
%       break;
%     end
% end

% Sample the signal and calculate the average power for each Ninit:
for Ninit = 1:factor
    sdn = s(start_point+Ninit:factor:900);
    avg_pwr(Ninit) = sum(norm(sdn).^2) / Ls;
end

% figure(3); clf;
% bar(avg_pwr);
% xlabel('Value of Ninit'); ylabel('Average signal power');
% title('Signal power as initial sampling point changes');

[~, N] = max(avg_pwr);

end

