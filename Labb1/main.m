clear,close,clc; 
%% Läs in mätdata, hämta tersspektrum 

for i = 1:5

    filename = sprintf('source_side%d_ex.dat', i); %går igenom fil 1-5

    [header{i}, spectra{i}] = readMWLdaq_LV(filename,'spectra'); %spectra datastruktur som håller ljuddatan

    data{i} = spectra{i}.sig_1_1_3OCT0;

    f{i} = data{i}(:,1);    % alla frekvenser för denna mätning ligger i första kolumnen
    Lp{i} = data{i}(:,2);   % ljudtryck i andra kolumenen

end 
disp(Lp{1})
disp(Lp{2})

%% A-vägning (Ekvation L.7)

f_A = [100 125 160 200 250 315 400 500 630 800 ...
       1000 1250 1600 2000 2500 3150 4000 5000 ...
       6300 8000 10000];

A = [-19.1 -16.1 -13.4 -10.9 -8.6 -6.6 -4.8 -3.2 ...
     -1.9 -0.8 0 0.6 1.0 1.2 1.3 1.2 1.0 0.5 ...
     -0.1 -1.1 -2.5];

S_i = [2.66*1.70, ...
       2.33*1.7, ...
       2.66*1.7, ...
       2.33*1.7, ...
       2.66*2.33];

S = sum(S_i);

%[~,index] = min(abs(f{1} - 100)); % Hittar det index där vi är närmst 100 Hz

LpA_kalla = zeros(1,5); 

for i = 1:5

    Lp_valda = zeros(size(f_A));

    for k = 1:length(f_A)

        [~,index] = min(abs(f{i} - f_A(k)));

        Lp_valda(k) = Lp{i}(index);

    end
    % Applicera A-vägningen för varje tersband
    Lp_A_ters = Lp_valda + A; 

    % A-vägda ljudtrycksnivån 
    LpA_kalla(i) = 10*log10(sum(10.^(0.1*Lp_A_ters)));

end 


%% Areavägt A-vägt ljudtryck (Ekvation L.8)

LpA_kalla_total = 10*log10( ...
    sum(S_i .* 10.^(0.1*LpA_kalla)) / S);

disp('Areavägt A-vägt ljudtryck [dB(A)]:')
disp(LpA_kalla_total)


%% Plottar grafer och kontrollerar att inläsning har skett korrekt 

for i = 1:5

    figure
    semilogx(f{i},Lp{i});
    grid on 

    xlabel('Frekvens [Hz]')
    ylabel('Ljudtrycksnivå [dB]')
    title(sprintf('Source - side %d',i))

end 

%% Beräkna K1A (Ekvation L.9)

K1A = 