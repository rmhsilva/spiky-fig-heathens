% Matlab script file:	DigiTrans.m
%	
% This file simulates a transmission of 16-QAM data. 
%
% All functions which are called from this script file are available
% from http://www.ecs.soton.ac.uk/~sw1/ez622/ez622.html
%
% S. Weiss, 10/11/2001

Nbits = 3;  % 3 bits per symbol -> 8-PSK
phase_offset = 0;  % For PSK modulation
pilot_freq = 10;

% TEMPORARY:
rts = (1:(2^Nbits)) / (2^Nbits);
points = exp(sqrt(-1)*(2*pi*rts + phase_offset));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bit stream generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LB = 10000;			% number of bits
LB -= mod(LB,Nbits);  % Make number of bits aligned with symbol size
B = BitStream(LB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conversion to symbol 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = BitsToSymbols(B);    	% group Nbits successive bits
                                    % into each I and Q
x_pilot = AddPilotSymbols(x, 0, pilot_freq, 1); % Add Pilot symbols
X = PSK_Mod(x_pilot,Nbits);             % Do PSK modulation
% X = QAM_Mod(x,Nbits);               % to implement 2^(2*Nbits)-QAM

% Random noise for TESTING
% X += rand(1,length(X)) / 10 + sqrt(-1) * rand(1,length(X)) / 10;

% X_tilde = PSK_Slicer(X,Nbits);
% x2 = PSK_Demod(X_tilde,Nbits);

% figure(1);
% scatter(real(X),imag(X));
% figure(2);
% scatter(real(X_tilde),imag(X_tilde));

% diff = x(1:end) - x2(1:end);
% BER = sum(abs(diff))/(length(x));
% disp('ber: '); disp(BER);

% error('done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% upsamling and transmit filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 16; 	% oversampling factor for transmitted data
% Xup = zeros(1,length(X)*N);
% Xup(1:N:end) = X;
Xup = Upsample(X, N);

%h = sqrt(N)*firrcos(10*N,1/N,.5,2,'rolloff','sqrt');
h = TxRxFilter;
s = filter(h,1,Xup);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add a carrier offset to the time domain signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

offset = (1/N) * -1/70;  % 1/70th of the symbol frequency (N)
%s = CarrierOffset(s, offset);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering with channel impulse response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = [1 0 0];			        % CIR (at N x symbol rate)
s_hat = filter(c,1,s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% additive white Gaussian noise (AWGN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('SNR_set', 'var') % Means we can set SNR from another script
    SNR = 1000;
end
sigma_x = std(s_hat);
Ls = length(s_hat);
noise = (randn(1,Ls) + sqrt(-1)*randn(1,Ls))*sqrt(N)/sqrt(2);
s_hat = s_hat + sigma_x*10^(-SNR/20)*noise;
% line above WAS: (incorrectly) s_hat = s_hat + sigma_x*10^(-SNR/20)*sqrt(N)*noise;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receive filtering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s2 = filter(h,1,s_hat);

% eye diagram
N_lines = 100;
EYE = zeros(32,N_lines); 
EYE(:) = s2(N*10+1:N*10+32*N_lines)';
figure(1); clf;
plot(imag(EYE));	% I-component only
title('eye diagram of received data');
xlabel('wrapped time'); ylabel('I-component amplitude');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sampling at symbol rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ninit = 6;                     % determine sampling point (0<Ninit<=N)
%Ninit = EstimateNinit(s2, N);
disp(sprintf('using Ninit: %d', Ninit));

% TODO: Trim out initial noise.

X_hat = Downsample(s2, N, N*10 + Ninit);

% plot received constellation
figure(2); clf;
plot(X_hat(20:170),'.');
title('constellation'); xlabel('I'); ylabel('Q');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conversion from 16-QAM to bits stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[X_phase_corrected,first_pilot] = CorrectPhase(X_hat, pilot_freq, points(1));

% X_tilde = QAM_Slicer(X_hat,Nbits,'renorm');
% X2 = QAM_Demod(X_tilde,Nbits);
X_tilde = PSK_Slicer(X_phase_corrected,Nbits);
X2 = PSK_Demod(X_tilde,Nbits);
B2_pilot = SymbolsToBits(X2,Nbits);

B2 = RemovePilotSymbols(B2_pilot,pilot_freq,first_pilot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate bit error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delayB = 30;			% to compensate delays in channel & TX/RX
diff = B(1:end-delayB-23) - B2(delayB+1:end);
BER = sum(abs(diff))/(length(B)-delayB);
disp(sprintf('bit error probability = %f',BER));







