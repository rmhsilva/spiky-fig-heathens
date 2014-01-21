% Matlab script file:	DigiTrans.m
%	
% This file simulates a transmission of 16-QAM data. 
%
% All functions which are called from this script file are available
% from http://www.ecs.soton.ac.uk/~sw1/ez622/ez622.html
%
% S. Weiss, 10/11/2001
clear all;

Nbits = 3;  % 3 bits per symbol -> 8-PSK
phase_offset = 0;  % For PSK modulation
pilot_freq = 10;

% TEMPORARY:
rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bit stream generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LB = 1000;               % number of bits
LB = LB - mod(LB,Nbits);  % Make number of bits aligned with symbol size
B = BitStream(LB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conversion to symbol 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = BitsToSymbols(B);     % group Nbits successive bits
                          % into each I and Q
x_pilot = AddPilotSymbols(x, 0, pilot_freq, 1); % Add Pilot symbols
X = PSK_Mod(x_pilot,Nbits);           % Do PSK modulation
% X = pskmod(x_pilot, 2^Nbits, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% upsamling and transmit filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 16; 	% oversampling factor for transmitted data;
Xup = Upsample(X, N);

%h = sqrt(N)*firrcos(10*N,1/N,.5,2,'rolloff','sqrt');
h = TxRxFilter;
s = filter(h,1,Xup);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add a carrier offset to the time domain signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%100Hz worst case
%Symbol freq = 6666 symbols/sec

offset = (1/N) * (100/6666);  % of the symbol frequency (N)
s = CarrierOffset(s, offset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering with channel impulse response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = [1 0 0];			        % CIR (at N x symbol rate)
s_hat = filter(c,1,s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% additive white Gaussian noise (AWGN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SNR_set', 'var') % Means we can set SNR from another script
    SNR = 20;
end
sigma_x = std(s_hat);
Ls = length(s_hat);
noise = (randn(1,Ls) + sqrt(-1)*randn(1,Ls))*sqrt(N)/sqrt(2);
s_hat = s_hat + sigma_x*10^(-SNR/10)*noise;
% s_hat = awgn(s_hat,SNR);
% line above WAS: (incorrectly) s_hat = s_hat + sigma_x*10^(-SNR/20)*sqrt(N)*noise;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receive filtering, gain and quantisation modelling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_hat = s_hat .* 0.1;                    % Receiver gain for -110dBm (10% of full swing)
s_real = quantise(real(s_hat), 16);     % 16 bit quantisation for real data
s_imag = quantise(imag(s_hat), 16);     % 16 bit quantisation for imag data
s_quantised = s_real + s_imag.*1i;  % Recombine the data
s2_quantised = s_hat;

s2 = filter(h,1,s_quantised);
%s2 = s_quantised;

% eye diagram
% N_lines = 100;
% EYE = zeros(32,N_lines); 
% EYE(:) = s2(N*10+1:N*10+32*N_lines)';
% figure(5); clf;
% plot(imag(EYE));	% I-component only
% title('eye diagram of received data');
% xlabel('wrapped time'); ylabel('I-component amplitude');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sampling at symbol rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Ninit = 1;                     % determine sampling point (0<Ninit<=N)
% EstimateNinitBetter does two things:
%   Finds the start of 'real' data (ie skips initial junk)
%   Calculates the best sampling point based on average signal power
[start_point, Ninit] = EstimateNinitBetter(s2, N);
%Ninit = 1;
%start_point = 160;
disp(sprintf('using Ninit: %d and start: %d', Ninit, start_point));

X_hat = Downsample(s2, N, start_point+Ninit);

% plot received constellation
% figure(2); clf;
% plot(X_hat(20:100),'.');
% title('constellation'); xlabel('I'); ylabel('Q');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%derp = EstimateFrequencyOffset(X_hat);
CorrectFrequency(X_hat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[X_phase_corrected,first_pilot,freqOff] = CorrectPhase(X_hat, pilot_freq, points(1));
%X_phase_corrected = X_hat;
%first_pilot = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conversion from 8-PSK to bits stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reposition the constellation points and demodulation
[X2,X_tilde] = PSK_DemodEuc(X_phase_corrected,Nbits);
%X2 = pskdemod(X_phase_corrected, 2^Nbits, 0);


% Remove pilots and convert to bits
X2_no_pilot = RemovePilotSymbols(X2,pilot_freq,first_pilot);
B2 = SymbolsToBits(X2_no_pilot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate bit error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delayB = 0;			% to compensate delays in channel & TX/RX
diff = B(1:length(B2)) - B2(delayB+1:end);
BER = sum(abs(diff))/(length(B)-delayB);
disp(sprintf('bit error probability = %f',BER));
