function [ state zcr ] = voicing_decision( xFrame )

silence_threshold = 20.0; % 27.120; %1.0240;
voiced_threshold = 0.3;
zcr = 0;

% initialize variables for encoding frame types 
silFrame = 1;
voicedFrame = 2;
unvoicedFrame = 3;

len = length(xFrame);

%= signal energy
xAmp = sqrt( xFrame' * xFrame ) / len;

  if xAmp < silence_threshold
    state = silFrame;
  else
    % use ZCR to estimate voiced/unvoiced statte
    signum = sign( xFrame );
    zcr = sum( 0.5 * abs( signum(1:len-1) - signum(2:len) ) ) / (len-1);
    if zcr <= voiced_threshold 
      state = voicedFrame;
    else
      state = unvoicedFrame;
    end
  end
  
end

