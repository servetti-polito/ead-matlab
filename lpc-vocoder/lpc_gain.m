function g = lpc_gain(xFrame)

    g = sqrt( xFrame' * xFrame ) / length(xFrame);

end
