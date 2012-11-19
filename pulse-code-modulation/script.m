clear all; close all;

%% Elaborazione dell'Audio Digitale a.a. 2012/2013
%% LAB 01 - ES 03 (+ snr.m script)

figure(1);
wavplot('music_ost.wav');

[y, fs, nbits] = mywavread('speech.wav');


%% try to change this value N: 6, 4, 2
%% check the resulting SNR and plot

N = 6;              % scale to use only N bits
A = 2^(nbits-N);    % scale factor

yN = y/A;

y_range = max(y)-min(y);    % dynamic range of y
yN_range = max(yN)-min(yN); % dynamic range of yN

delta = 2/2^nbits;          % delta with nbits

fprintf('y dynamic range is %f, i.e. %f times delta (%f).\n', y_range, y_range/delta, delta);
fprintf('  %f times delta means log2(%f) ~= %d bits.\n', y_range/delta, y_range/delta, round(log2(y_range/delta)));

fprintf('yN dynamic range is %f, i.e. %f times delta (%f).\n', yN_range, yN_range/delta, delta);
fprintf('  %f times delta means log2(%f) ~= %d bits.\n', yN_range/delta, yN_range/delta, round(log2(yN_range/delta)));

wavwrite(yN, fs, nbits, 'speech_N.wav');

[yN, fs, nbits] = wavread('speech_N.wav');

% rescale
yN = yN*A;

figure(2);
i = 40000:40160;
plot(i,y(i),i,yN(i));

snrdb = snr(y,y-yN);

fprintf('SQNR from %d to %d bits is %f dB.\n', nbits, N, snrdb);

