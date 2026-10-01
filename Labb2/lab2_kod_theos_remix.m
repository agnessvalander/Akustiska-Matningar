clear, close all, clc; 
%% Kodstruktur - Metod 1 - Power Injection Method 

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

%% Settings
% Assumed mass of one plate section
ms = 6.5/12;       % [kg]

% Folder
dataFolder = fullfile(fileparts(mfilename('fullpath')), 'labb2_data', 'pim');

% Frequency range according to the lab instructions
f_min = 125;  % [Hz]
f_max = 5000; % [Hz]

%% 1. Read input accelerance Hii
% Test file path

inputFile = fullfile(dataFolder, ...
    'ex3_input_accelerance_v201_60_6000hz_ex.dat');

[~, inputSpectra] = readMWLdaq_LV(inputFile, 'spectra');

%fieldnames(inputSpectra)

%% 2. Extract 1/3-octave magnitude and phase

% Magnitude
Hii_mag_data = inputSpectra.sig_2_1_3OCT0;

% Phase
Hii_phase_data = inputSpectra.sig_4_P_1_3OCT0;

% Frequency
f = Hii_mag_data(:,1);

% Magnitude
Hii_mag = Hii_mag_data(:,2);

% Phase in degrees
Hii_phase_deg = Hii_phase_data(:,2);

%% 3. Convert Hii from magnitude + phase to complex form

Hii_phase_rad = deg2rad(Hii_phase_deg);

Hii = Hii_mag .* exp(1j * Hii_phase_rad);

%% 4. Select frequency range 125-5000 Hz

freqMask = f >= 70 & f <= 5100;

f = f(freqMask);
Hii = Hii(freqMask);

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

%% 6. Sum all transfer accelerances

sumHij = sum(abs(Hij).^2, 2);

%% 7. Calculate structural loss factor

eta = imag(Hii)./(ms.*sumHij);

%% 8. Plot structural loss factor (eta)

figure
semilogx(f, eta, 'o-')
grid on
xlabel('Frequency [Hz]')
ylabel('\eta [-]')
title('Power injection method')

%% Metod 2 - Reverberation Method 

%% 9. Read reverberation data 

rmFolder = fullfile(fileparts(mfilename('fullpath')),'labb2_data', 'rm');

fileName = fullfile(rmFolder, 'p1_1.dat');
fileName2 = fullfile(rmFolder, 'p1_2.dat');
fileName3 = fullfile(rmFolder, 'p1_3.dat');

[~, ~, data] = readMWLdaq_LV(fileName, 'rawdata');
[~, ~, data2] = readMWLdaq_LV(fileName2, 'rawdata');
[~, ~, data3] = readMWLdaq_LV(fileName3, 'rawdata');

%% 10. Get acceleration data

Fs = 16000; % Sampling frequency 
raw_data = data{1,2}(:,2); 
raw_data2 = data2{1,2}(:,2);
raw_data3 = data3{1,2}(:,2);
t = (0:length(raw_data)-1)/Fs; % Tidsvektorn 

%% 11. Create third-octave filter bank

octfilt = octaveFilterBank('1/3 octave', Fs, ...
    'FrequencyRange', [125 5000], ...
    'FilterOrder', 12);

%% 12. Filter acceleration data

oct_data = octfilt(raw_data);
oct_data2 = octfilt(raw_data2);
oct_data3 = octfilt(raw_data3);
% size(oct_data) % Kontrollerar storleken av datan 
% size(oct_data2)
% size(oct_data3)

%% 13. Rolling average 

at = 0.02;          % Rolling average window length [s]
aS = round(at * Fs); % Rolling average window length [samples]
b = (1/aS) * ones(1, aS);
a = 1;
mf_data = filter(b, a, abs(oct_data));
mf_data2 = filter(b, a, abs(oct_data2));
mf_data3 = filter(b, a, abs(oct_data3));

figure

ii = 16;

y = mf_data(:,ii);
y = y(:);

y = y / max(y);

L = 20*log10(y);

plot(t,L)

grid on

xlabel('Time [s]')
ylabel('Level [dB]')

title('Decay curve - 3981 Hz, measurement 3')

%% 14. Plot third-octave band

figure
semilogy(t(100:end), mf_data(100:end,3))
grid on
xlabel('Time [s]')
ylabel('Amplitude')
title('Decay curve - third-octave band')

%% 15. Convert to dB

band = 3; 
y = mf_data(:,band); 
y = y/max(y); % Normalize curve 

L = 20*log10(y); % Convert to dB 

% Ensures that y, t and L all are column vectors, matlab was complaining...
y = y(:); 
t = t(:);
L = L(:);

