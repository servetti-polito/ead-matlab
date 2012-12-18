function [ excitation, overhang ] = excitation_synth( state, ltpDelay, overhang, blockLength )

inputNoise = randn( blockLength, 1 );

% initialize variables for encoding coder states
silence = 1;
voiced = 2;
voiceless = 3;

    %%%% if silence frame
    %
    if state == silence
      excitation = zeros( blockLength, 1 );
      overhang = 0;
    end

    %%%% if voiceless frame
    %
    if state == voiceless
        excitation = inputNoise;
        overhang = 0;
    end

      %%%% if voiced frame
  %
  if state == voiced
      excitation = zeros( blockLength, 1 );
      if overhang == 0
          first = 1; 
      else
          first = max(1, ltpDelay - overhang);
      end      
      pulses = first:ltpDelay:blockLength;
      excitation(pulses) = 1;
      overhang = blockLength - pulses(end);
  end
end

