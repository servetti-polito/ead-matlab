clear all; close all;

figure(1);
in = -1.5:2^-8:+1.5;
idx = qenc(in,4,1); out = qdec(idx,4,1);
plot(in,out); axis([-1.5 +1.5 -1.5 +1.5]);
xlabel('in'); ylabel('out');
title('Quantizer mapping');
grid on;


figure(2);
nbit = 8; fs = 8000;
wav = 0.3.*randn(64000,1);
% uncomment the next line to load a speech file
% [wav, fs, nbit] = wavread('IT01M001-A.wav');

% get a single row vector
input_signal = wav';
frame_duration = 15; % ms
frame_length = fs * frame_duration/1000;

snr_log_2 = [];

m = 1:5;
for nbits = m

snr_log = [];
n = 1.5:.05:4;

for c = n

    [output_signal, snr] = apcm(input_signal, frame_length, nbits, c);
    snr_log = [snr_log snr];

    figure(2);
    frame_plot = 175;
    range = 1 + frame_length * frame_plot : frame_length * (frame_plot+1);
    plot(range,input_signal(range),range,output_signal(range));
    
    %pause(.05);
end

snr_log_2 = [snr_log_2 ; snr_log];

end

figure(3);
[a,b] = max(snr_log_2');
plot(n,snr_log_2',n(b),a,'*'); 
txt = cell(length(1:5),1); for k = 1:5 ; txt{k} = sprintf('%d bits (c=%.2f)', k, n(b(k))); end
legend(txt,'Location','SouthEast');
xlabel('c (xol/sigma)');
ylabel('snr (dB)');
title(sprintf('Uniform quantizer with dynamic range adapted to signal sigma every %dms',frame_duration));
hold on;
