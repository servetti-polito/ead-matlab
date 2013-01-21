function [Nb,SNR] = alloc(SMR, br)

% Implements a simplified version of the MPEG1 bit allocation algorithm
% input:
%  SMR is the signal to mask ratio in each subband
%  br is the audio bitrate in kb/s
% output:
%  Nb is a vector with the number of bits to be used in each subband in the
%     range 0..16 (no more, no less)
%  SNR is the SNR in each subband (in the best case)

Fs=44100;

% Compute the number of bits available for the quantization given
% Fs and br
available = br*384/Fs- 6*27-4*27;    % REMOVE
used = 0;

% The bit allocation process should mazimize the Mask-to-Noise Ratio
Nb = zeros(1,32);
SNR = zeros(1,32);
MNR = SNR-SMR;

% Bit allocation for subband
% At each loop update the SNR of the modified subband as follows:
%   SNR(k) = 1.76 + 6.02 * Nb(k)
while used < available
	[temp kmin] = min(MNR);
    if Nb(kmin) == 16
		SNR(kmin) = 100; % avoid more then 16 bits
	else
		if Nb(kmin)==0
            % Avoid having 1 bit only
            Nb(kmin) = 2;
        else
            Nb(kmin) = Nb(kmin) + 1;
        end
        % Assuming sub-band signal = full scale cosine
        SNR(kmin)=1.77+6.02*Nb(kmin);
    end
    MNR(kmin) = SNR(kmin) - SMR(kmin);
	used = 12*sum(Nb);
	
end