function [y, snr] = apcm(x, fr_len, nbits, c) 
% function [y, snr] = apcm(x, fr_len, nbits, c) 
%  x: input signal bounded [-1, 1]
%  fr_len: frame_length
%  nbits: number of Q bits
%  c: scale factor for sigma

frame_length = fr_len;
input_signal = x;

% pad input signal with zeros to match an integer multiple of frame_length
n_frames = ceil((length(input_signal))/frame_length);
zer = n_frames * frame_length - length(input_signal);
input_signal = [input_signal zeros(1,zer)];

fprintf(2, 'apcm of x:%d samples every %d with c:%.2f\n', length(x), fr_len,c);
cnt = 1;
pin = 0; pout = 0;
output_signal = zeros(size(input_signal));

while pin+frame_length <= length(input_signal)
    
	% Analysis
    analysis_frame = ... 
        input_signal(pin+1:pin+frame_length);

    sigma = sqrt(var(analysis_frame));  % sigma of the speech signal
    xol = c * sigma;
    
    idx = qenc(analysis_frame, nbits, xol); % encoding
    synthesis_frame = qdec(idx, nbits, xol); % decoding

    % synthesis_frame = analysis_frame;
    
    % Synthesis
    output_signal(pout+1:pout+frame_length) = ...
            synthesis_frame;
            %output_signal(pout+1:pout+frame_length) + ... 

    pin  = pin  + frame_length;
    pout = pout + frame_length;
    
    cnt = cnt + 1;
end

snr = 10*log10( sum(input_signal.^2) / sum((input_signal-output_signal).^2) );

y = output_signal;

end
