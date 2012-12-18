function [ coeff, lpc_mem, res_xFrame ] = lpc_filter( xFrame, order , lpc_mem)

      len = length(xFrame);
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % amplitude of input signal
      %
      amp = sqrt( xFrame' * xFrame / len );

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % linear prediction coefficients
      a = lpc( xFrame, order );
      coeff = a(2:end);

      [est_xFrame lpc_mem] = filter([0 -coeff], 1, xFrame, lpc_mem);   % Estimated signal
      res_xFrame = xFrame - est_xFrame;

      

end

