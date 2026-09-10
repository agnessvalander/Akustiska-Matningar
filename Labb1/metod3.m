
%% Metod 3 - intensitetsskanner
clear all, clc



P0 = 10^-12;     %[W]
I0 = 10^-12;     %[Wm^-2]

S_i = [0.8*0.7, ...
       0.6*0.7, ...
       0.8*0.7, ...
       0.6*0.7, ...
       0.8*0.6];
S = sum(S_i);    %[m^2]

LnI_i = [];


files = {
    'source_side1_new_ex.dat'
    'source_side2_new_ex.dat'
    'source_side3_new_ex.dat'
    'source_side4_new_ex.dat'
    'source_side5_new_ex.dat'
};



%% Tabell med 37 rader skapas här, kolumn 1 har frekvens och kolumn 2 har "Cross Power"


[header, spectra] = readMWLdaq_LV(files{1}, 'spectra');

frequency = spectra.sig_1_1_3OCT0(:,1);
crossPower = spectra.sig_1_1_3OCT0(:,2);

[header, spectra, rawdata] = readMWLdaq_LV(files{1}, 'all');

