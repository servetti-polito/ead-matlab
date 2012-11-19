%% Elaborazione dell'Audio Digitale a.a. 2012/2013
%% LAB 01 - ES 02

function [y, fs, nbits] = mywavread(filename)
% [y, fs, nbits] = mywavread(filename)
% Same as wavread

[fid, msg] = fopen(filename,'rb');
if (fid<0)
    error('wavread: %s', msg);
end

riff = fread(fid,4,'char=>char');
if(strcmp(riff','RIFF') == 0)
    fclose(fid); error('wavread: no RIFF');
else
    fprintf(2,'RIFF file\n');
end

fseek(fid,4,'cof');

wave = fread(fid,4,'char=>char');
if(strcmp(wave','WAVE') == 0)
    fclose(fid); error('wavread: no WAVE');
else
    fprintf(2,'WAVE file\n');
end

fmt = fread(fid,4,'char=>char');
fmt = char(fmt');
if(strcmp(fmt,'fmt ') == 0)
    fclose(fid); error('wavread: no fmt chunk found');
else
    fprintf(2,'fmt_ chunk found\n');    
end

fseek(fid,4,'cof'); % skip subchunk size

fmt_tag = fread(fid,1,'uint16', 0, 'ieee-le');
if(fmt_tag ~= 1)
    fclose(fid); error('wavread: no PCM [read: %u]', fmt_tag);
else
    fprintf(2,'PCM format\n');
end

nch = fread(fid, 1, 'uint16', 0, 'ieee-le');
fprintf(2,'channels: %u\n', nch);

fs = fread(fid, 1, 'uint32', 0, 'ieee-le');
fprintf(2,'samplerate: %u\n', fs);

fseek(fid,4,'cof'); % skip byterate
fseek(fid,2,'cof'); % skip blockalign

nbits = fread(fid, 1, 'uint16', 0, 'ieee-le');
fprintf(2,'bits per sample: %u\n', nbits);

data = fread(fid,4,'char=>char');
if(strcmp(data','data') == 0)
    fclose(fid); error('wavread: no data chunk found');
else
    fprintf(2,'data chunk found\n');    
end

fseek(fid,4,'cof'); % skip subchunk size

switch(nbits)
    case 8
        format = 'uint8';
    case 16
        format = 'int16';
    otherwise
        fclose(fid);
        error('wavread: %d sample resolution not supported', nbits);
end

fprintf(2,'reading %s samples\n', format);

[yi, n] = fread(fid,inf,format,0,'ieee-le');
fprintf(2,'read %u samples\n', n);

fclose(fid);

% Normalization
switch(nbits)
    case 8
        yi = (yi-128) / 127;
    case 16
        yi = yi / 32767;
end

nr = numel(yi) / nch;
y = reshape(yi,nch,nr)';

end