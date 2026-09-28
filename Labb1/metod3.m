
%% Metod 3 - intensitetsskanner
clear
clc


P0 = 10^-12;     %[W]
I0 = 10^-12;     %[Wm^-2]

S_i = [1.51*0.58, ...
       1.14*0.58, ...
       1.51*0.58, ...
       1.14*0.58, ...
       1.51*1.14];


files = {
    'side1_1.dat'
    'side2_1.dat'
    'side3_1.dat'
    'side4_1.dat'
    'side5_1.dat'
};

%% Vi råkade spara datan i smalband, så här nedan kan vara en bra plats för att göra om formatet till tersband



for i = 1: length(files)

    [header, spectra] = readMWLdaq_LV(files{i}, 'spectra');

    frequency = spectra.sig_1_1_3OCT0(:,1);
    L_nI = spectra.sig_1_1_3OCT0(:,2);
   
    I = I0 * 10.^(0.1 * L_nI);
    P_i(i,:) = I * S_i(i);  %matris med P

end

% Summera över P

P = sum(P_i, 1);

L_W = 10 * log10(P / P0); %14:31 är värden dB för frekvenserna mellan 100-5000 hz, spacern går inte längre.


%A-vägnings konstanter i tersband
A = [-19.1, -16.1, -13.4, -10.9, -8.6, -6.6, ...
     -4.8, -3.2, -1.9, -0.8, 0, 0.6, ...
      1.0,  1.2,  1.3,  1.2, 1.0, 0.5];

%A-vägda värden i tersband
L_W_A_bands = L_W(14:31) + A;

%Kombinera! Vi måste summera bidragen eftersom nivåer är logaritmiska (kan ej bara ta medelvärdet alltså)
L_WA = 10 * log10(sum(10.^(0.1 * L_W_A_bands)));



%% A-vägd intensitetsnivå för varje yta

for i = 1:length(files)

    [header, spectra] = readMWLdaq_LV(files{i}, 'spectra');

    L_nI = spectra.sig_1_1_3OCT0(:,2);

    % Tersband 100-5000 Hz
    L_nI_bands = L_nI(14:31);

    % A-vägning
    L_nI_A = L_nI_bands + A(:);

    % Summera de A-vägda tersbanden
    L_nI_A_surface(i) = 10 * log10(sum(10.^(0.1 * L_nI_A)));

end

L_nI_A_surface