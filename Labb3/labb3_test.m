%% Program för att testa referensdata inför labb 3
clear, close, clc
%% Definitioner 
c = 343; %Ljudhastigheten 
D0 = 0.175; % Avstånd från öppning till mätposition 1 [m] 

s_short = 0.07; % Avstånd mellan mätposition 1 och 2
s_long = 0.14; % Avstånd mellan mätposition 1' och 2 

sample_thicc = 0.40; % Tjockleken av absorbet [m], sätt till 0 för mätningar av tomt rör

data_folder = 'lab3_data'; 

%% Inläsning av data 

% Tomt rör 
empty.pos1 = readMWLdaq_LV(fullfile(data_folder,'empty_tube_pos1_ex.dat')); 
empty.pos1p = readMWLdaq_LV(fullfile(data_folder,'empty_tube_pos1p_ex.dat')); 
empty.pos2 = readMWLdaq_LV(fullfile(data_folder,'empty_tube_pos2_ex.dat')); 

% Med absorbent, 40mm tjocklek 
abs4.pos1 = readMWLdaq_LV(fullfile(data_folder,'abs4cm_tube_pos1_ex.dat')); 
abs4.pos1p = readMWLdaq_LV(fullfile(data_folder,'abs4cm_tube_pos1p_ex.dat'));
abs4.pos2 = readMWLdaq_LV(fullfile(data_folder,'abs4cm_tube_pos2_ex.dat'));