function [ lpc_output, lpc_mem ] = lpc_synth(excitation, coeff , lpc_mem)

    [lpc_output, lpc_mem] = filter(1, [1; coeff] , excitation, lpc_mem);

      
end

