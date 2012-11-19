%% Elaborazione dell'Audio Digitale a.a. 2012/2013
%% LAB 01 - ES 01 

function wavplot(filename)

ch = ['mono  '; 'stereo'];
    
[y, fs, nbits, opts] = wavread(filename);

n = 0:length(y)-1;
t = n * (1/fs);				% samples are spaced apart 1/Fs seconds
ptitle = sprintf('%s (%s) sampled at %d Hz, using %d bits', filename, ch(size(y,2),:), fs, nbits);
plot(t,y);
title(ptitle);

ylabel('Amplitude');
xlabel('Time (s)');

ax = axis;
axis([ax(1) ax(2) -1 1]);

%opts.fmt