function out = qdec(idx, nbits, xol)
% function out = qdec(idx, nbits, xol)
% Uniform de-quantizer with nbits bits and range [-xol, xol]
%  idx: quantization indexes
%  out:  output vector (bounded to [-1,1]
%  nbits: number of quantization bits
%  xol: quantizer range [-xol, xol]

out = [];
L = 2^nbits;              % number of levels
delta = (2*xol)/L;        % quantization step

% xmin = -xol

% calculate output
out = -xol + ( (idx - .5) * delta );

