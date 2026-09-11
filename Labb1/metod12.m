clear,close,clc; 
%% Läs in mätdata för bakrundsljud, RSS och mätobjektet. 

for i = 1:5 % Mätobjekt

    filename = sprintf('source_side%d_ex.dat', i); % Går igenom fil 1-5

    [header{i}, spectra{i}] = readMWLdaq_LV(filename,'spectra'); % Spectra datastruktur som håller ljuddatan

    data{i} = spectra{i}.sig_1_1_3OCT0;

    f{i} = data{i}(:,1);    % Alla frekvenser för denna mätning ligger i första kolumnen
    Lp{i} = data{i}(:,2);   % Ljudtryck i andra kolumenen

end 

for i = 1:5 % Bakgrundsljud 

    filename = sprintf('background_side%d_ex.dat',i); % Går igenom fil 1-5

    [header{i}, spectra{i}] = readMWLdaq_LV(filename,'spectra');

    data_B{i} = spectra{i}.sig_1_1_3OCT0;

    f_B{i} = data_B{i}(:,1); % Alla frekvenser för denna mätning 
    Lp_B{i} = data_B{i}(:,2); % Uppmätt ljudtryck för respektive frekvens

end 

for i = 1:5 % RSS

    filename = sprintf('ref_source_side%d_ex.dat',i); % Går igenom fil 1-5

    [header{i},spectra{i}] = readMWLdaq_LV(filename,'spectra');

    data_RSS{i} = spectra{i}.sig_1_1_3OCT0;

    f_RSS{i} = data_RSS{i}(:,1); % Alla frekvenser från RSS-mätningen
    Lp_RSS{i} = data_RSS{i}(:,2); % Uppmätt ljudtryck för respektive frekvens

end 

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


LpA_kalla = zeros(1,5); 

for i = 1:5 % A-vägning för källan

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


LpA_bakgrund = zeros(1,5);

for i = 1:5 % A-vägning för bakgrundsljudet 

    Lp_valda_B = zeros(size(f_A));

    for k = 1:length(f_A)
        [~,index] = min(abs(f_B{i} - f_A(k)));
        Lp_valda_B(k) = Lp_B{i}(index);
    end 
    
    LpA_ters_B = Lp_valda_B + A; % Applicera A-vägningen för varje tersband
    LpA_bakgrund(i) = 10*log10(sum(10.^(0.1*LpA_ters_B))); % A-vägd ljudtrycksnivå
end 


%% Areavägt A-vägt ljudtryck (Ekvation L.8)

LpA_kalla_total = 10*log10(sum(S_i .* 10.^(0.1*LpA_kalla)) / S); % För källan

LpA_bakgrund_total = 10*log10(sum(S_i .* 10.^(0.1*LpA_bakgrund)) / S); % För bakgrundsljudet

delta_LA = LpA_kalla_total - LpA_bakgrund_total; % Skillnaden mellan källnivå och bakgrundsnivå

% disp('Skillnaden mellan källa och bakgrund [dB(A)]: ')
% disp(delta_LA)

%% Beräkna K1A, bakgrundskorrigeringen (L.9)

K_1A = -10*log10(1 - 10^(-0.1*delta_LA));
% disp('Bakgrundskorrigering K1A [dB]:')
% disp(K_1A)

%% Beräkning av ljudeffektnivå (L.11)

S_0 = 1; % Referensarean är 1 [m^2] enligt instruktion 

L_WA = LpA_kalla_total - K_1A + 10*log10(S/S_0);

disp('A-vägd Ljudeffektnivå för källan vid metod 1 [dB(A)]:')
disp(L_WA)

%% Metod 2 - Bakgrundskorrigering

% Av källan 
Lp_korrigerad = zeros(5,length(f{1})); 
K1 = zeros(5, length(f{1}));

for i = 1:5

    for k = 1:length(f{1})

        delta_LP = Lp{i}(k) - Lp_B{i}(k);

        if delta_LP > 0

            K1(i,k) = -10*log10(1 - 10^(-0.1*delta_LP));

            Lp_korrigerad(i,k) = Lp{i}(k) - K1(i,k);

        else

            K1(i,k) = NaN;
            Lp_korrigerad(i,k) = NaN;

        end

    end

end

% Av RSS
fan_RSS = f_RSS{1};

Lp_RSS_korrigerad = zeros(5,length(fan_RSS));
K1_RSS = zeros(5,length(fan_RSS));

for i = 1:5

    for k = 1:length(fan_RSS)

        delta_LP_RSS = Lp_RSS{i}(k) - Lp_B{i}(k);

        if delta_LP_RSS > 0

            K1_RSS(i,k) = -10*log10(1 - 10^(-0.1*delta_LP_RSS));

            Lp_RSS_korrigerad(i,k) = Lp_RSS{i}(k) - K1_RSS(i,k);

        else

            K1_RSS(i,k) = NaN;
            Lp_RSS_korrigerad(i,k) = NaN;

        end

    end

end

%% Medelvärdet över alla mikrofonpositioner 

Lp_ST = 10*log10(mean(10.^(0.1*Lp_korrigerad),1)); 

Lp_RSS_m = 10*log10(mean(10.^(0.1*Lp_RSS_korrigerad),1));

% Från tabell 1 
LW_RSS_table = [71.7 73.6 74.4 75.2 76.1 75.9 76.4 76.3 ...
                77.2 79.1 80.0 81.5 81.8 80.7 78.8 78.6 ...
                78.0 77.2 76.4 74.2 72.5];

% Söker de ljudtrycksnivåerna som finns mellan 100-10000 Hz 
Lp_ST_RSSbands = zeros(size(f_A));
Lp_RSS_RSSbands = zeros(size(f_A));

for k = 1:length(f_A)

    [~, index] = min(abs(f{1} - f_A(k)));

    Lp_ST_RSSbands(k) = Lp_ST(index);
    Lp_RSS_RSSbands(k) = Lp_RSS_m(index);

end

% Beräkna ljudeffektnivån för testkällan 
LW_ST = LW_RSS_table - Lp_RSS_RSSbands + Lp_ST_RSSbands;

% disp('Ljudeffektnivå för testkällan per tersband:')
% disp(LW_ST)

% A-vägning för ljudeffektnivån 
LW_A_ters = LW_ST + A; 

LWA_ST = 10*log10(sum(10.^(0.1*LW_A_ters)));

disp('A-vägd ljudeffektnivå för testkällan vid metod 2 [dB(A)]:')
disp(LWA_ST)

%% Plottar grafer och kontrollerar att inläsning har skett korrekt 

% for i = 1:5
% 
%     figure
%     semilogx(f{i},Lp{i});
%     grid on 
% 
%     xlabel('Frekvens [Hz]')
%     ylabel('Ljudtrycksnivå [dB]')
%     title(sprintf('Source - side %d',i))
% 
% end 
