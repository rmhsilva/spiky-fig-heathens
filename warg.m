function a = warg(phi, offset);
% a = warg(phi, offset);
%
% Utility function to make it easier to check phase inequalities
% Calc arg of phi, in the interval [0,2pi]
% offset is added to the angle before changing interval
if nargin < 2
  offset = 0;
end

a = mod(arg(phi)+offset,2*pi);