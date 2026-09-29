%% Akustiska mätningar LAB 2 - Structural Loss Factor
% Theos och Agnes kod

clear
close all
clc

%% Kodstruktur

% Settings
% 1. Read input accelerance
% 2. Read transfer accelerances
% 3. Convert magnitude + phase to complex H
% 4. Calculate structural loss factor - power injection
% 5. Plot power injection result
% 6. Read reverberation data
% 7. Third-octave filtering
% 8. RMS averaging
% 9. Calculate T60
% 10. Calculate structural loss factor - reverberation
% 11. Plot reverberation result

%%

%Settings
% Assumed mass of one plate section
ms = 6.5/12;       % [kg]

% Folder
dataFolder = fullfile(fileparts(mfilename('fullpath')), ...
    'labb2_data', 'pim');

% Frequency range according to the lab instructions
f_min = 125;  % [Hz]
f_max = 5000; % [Hz]


%% 1. Read input accelerance Hii



%% Test file path

inputFile = fullfile(dataFolder, ...
    'ex3_input_accelerance_v201_60_6000hz_ex.dat');

[~, inputSpectra] = readMWLdaq_LV(inputFile, 'spectra');

fieldnames(inputSpectra)


%% 2. Extract 1/3-octave magnitude and phase

% Magnitude
Hii_mag_data = inputSpectra.sig_2_1_3OCT0;

% Phase
Hii_phase_data = inputSpectra.sig_4_P_1_3OCT0;

% Frequency
f = Hii_mag_data(:,1);

% Select frequency range 125-5000 Hz
freqMask = f >= f_min & f <= f_max;
f = f(freqMask);

% Magnitude
Hii_mag = Hii_mag_data(freqMask,2);

% Phase in degrees
Hii_phase_deg = Hii_phase_data(freqMask,2);


%% 3. Convert Hii from magnitude + phase to complex form

Hii_phase_rad = deg2rad(Hii_phase_deg);

Hii = Hii_mag .* exp(1j * Hii_phase_rad);




%% 5. Read transfer accelerances Hij

Hij = zeros(length(f),12);

for ii = 1:12

    % Construct filename
    filename = sprintf( ...
        'ex3_p%d_v201_60_6000hz_ex.dat', ii);

    filepath = fullfile(dataFolder, filename);

    % Read data
    [~, spectra] = readMWLdaq_LV(filepath, 'spectra');

    % Extract magnitude and phase
    Hij_mag_data = spectra.sig_2_1_3OCT0;
    Hij_phase_data = spectra.sig_4_P_1_3OCT0;

    Hij_mag = Hij_mag_data(:,2);
    Hij_phase_deg = Hij_phase_data(:,2);

    % Convert phase from degrees to radians
    Hij_phase_rad = deg2rad(Hij_phase_deg);

    % Convert magnitude + phase to complex transfer function
    Hij_complex = Hij_mag .* exp(1j * Hij_phase_rad);

    % Keep only 125-5000 Hz
    Hij(:,ii) = Hij_complex(freqMask);

end

%% 6. Sum of transfer accelerances
sumHij = sum(Hij, 2);
size(sumHij)

%% 7. Structural loss factor - power injection

%testar ny eta
eta = imag(Hii) ./ (ms .* sum(abs(Hij).^2, 2));



%% 8. Plot structural loss factor - power injection

% figure 
% semilogx(f, eta, 'o-')
% xlabel('Frequency [Hz]')
% ylabel('Structural loss factor \eta')
% title('Structural loss factor - Power Injection Method')
% grid on


figure 
semilogx(f, eta, 'o-')
xlabel('Frekvens [Hz]')
ylabel(' \eta')
title('PIM')
grid on

size(f)
size(Hii)
size(Hij)