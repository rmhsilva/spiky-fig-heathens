%SNR_tests
%Runs the PskDigiTrans function, making a table of results

SNRmax = 16;
results = zeros(1,SNRmax+1);
for SNR = 0:16
    results(SNR+1) = PskDigiTrans(SNR);
end