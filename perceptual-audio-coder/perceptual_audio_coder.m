clear all; close all;

% 550Hz quiet tone, 500Hz loud tone. Quiet tone is masked. 
infilename = 'violin.wav';
outfilename = 'violin.mp3.wav';

M = 32;
N = 512;

XX = 349;
bitrate = 64000;

load -ascii pqmf32;

% Filter-bank definition
G = zeros(32, 512);
for i = 0:(M-1)
    n = 0:(N-1);
    fi = .5*(2*i+1)/(2*M);
    di = (2*i+1)*pi/4;
    G(i+1,:) = pqmf32 .* cos(2*pi*fi*n+di);
end

[input,Fs] = wavread(infilename);

%% Subband decompostion
frame = zeros(N,1);
%output_signal = zeros(size(input));
% number of frames to be processed
Nf = fix((length(input)-N+M)/M);   

for i=1:Nf
     
     % Extract overlapping input frames
     s = (i-1)*M;   % first input frame sample
     frame = input(s+1:s+N);
 
     % Multiplication performs filtering and downsampling
     subbands(i,:) = (G * frame)';
      
end


%% Quantization of subband blocks of 12 values x 32 subbands = 384 input samples
figure;

% Integer number of groups of 12 frames 
% (for floating point quantization of subband blocks)
Nf = fix(Nf/12)*12;

for k=1:12:Nf
    % for each block
    
    % Compute scalefactors (sfs) for each block (absolute max value)
    [sfs,tmp] = max(abs(subbands(k:k+11,:)));
    
    % Compute SMRs (center analysis frame with subband data frame)
    offset = (12-1)*(M/2); % first frame offset = 176
    frame = input(offset+(k-1)*M:offset+(k-1)*M+(N-1));
    [SMR, min_thr, psd_spl] = psycho(frame);

   % Calculate bit allocation for a target bit rate of 192 kb/s
    Nb = alloc(SMR, bitrate);
    nn = Nb(ones(1,(N/2)/M),:);
    
    % -------------------
    % Adaptive uniform quantization with mid-thread quantizer
    for j=1:32 % for a subband

        if Nb(j)~=0
            delta = 2^(Nb(j)-1)/sfs(j);
            qsub(k:k+11,j) = ...
                (floor(delta*subbands(k:k+11,j)+0.5))/delta; 
        else
            qsub(k:k+11,j) = 0;
        end;

    end;
    % --------------------
    
    % Psycho-acoustic analysis of an input frame
    if k==XX
        f = (0:(N/2-1))/N*Fs;
        plot(f, psd_spl, '-k', f, min_thr,'.b', f, nn(:)*10, '.g');
        hold on;
    end
           
    fprintf('.')

end;
fprintf('\n')

%% Signal re-synthesis
output = zeros(size(input));

for i=1:Nf
    
    % Synthesis filters
    oframe = G' * qsub(i,:)';
    
    % Output frames overlap-add (delay N samples)
    ii = (i-1)*M; 
    output(ii+1:ii+N)= output(ii+1:ii+N) + oframe;
end

% Analysis of perceptual coding
error = output(offset+(XX-1)*M:offset+(XX-1)*M+(N-1)) ...
        - input(offset+(XX-1)*M:offset+(XX-1)*M+(N-1));

f = (0:(N/2-1))/N*Fs;

[dummy, dummy, error_psd_spl]= psycho(error);

plot(f, error_psd_spl, 'r');
axis([0 22050 -20 100]);
legend('Signal', 'Masking','Bits','Error');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB) / Bits (*10)');
hold off;

wavwrite(output,Fs,outfilename);
