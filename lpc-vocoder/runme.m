close all; clear all;

[x, fs, nbits] = wavread('IT01M001.wav');

y = lpc_vocoder_main(x);


