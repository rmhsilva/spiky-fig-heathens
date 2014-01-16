clear all;

%Generate random symbol stream
Len = 100000;
input_syms = zeros(1,Len);
for n = 1:length(input_syms)
    input_syms(1,n) = randi([0,7]);
end

%PSK mod
txstream = pskmod(input_syms,8);
%plot(real(txstream));

%Create noisy signals
snrmax = 17;
channelstream = zeros(snrmax,Len);
for n = 1:snrmax
    channelstream(n,:) = awgn(txstream,n);
end

%PSK demods
rxstream = zeros(snrmax,Len);
for n = 1:snrmax
    rxstream(n,:) = pskdemod(channelstream(n,:),8);
end


%Convert symbols to bit streams
inputbits = SymbolsToBits(input_syms);
outputbits = zeros(snrmax,Len*3);
for n = 1:snrmax
    outputbits(n,:) = SymbolsToBits(rxstream(n,:));
end

%Calculate BERs
BERs = zeros(snrmax,1);
errs = 0;
for n = 1:snrmax
    for m = 1:Len
        if(inputbits(1,m) ~= outputbits(n,m))
            errs = errs + 1;
        end
    end
    BERs(n,1) = errs/Len;
    errs = 0;
   
end
%figure(1); semilogy(BERs);


%Generate theoretical 8PSK BER curve
%Symbol error rate = 2Q(sqrt(2*SNR<linear>) * sin(pi/8))
%Divide by bits per symbol for gray coded error rate
linearSNRs = zeros(1,snrmax);
for n = 1:snrmax
    linearSNRs(1,n) = 10^(n/20);
end

theoretical = zeros(1,snrmax);
for n = 1:snrmax
    stuff = sin(3.14159/8)*sqrt(2*linearSNRs(1,n));
    theoretical(1,n) = (2/3)*qfunc(stuff);
end
%semilogy(theoretical); grid on;
figure(1);
semilogy(1:snrmax,theoretical,1:snrmax,BERs,'LineWidth',3); 
grid on;
title('Theoretical vs simulated BER for 8 PSK');
xlabel('SNR (dB)');
ylabel('BER');
legend('show');