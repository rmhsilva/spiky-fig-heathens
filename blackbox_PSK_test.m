%clear all;



% %Data from our own system
results_no_corr = zeros(1,snrmax+1);
for n = 0:snrmax

    results_no_corr(n+1) = PskDigiTrans(n);
end

%Generate theoretical 8PSK BER curve
%Symbol error rate = 2Q(sqrt(2*SNR<linear>) * sin(pi/8))
%Divide by bits per symbol for gray coded error rate
linearSNRs = zeros(1,snrmax);

for n = 0:snrmax-1
    linearSNRs(1,n+1) = 10^(n/10);
end

theoretical = zeros(1,snrmax);
for n = 1:snrmax

    stuff = sin(pi/8)*sqrt(2*3*linearSNRs(1,n));
    theoretical(1,n) = (2/3)*qfunc(stuff);
end
%semilogy(theoretical); grid on;
figure(1);

% semilogy(0:snrmax-1,theoretical,'LineWidth',3);
semilogy(0:snrmax-1,theoretical,0:snrmax,results_no_corr,'LineWidth',3);
% semilogy(1:snrmax,theoretical,1:snrmax,BERs,0:17,results,'LineWidth',3); 
grid on;
% title('Theoretical vs simulated BER for 8 PSK');
title('Theoretical BER for 8 PSK');
% legend('Theoretical performance','Matlab black box','Constructed system');
legend('Theoretical performance','Constructed system');
xlabel('Eb / N0(dB)');
ylabel('BER');





