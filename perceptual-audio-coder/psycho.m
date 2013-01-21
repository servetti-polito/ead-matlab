function [SMR, thr, psd, masking] = psycho(frame)


global LTq_i LTq_k Table_z Frontieres_i Frontieres_k Larg_f

if size(LTq_i)==[0,0]


i1 = 1:48;
i2 = (49:72)-48;
i3 = (73:108)-72;
i_to_k = [i1 (2*i2+48) (4*i3+96)];


LTq_i = [25.87 14.85 10.72  8.50  7.10  6.11  5.37  4.79 ...
             4.32  3.92  3.57  3.25  2.95  2.67  2.39  2.11 ...
             1.83  1.53  1.23  0.90  0.56  0.21 -0.17 -0.56 ...
            -0.96 -1.38 -1.79 -2.21 -2.63 -3.03 -3.41 -3.77 ...
            -4.09 -4.37 -4.60 -4.78 -4.91 -4.97 -4.98 -4.92 ...
            -4.81 -4.65 -4.43 -4.17 -3.87 -3.54 -3.19 -2.82 ...
            -2.06 -1.32 -0.64 -0.04  0.47  0.89  1.23  1.51 ...
             1.74  1.93  2.11  2.28  2.46  2.63  2.82  3.03 ...
             3.25  3.49  3.74  4.02  4.32  4.64  4.98  5.35 ...
             6.15  7.07  8.10  9.25 10.54 11.97 13.56 15.31 ...
            17.23 19.34 21.64 24.15 26.88 29.84 33.05 36.52 ...
            40.25 44.27 48.59 53.22 58.18 63.49 68.00 68.00 ...
            68.00 68.00 68.00 68.00 68.00 68.00 68.00 68.00 ...
            68.00 68.00 68.00 68.00];


LTq_k = zeros(250, 1);
for i = 1:length(LTq_i)
    LTq_k(i_to_k(i)) = LTq_i(i);
end
for k = 1:250
    if LTq_k(k) == 0
        LTq_k(k) = last_nonzero;
    else
        last_nonzero = LTq_k(k);
    end
end


Table_z = [ .850 1.694 2.525 3.337 4.124 4.882 5.608 6.301 ...
             6.959  7.581  8.169  8.723  9.244  9.734 10.195 10.629 ...
            11.037 11.421 11.783 12.125 12.448 12.753 13.042 13.317 ...
            13.578 13.826 14.062 14.288 14.504 14.711 14.909 15.100 ...
            15.284 15.460 15.631 15.796 15.955 16.110 16.260 16.406 ...
            16.547 16.685 16.820 16.951 17.079 17.205 17.327 17.447 ...
            17.680 17.905 18.121 18.331 18.534 18.731 18.922 19.108 ...
            19.289 19.464 19.635 19.801 19.963 20.120 20.273 20.421 ...
            20.565 20.705 20.840 20.972 21.099 21.222 21.342 21.457 ...
            21.677 21.882 22.074 22.253 22.420 22.576 22.721 22.857 ...
            22.984 23.102 23.213 23.317 23.415 23.506 23.592 23.673 ...
            23.749 23.821 23.888 23.952 24.013 24.070 24.125 24.176 ...
            24.225 24.271 24.316 24.358 24.398 24.436 24.473 24.508 ...
            24.542 24.574 25 25];
    
Frontieres_i = [1 2 3 5 6 8 9 11 13 15 17 20 23 27 32 37 ...
          45 50 55 61 68 75 81 93 106];

Frontieres_k = zeros(1, length(Frontieres_i));
for i = 1:length(Frontieres_i)
    Frontieres_k(i) = i_to_k(Frontieres_i(i));
end

f_250_c = [0 Frontieres_k 296];
f_250_d = [0 Frontieres_k 256];

