%% LAB 3 - INVESTIGATION OF NUMBER OF AVERAGES
clear; close all; clc;
%% 1. SETTINGS

data_folder = 'test_averages';

f_min = 120;    % Lower frequency limit [Hz]
f_max = 1900;   % Upper frequency limit [Hz]

%% 2. READ MEASUREMENT DATA

[~, M10, ~] = readMWLdaq_LV( ...
    fullfile(data_folder,'empty_pos2_10aver.dat'));

[~, M30, ~] = readMWLdaq_LV( ...
    fullfile(data_folder,'empty_pos2_30aver.dat'));

[~, M60, ~] = readMWLdaq_LV( ...
    fullfile(data_folder,'empty_pos2_60aver.dat'));

[~, M120, ~] = readMWLdaq_LV( ...
    fullfile(data_folder,'empty_pos2_120aver.dat'));

%% 3. EXTRACT FREQUENCY AND MAGNITUDE

f10 = M10.sig_1_AMP0(:,1);
A10 = M10.sig_1_AMP0(:,2);

f30 = M30.sig_1_AMP0(:,1);
A30 = M30.sig_1_AMP0(:,2);

f60 = M60.sig_1_AMP0(:,1);
A60 = M60.sig_1_AMP0(:,2);

f120 = M120.sig_1_AMP0(:,1);
A120 = M120.sig_1_AMP0(:,2);

%% 4. SELECT FREQUENCY RANGE

idx = f120 >= f_min & f120 <= f_max;

f = f120(idx);
A120 = A120(idx);

% Check that all measurements have matching frequency vectors
assert(isequal(f10(idx), f), ...
    'Frequency vectors do not match for 10 averages.');

assert(isequal(f30(idx), f), ...
    'Frequency vectors do not match for 30 averages.');

assert(isequal(f60(idx), f), ...
    'Frequency vectors do not match for 60 averages.');

A10 = A10(idx);
A30 = A30(idx);
A60 = A60(idx);

%% 5. PLOT ALL FREQUENCY RESPONSES

figure;

semilogx(f, A10, 'LineWidth', 1);
hold on;
semilogx(f, A30, 'LineWidth', 1);
semilogx(f, A60, 'LineWidth', 1);
semilogx(f, A120, 'k--', 'LineWidth', 1.5);

grid on;
box on;

xlabel('Frequency [Hz]');
ylabel('Magnitude response |H|');
title('Comparison of different numbers of averages');

legend('10 averages', '30 averages', ...
       '60 averages', '120 averages', ...
       'Location', 'best');

xlim([f_min f_max]);

%% 6. COMPARE AGAINST 120 AVERAGES

% Difference in magnitude expressed in dB
diff10 = 20*log10(A10 ./ A120);
diff30 = 20*log10(A30 ./ A120);
diff60 = 20*log10(A60 ./ A120);

figure;

semilogx(f, diff10, 'LineWidth', 1);
hold on;
semilogx(f, diff30, 'LineWidth', 1);
semilogx(f, diff60, 'LineWidth', 1);

yline(0, 'k--');

grid on;
box on;

xlabel('Frequency [Hz]');
ylabel('Difference relative to 120 averages [dB]');
title('Deviation from 120 averages');

legend('10 averages', '30 averages', ...
       '60 averages', 'Location', 'best');

xlim([f_min f_max]);

%% 7. CALCULATE NUMERICAL DEVIATION

% Mean absolute deviation
MAD = [mean(abs(diff10)), ...
       mean(abs(diff30)), ...
       mean(abs(diff60))];

% Root mean square deviation
RMS = [sqrt(mean(diff10.^2)), ...
       sqrt(mean(diff30.^2)), ...
       sqrt(mean(diff60.^2))];

% Maximum absolute deviation
MAX = [max(abs(diff10)), ...
       max(abs(diff30)), ...
       max(abs(diff60))];

averages = [10; 30; 60];

Results = table(averages, MAD', RMS', MAX', ...
    'VariableNames', {'Averages', ...
    'MeanAbsDeviation_dB', ...
    'RMSDeviation_dB', ...
    'MaxDeviation_dB'});

disp('Comparison with 120 averages:');
disp(Results);
