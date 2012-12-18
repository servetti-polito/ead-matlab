function [ pitch ] = ltp_estimation( xFrame )

    % pitch (number of samples)
    range_start = 25;
    range_end = 150;
    acf_length = 40;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pitch estimation with autocorrelation

    acf = conv( xFrame(acf_length:-1:1), xFrame );
    acf = acf( acf_length : length(acf) - acf_length + 1 );     

    searchArea = acf( range_start + 1 : min(range_end, length(acf)) );
    [m, mi] = max( searchArea );
    pitch = mi(1) + range_start - 1;

    % from 80 to 300 Hz
    msA  = floor(8000/300); 
    msB = floor(8000/80); 

    [ac, lag] = xcorr(xFrame, msB, 'coeff'); 
    ac = ac( (msB+1):end );
    
    [m, i] = max(ac(msA:end));    
    
    pitch = msA+i-1;
    
end