upper_bound = 1;
lower_bound = 1;
while upper_bound < 250
    lower_bound = lower_bound + 1;
    for k = 1:25
        if lower_bound >= f_250_c(k) & lower_bound < f_250_c(k+1)
            larg_bas = f_250_c(k+1) - f_250_c(k);
            no_ech_bas = f_250_c(k+1) - lower_bound;
        end
    end
    if no_ech_bas >= ceil(larg_bas/2)
        larg_fen = ceil(larg_bas/2);
    else
        for k = 1:25
            if upper_bound >= f_250_c(k) & upper_bound < f_250_c(k+1)
                larg_haut = f_250_c(k+1) - f_250_c(k);
                no_ech_haut = upper_bound - f_250_c(k);
            end
        end
        no_ech_tot = no_ech_haut + no_ech_bas;
        larg_fen = ceil((larg_bas*no_ech_bas/no_ech_tot+larg_haut*no_ech_haut/no_ech_tot)/2);
    end
    upper_bound = lower_bound + larg_fen;
    Larg_f(lower_bound) = larg_fen;
end

end;

N = length(frame);
if N ~= 512
    disp('Frame length must be set to 512')
    return
end

% FFT
% ***

hann = sqrt(8/3)/2*[ones(N, 1) - cos(2*pi*(0:N-1)'/N)];
if sum(abs(frame)) > 0
    X1 = fft(frame.*hann);
    X1 = (abs(X1(1:N/2+1)).^2)/N;
    perio_xn_db = 10*log10(X1);
else
    perio_xn_db = zeros(N/2+1,1);
end

offset=96-27.09;
X = perio_xn_db + offset;
psd=X(1:256);

max_local = zeros(250, 1);
for k = 3:250
    if X(k) > X(k-1) & X(k) >= X(k+1)
        max_local(k) = 1;
    end
end

tonal = zeros(250, 1);
for k = 3:62
    if max_local(k)
        tonal(k) = 1;
        for j = [-2 2]
            if X(k) - X(k+j) < 7
                tonal(k) = 0;
            end
        end
    end
end

for k = 63:126
    if max_local(k)
        tonal(k) = 1;
        for j = [-3 -2 2 3]
            if X(k) - X(k+j) < 7
                tonal(k) = 0;
            end
        end
    end
end

for k = 127:250
    if max_local(k)
        tonal(k) = 1;
        for j = [-6:-2 2:6]
            if X(k) - X(k+j) < 7
                tonal(k) = 0;
            end
        end
    end	
end


X_tm = zeros(250,1);

for k = 1:250
    if tonal(k)
        temp = 10^(X(k-1)/10) + 10^(X(k)/10) + 10^(X(k+1)/10);
        X_tm(k) = 10*log10(temp);
        X(k-1) = -100; 
        X(k)   = -100;
        X(k+1) = -100;
    else
        X_tm(k) = -100;
    end
end

X_nm = -100*ones(250, 1);
k = 1;
for k1 = Frontieres_k
    geom_mean = 1;
    pow = 0;
    raies_en_sb = 0;
    while k <= k1
        geom_mean = geom_mean*k;
        pow = pow + 10^(X(k)/10);
        k = k + 1;
        raies_en_sb = raies_en_sb + 1;
    end
    geom_mean = floor(geom_mean^(1/raies_en_sb));
    X_nm(geom_mean) = 10*log10(pow);
end

X_tm_avant = X_tm;
X_nm_avant = X_nm;

for k = 1:250
    if X_tm(k) < LTq_k(k)
        X_tm(k) = -100;
    end
    if X_nm(k) < LTq_k(k)
        X_nm(k) = -100;
    end
end

upper_bound = 1;
lower_bound = 1;
while upper_bound < 250
    [ans, max_ix] = max(X_tm(lower_bound:upper_bound));
    for k = lower_bound:upper_bound
        if k-lower_bound+1 ~= max_ix
            X_tm(k) = -100;
        end
    end
    lower_bound = lower_bound + 1;
    upper_bound = lower_bound + Larg_f(lower_bound);
end

Nbre_comp_i = length(Table_z);
X_tm_i = -100*ones(Nbre_comp_i, 1);
X_nm_i = -100*ones(Nbre_comp_i, 1);

for k = 1:250
    if X_tm(k) >= -10
        X_tm_i(ppv(k)) = X_tm(k);
    end
end

for k = 1:250
    if X_nm(k) >= -10
        X_nm_i(ppv(k)) = X_nm(k);
    end
end

seuil_m = zeros(Nbre_comp_i, 1);

no_tm = 0;
no_nm = 0;
for i = 1:Nbre_comp_i
    if X_tm_i(i) > -100
        no_tm = no_tm + 1;
    end
    if X_nm_i(i) > -100
        no_nm = no_nm + 1;
    end
end

tab_tm = zeros(1,no_tm);
tab_nm = zeros(1,no_nm);

ix = 1;
for i = 1:Nbre_comp_i
    if X_tm_i(i) > -100
        tab_tm(ix) = i;
        ix = ix + 1;
    end
end

ix = 1;
for i = 1:Nbre_comp_i
    if X_nm_i(i) > -100
        tab_nm(ix) = i;
        ix = ix + 1;
    end
end

for i = 1:Nbre_comp_i
    sum_tm = 0;
    z_i = Table_z(i);
    for j = tab_tm
        z_j = Table_z(j);
        dz = z_i - z_j;
        if dz >= -3 & dz < 8
            LT_tm = X_tm_i(j) + (-1.525 - 0.275*z_j - 4.5) + vf(dz, j, X_tm_i);
            sum_tm = sum_tm + 10 ^ (LT_tm/10);
        end
    end
    sum_nm = 0;
    for j = tab_nm
        z_j = Table_z(j);
        dz = z_i - z_j;
        if dz >= -3 & dz < 8
            LT_nm = X_nm_i(j) + (-1.525 - 0.175*z_j - 0.5) + vf(dz, j, X_nm_i);
            sum_nm = sum_nm + 10 ^ (LT_nm/10);
        end
    end
    seuil_m(i) = 10 * log10(10^(LTq_i(i)/10) + sum_tm + sum_nm);
end

masking = zeros(1,256);
thr = zeros(1,256);
for i = 1:6
    t1 = seuil_m(8*(i-1)+1:8*(i));
    masking(8*(i-1)+1:8*(i)) = t1;
    thr(8*(i-1)+1:8*(i)) = ones(1,8)*min(t1);
end
for i = 7:12
    i1 = i - 6;
    t1 = seuil_m(49+4*(i1-1):48+4*(i1));
    t2(1:2:7) = t1;
    t2(2:2:8) = t1;
    masking(8*(i-1)+1:8*(i)) = t2;
    thr(8*(i-1)+1:8*(i)) = ones(1,8)*min(t1);
end
for i = 13:30
    i1 = i - 12;
    t1 = seuil_m(73+2*(i1-1):72+2*(i1));
    t2(1:4:5) = t1;
    t2(2:4:6) = t1;
    t2(3:4:7) = t1;
    t2(4:4:8) = t1;
    masking(8*(i-1)+1:8*(i)) = t2;
    thr(8*(i-1)+1:8*(i)) = ones(1,8)*min(t1);
end
for i = 31:32
    masking(8*(i-1)+1:8*(i)) = ones(1,8)*min(t1);
    thr(8*(i-1)+1:8*(i)) = ones(1,8)*min(t1);
end

for i = 1:32
    SMR(i) = max(psd((i-1)*8+1:i*8)) ...
        - thr(i*8);
end

function i0 = ppv(k0)

if k0 <= 48
   i0 = k0;
elseif k0 <= 96
   i0 = floor((k0-48)/2) + 48;
else
   i0 = round((k0-96)/4) + 72;
end;
if i0 > 108
   i0 = 108;
end;


function le_vf = vf(dz, j, X)

if dz < -1
   le_vf = 17 * (dz + 1) - (0.4 * X(j) + 6);
elseif dz < 0
   le_vf = (0.4 * X(j) + 6) * dz;
elseif dz < 1
   le_vf = -17 * dz;
else
   le_vf = -(dz - 1) * (17 - 0.15 * X(j)) - 17;
end;
