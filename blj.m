global result;
for snr = 0:15
    result(snr+1) = erfc( 10^(-snr/20) *sin(pi/8) );
end
semilogy(result);
disp(result);