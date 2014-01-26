function [y,sliced] = PSK_Demod(Y,Nbits,phase_offset)
% y = PSK_Demod(Y,Nbits,phase_offset);
%
% Converts a complex PSK signal into symbols
%
if nargin < 3
  phase_offset = 0;
end

y = zeros(1,length(Y));
sliced = zeros(1,length(Y));

rts = (1:(2^Nbits)) / (2^Nbits);
% points = exp(sqrt(-1)*(2*pi*rts + phase_offset));
% 
% split_angle = pi/(2^Nbits);

% Re-position the constellation points
points = warg(exp(sqrt(-1)*(2*pi*rts + phase_offset)));

%Get angles of the incoming stream
angles = warg(Y);

%Calculate angle offsets and select best match
for n = 1:length(angles)
    %Find closest point
    closest = 0;
    angmin = 10;
    tempres = zeros(1,8);
    for m = 1:8
        %angtemp = abs(angle(points(1,m)) - angle(stream_in(1,n)));
        angtemp = abs(points(1,m) - angles(1,n));
        tempres(1,m) = angtemp;
        if(angtemp < angmin)
            angmin = angtemp;
            closest = m;
        end           
    end
    y(n) = closest-1;
    sliced(n) = points(closest);
end

% for n = 1:(2^Nbits)
%   y(warg(Y) > warg(points(n), -split_angle) & warg(Y) < warg(points(n+1), -split_angle)) = n-1;
%   sliced(warg(Y) > warg(points(n), -split_angle) & warg(Y) < warg(points(n+1), -split_angle)) = points(n);
% end
% 
% % Do the last one specially
% y(warg(Y) > warg(points(2^Nbits), -split_angle) | warg(Y) < warg(points(1), -split_angle)) = (2^Nbits) - 1;
% sliced(warg(Y) > warg(points(2^Nbits), -split_angle) | warg(Y) < warg(points(1), -split_angle)) = points(2^Nbits);



end