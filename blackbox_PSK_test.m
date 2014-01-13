clear all;

%Generate random symbol stream
Len = 1000000;
input_syms = zeros(1,Len);
for n = 1:length(input_syms)
    input_syms(1,n) = randi([0,7]);
end

%PSK mod
txstream = pskmod(input_syms,8);
%plot(real(txstream));

%Create noisy signals
snrmax = 15;
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

semilogy(BERs);