% Plot of dB decay as a function of time 
figure
plot(t,L)
grid on
xlabel('Time [s]')
ylabel('Level [dB]')
title('Decay curve in dB')

%% 16. Find excitation

[~, peak_index] = max(y);
t_peak = t(peak_index);
fprintf('Excitation occurs at %.3f s\n: ',t_peak)

%% 17. Select decay region 

fitMask = t >= t_peak & ...
          L <= -6 & ...
          L >= -50;

%% 18. Linear curve fit 

p = polyfit(t(fitMask), L(fitMask), 1);
slope = p(1);
intercept = p(2);

%% 19. Plot decay and curve fit

figure
plot(t,L)
hold on
plot(t(fitMask), polyval(p,t(fitMask)),'LineWidth',2)
grid on
xlabel('Time [s]')
ylabel('Level [dB]')
title('Decay curve and linear fit')
legend('Decay','Linear fit')

%% 20. Calculate T60

T60 = -60 / slope;
fprintf('T60 = %.4f s\n', T60);

%% 21. Structural loss factor can now be calculated accordingly 

f_band = 198.4; 
eta = 2.2/(f_band*T60);

fprintf('Structural loss factor eta = %.5f\n', eta);

%% 22. Calculate T60 and eta for all third-octave bands

% octFilt = octaveFilter(1000, '1/3 octave');
% centerFrequencies = getANSICenterFrequencies(octFilt);
% f = centerFrequencies(15:30);

f = getCenterFrequencies(octfilt);
f = f(:);

% Inläsning 1
T60 = zeros(length(f),1);
eta = zeros(length(f),1);
slope = zeros(length(f),1);

% Inläsning 2
T60_2 = zeros(length(f),1);
eta_2 = zeros(length(f),1);
slope_2 = zeros(length(f),1);

% Inläsning 3
T60_3 = zeros(length(f),1);
eta_3 = zeros(length(f),1);
slope_3 = zeros(length(f),1);

for ii = 1:length(f)

    % Select third-octave band
    y = mf_data(:,ii);

    y = y(:);

    % Normalize to maximum amplitude
    y = y / max(y);

    % Convert to dB
    L = 20*log10(y);

    L = L(:);

    % Find excitation
    [~, peak_index] = max(y);

    t_peak = t(peak_index);

    % Select decay region
    fitMask = t >= t_peak & ...
              L <= -5 & ...
              L >= -50;

    % Linear curve fit
    p = polyfit(t(fitMask), L(fitMask), 1);

    slope(ii) = p(1);

    % Calculate T60
    T60(ii) = -60 / slope(ii);

    % Calculate structural loss factor
    eta(ii) = 2.2 / (f(ii) * T60(ii));

end

for ii = 1:length(f)

    % Select third-octave band
    y = mf_data2(:,ii);

    y = y(:);

    % Normalize to maximum amplitude
    y = y / max(y);

    % Convert to dB
    L = 20*log10(y);

    L = L(:);

    % Find excitation
    [~, peak_index] = max(y);

    t_peak = t(peak_index);

    % Select decay region
    fitMask = t >= t_peak & ...
              L <= -6 & ...
              L >= -50;

    % Linear curve fit
    p = polyfit(t(fitMask), L(fitMask), 1);

    slope_2(ii) = p(1);

    % Calculate T60
    T60_2(ii) = -60 / slope_2(ii);

    % Calculate structural loss factor
    eta_2(ii) = 2.2 / (f(ii) * T60_2(ii));

end

for ii = 1:length(f)

    % Select third-octave band
    y = mf_data3(:,ii);

    y = y(:);

    % Normalize to maximum amplitude
    y = y / max(y);

    % Convert to dB
    L = 20*log10(y);

    L = L(:);

    % Find excitation
    [~, peak_index] = max(y);

    t_peak = t(peak_index);

    % Select decay region
    fitMask = t >= t_peak & ...
              L <= -6 & ...
              L >= -50;

    % Linear curve fit
    p = polyfit(t(fitMask), L(fitMask), 1);

    slope_3(ii) = p(1);

    % Calculate T60
    T60_3(ii) = -60 / slope_3(ii);

    % Calculate structural loss factor
    eta_3(ii) = 2.2 / (f(ii) * T60_3(ii));

end


%% 22.1 Average results from the three measurements

T60_mean = mean([T60 T60_2 T60_3], 2);

eta_mean = 2.2 ./ (f .* T60_mean);

%% 23. Plot structural loss factor

figure
semilogx(f, eta_3, 'o-')
grid on
xlabel('Frequency [Hz]')
ylabel('\eta [-]')
title('Reverberation method')

