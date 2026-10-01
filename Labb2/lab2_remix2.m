clear, close all, clc;
%% 

[a, b, c] = readMWLdaq_LV('p1_1.dat');  % read in the data
Fs = 16000;  % Sampling Frequency in S/s
at = 0.02;  % Rolling avergae window length in s (seconds)
aS =round(at * Fs);  % Rolling avergae window length in S (samples)

raw_data=c{1,2}(:,2);  % get the amplitude vector of the accelerometer
%  build up the octave filter bank, with octave filtering from 250Hz to
%  10kHz
octfilt=octaveFilterBank('1 octave',Fs,'FrequencyRange',[250 10000],...
    'FilterOrder', 12);
oct_data=octfilt(raw_data);  % Filter the data
clear raw_data;

% rolling mean average of absolute values implemented via digital filtering
% to get envelope function
b = (1 / aS) * ones(1, aS);
a = 1;
mf_data = filter(b, a, abs(oct_data));

% plot on 3. octave band
semilogy(mf_data(100 : end, 3))

