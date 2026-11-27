%% LAB 4 - Structure-borne sound transmission loss
% Symmetrical method / Single-side excitation
% Mobility measurements using laser vibrometer

clear;
clc;
close all;

%% 1. Settings

dataFolder = pwd;  % Folder containing the measurement files

% Beam parameters (steel)
s = 0.025;          % Distance between measurement points [m]
h = 0.002;          % Beam thickness [m]
rho = 7850;         % Density [kg/m^3]
epsilon = 0.01;     % Structural loss factor

EX = 2.1e11 * (1 + 1j*epsilon);  % Complex Young's modulus [Pa]
D = (EX*h^3)/12;                 % Complex bending stiffness

%% 2. Read measurement data

% File names for each measurement point
files = {
    'p1_100_2300hz_ex.dat', 'p1_2300_5000hz_ex.dat';
    'p2_100_2300hz_ex.dat', 'p2_2300_5000hz_ex.dat';
    'p3_100_2300hz_ex.dat', 'p3_2300_5000hz_ex.dat';
    'p4_100_2300hz_ex.dat', 'p4_2300_5000hz_ex.dat'
};

% Storage
H = cell(4,1);
f = cell(4,1);

for p = 1:4

    % Read both frequency ranges
    for band = 1:2

        filename = fullfile(dataFolder, files{p,band});

        [~, data] = readMWLdaq_LV(filename, 'spectra');

        % Extract amplitude and phase
        freq = data.sig_1_AMP0(:,1);
        amp = data.sig_1_AMP0(:,2);
        phase = data.sig_2_Phi0(:,2);

        % Build complex mobility
        H_band = amp .* exp(1j * phase * pi/180);

        if band == 1
            f_temp = freq;
            H_temp = H_band;
        else
            f_temp = [f_temp; freq];
            H_temp = [H_temp; H_band];
        end

    end

    % Sort data according to frequency
    [f_temp, idx] = sort(f_temp);
    H_temp = H_temp(idx);

    % Remove duplicate frequencies, if any
    [f{p}, ia] = unique(f_temp, 'stable');
    H{p} = H_temp(ia);

end

% Check that all four measurement points have the same frequency vector
f_ref = f{1};

for p = 2:4
    if length(H{p}) ~= length(f_ref) || ...
            any(abs(f_ref - f{p}) > 1e-6)

        error('Frequency vectors do not match between measurement points.');
    end
end

% Extract frequency vector
f = f_ref;

% Extract transfer functions
H1 = H{1};
H2 = H{2};
H3 = H{3};
H4 = H{4};

%% 3. Calculate bending wave numbers

k = sqrt(2*pi*f) .* (rho*h/D)^(1/4);

%% 4. Calculate wave components

pjks = exp(1j*k*s);
mjks = exp(-1j*k*s);
jsinks = 2*1j*sin(k*s);

% Waves on side A
Am = mjks .* (H1.*pjks - H2) ./ jsinks;
Ap = pjks .* (H2 - H1.*mjks) ./ jsinks;

% Waves on side B
Bm = mjks .* (H4.*pjks - H3) ./ jsinks;
Bp = pjks .* (H3 - H4.*mjks) ./ jsinks;

%% 5. Calculate reflection and transmission coefficients

denominator = Am.^2 - Bm.^2;

r = (Am.*Ap - Bm.*Bp) ./ denominator;
t = (Am.*Bp - Bm.*Ap) ./ denominator;

%% 6. Calculate transmission loss

TL = -10*log10(abs(t).^2);

%% 7. Plot transmission loss

figure;

semilogx(f, TL, 'r', 'LineWidth', 1);
grid on;

xlabel('Frequency [Hz]');
ylabel('Transmission loss [dB]');
title('Structure-borne sound transmission loss - Steel beam');

xlim([100 5000]);
ylim([-10 30]);

%% 8. Plot the two frequency ranges separately

figure;

subplot(1,2,1);
semilogx(f, TL, 'r', 'LineWidth', 1);
grid on;
xlim([100 2300]);
ylim([-10 30]);
xlabel('Frequency [Hz]');
ylabel('Transmission loss [dB]');
title('100-2300 Hz');

subplot(1,2,2);
semilogx(f, TL, 'r', 'LineWidth', 1);
grid on;
xlim([2300 5000]);
ylim([-10 30]);
xlabel('Frequency [Hz]');
ylabel('Transmission loss [dB]');
title('2300-5000 Hz');