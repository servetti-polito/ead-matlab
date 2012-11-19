function snrdb = snr( signal, noise )

   e_signal = sum(signal(:).^2); % does not subtract the means
   e_noise  = sum(noise(:) .^2);
   snrdb = 10*log10(e_signal/e_noise);
