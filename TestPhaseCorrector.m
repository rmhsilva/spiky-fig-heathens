%TestPhaseCorrector
clear all;

%Generate complex numbers (QPSK)
reals = round(rand(1,10000));
imags = round(rand(1,10000));
for n = 1:length(reals)
    if(reals(1,n) == 0)
        reals(1,n) = -1;
    end
    if(imags(1,n) == 0)
        imags(1,n) = -1;
    end
end
streamA = reals + (1i*imags);
%streamA = ones(1,10);

%Inject pilot
pilotSym = 1 + 1i;
symFreq = 10;
streamB = AddPilotSymbols(streamA,pilotSym,symFreq,1);

%Apply some phase offset
offset = 0.707 + 0.707i;
streamC = streamA * offset;
%figure(1); plot(streamA);
%figure(2); plot(streamB);

%Correction!
streamD = CorrectPhase(streamC,symFreq,pilotSym);
%figure(3); plot(streamC);

%Remove pilots
streamE = RemovePilotSymbols(streamD,symFreq,1);
%figure(4); plot(abs(streamD));

errs = 0;
for n = 1:length(streamA)
    if(streamA(1,n) ~= streamE(1,n))
        errs = errs + 1;
    end
end
