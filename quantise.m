function out = quantise(stream, Nbits)

maxX = 2^Nbits - 1;
step = 2/maxX;

levels = -1:step:1;  % Signal varies between -1 and 1

out = zeros(1,length(stream));

for n=1:length(stream)
  difference = abs(stream(n) - levels);
  [~,idx] = min(difference);
  out(n) = levels(idx);
end