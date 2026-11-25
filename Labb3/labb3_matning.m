%% Program för faktiska mätningar från labb 3
close, clc
%% Definitioner 

c = 343; %Ljudhastigheten 
D0 = 0.175; % Avstånd från öppning till mätposition 1 [m] 

s_short = 0.07; % Avstånd mellan mätposition 1 och 2
s_long = 0.14; % Avstånd mellan mätposition 1' och 2 

sample_thicc = 0.040; % Tjockleken av absorbent [m], sätt till 0 för mätningar av tomt rör

df_empty = 'empty_tube'; 
df_poly = 'polyester';
df_mineral = 'mineralull';
df_skum = 'skum';

%% Inläsning av data 

% % Tomt rör 
% [~, E1, ~] = readMWLdaq_LV(fullfile(df_empty,'empty_p1_1.dat')); 
% [~, E1p, ~]  = readMWLdaq_LV(fullfile(df_empty,'empty_p1p_1.dat')); 
% [~, E2, ~]  = readMWLdaq_LV(fullfile(df_empty,'empty_p2_1.dat')); 
% 
% % Med polyester, 40mm tjocklek, INGEN luftspalt
% [~, A1, ~]  = readMWLdaq_LV(fullfile(df_poly,'poly_p1_1.dat')); 
% [~, A1p, ~]  = readMWLdaq_LV(fullfile(df_poly,'poly_p1p_1.dat'));
% [~, A2, ~ ] = readMWLdaq_LV(fullfile(df_poly,'poly_p2_1.dat'));
% % Med polyester, 40mm tjocklek, MED lufstpalt
% [~, A1_luft, ~]  = readMWLdaq_LV(fullfile(df_poly,'luft_poly_p1_1.dat')); 
% [~, A1p_luft, ~]  = readMWLdaq_LV(fullfile(df_poly,'luft_poly_p1p_1.dat'));
% [~, A2_luft, ~ ] = readMWLdaq_LV(fullfile(df_poly,'luft_poly_p2_1.dat'));
% 
% % Med mineralull, 40mm tjocklek, INGEN luftspalt
% [~, M1, ~] = readMWLdaq_LV(fullfile(df_mineral,'mineral_p1.dat'));
% [~, M1p, ~] = readMWLdaq_LV(fullfile(df_mineral,'mineral_p1p.dat'));
% [~, M2, ~] = readMWLdaq_LV(fullfile(df_mineral,'mineral_p2.dat'));
% % Med mineralull, 40mm tjockelk, MED luftspalt 
% [~, M1_luft, ~] = readMWLdaq_LV(fullfile(df_mineral,'luft_mineral_p1.dat'));
% [~, M1p_luft, ~] = readMWLdaq_LV(fullfile(df_mineral,'luft_mineral_p1p.dat'));
% [~, M2_luft, ~] = readMWLdaq_LV(fullfile(df_mineral,'luft_mineral_p2.dat'));
% 
% % Med skum, 40mm tjocklek, INGEN luftspalt
% [~, S1, ~] = readMWLdaq_LV(fullfile(df_skum,'skum_p1.dat'));
% [~, S1p, ~] = readMWLdaq_LV(fullfile(df_skum,'skum_p1p.dat'));
% [~, S2, ~] = readMWLdaq_LV(fullfile(df_skum,'skum_p2.dat'));
% % Med skum, 40mm tjocklek, MED luftspalt
% [~, S1_luft, ~] = readMWLdaq_LV(fullfile(df_skum,'luft_skum_p1.dat'));
% [~, S1p_luft, ~] = readMWLdaq_LV(fullfile(df_skum,'luft_skum_p1p.dat'));
% [~, S2_luft, ~] = readMWLdaq_LV(fullfile(df_skum,'luft_skum_p2.dat'));

%% Beräkningar 

% För mätningar UTAN absorbent 
empty = analyse_tube(E1,E1p,E2,0,D0,s_short,s_long,c);

% För mätningar MED absorbent och UTAN luftspalt
ployester = analyse_tube(A1,A1p,A2,sample_thicc,D0,s_short,s_long,c);
mineral = analyse_tube(M1,M1p,M2,sample_thicc,D0,s_short,s_long,c);
skum = analyse_tube(S1,S1p,S2,sample_thicc,D0,s_short,s_long,c); 

% För mätningar MED absorbent och MED luftspalt
ployester_luft = analyse_tube(A1_luft,A1p_luft,A2_luft,sample_thicc,D0,s_short,s_long,c);
mineral_luft = analyse_tube(M1_luft,M1p_luft,M2_luft,sample_thicc,D0,s_short,s_long,c);
skum_luft = analyse_tube(S1_luft,S1p_luft,S2_luft,sample_thicc,D0,s_short,s_long,c); 

%% Plottar 

% Giltiga frekvensområden enligt laborationsinstruktionen
range = empty.f >= 245 & empty.f <= 1900;

figure(1) % Absorptionsfaktorn utan absorbent
semilogx(empty.f, empty.alphaShort,'r')
hold on
semilogx(empty.f,empty.alphaLong,'k')
grid on

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of impedance tube')

figure(2) % Absorptionsfaktorn för polyester UTAN luftspalt
semilogx(ployester.f, ployester.alphaShort,'r','LineWidth',1)
hold on
semilogx(ployester.f, ployester.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of polyester')

figure(3) % Absorptionsfaktorn för polyester MED luftspalt
semilogx(ployester_luft.f, ployester_luft.alphaShort,'r','LineWidth',1)
hold on
semilogx(ployester_luft.f, ployester_luft.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of polyester with air gap')

figure(4) % Absorptionsfaktorn för mineralull UTAN luftspalt
semilogx(mineral.f, mineral.alphaShort,'r','LineWidth',1)
hold on
semilogx(mineral.f, mineral.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of mineral wool')

figure(5) % Absorptionsfaktorn för mineralull MED luftspalt
semilogx(mineral_luft.f, mineral_luft.alphaShort,'r','LineWidth',1)
hold on
semilogx(mineral_luft.f, mineral_luft.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of mineral wool with air gap')

figure(6) % Absorptionsfaktorn för skum UTAN luftspalt
semilogx(skum.f, skum.alphaShort,'r','LineWidth',1)
hold on
semilogx(skum.f, skum.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of foam')

figure(7) % Absorptionsfaktorn för skum MED luftspalt
semilogx(skum_luft.f, skum_luft.alphaShort,'r','LineWidth',1)
hold on
semilogx(skum_luft.f, skum_luft.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p','Location','north')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('\alpha of foam with air gap')

%% Transfer function 

% Magnitude & phase
f = E1.sig_1_AMP0(:,1);
H_mag = E1.sig_1_AMP0(:,2);
H_phase = E1.sig_2_Phi0(:,2);

figure(8);

subplot(1,2,1)

semilogx(f, H_mag, 'k', 'LineWidth', 1);

grid on;
xlim([120 1900]);

xlabel('Frequency [Hz]');
ylabel('|H|');
title('Transfer function magnitude');

subplot(1,2,2)

semilogx(f, H_phase, 'b', 'LineWidth', 1);

grid on;
xlim([120 1900]);

xlabel('Frequency [Hz]');
ylabel('Phase [degrees]');
title('Transfer function phase');

%% Lokal funktion 

function result = analyse_tube(H1data, H1pdata, H2data, sample, D0, s_short, s_long, c)

    f = H2data.sig_1_AMP0(:,1); % Frekvensvektor
    
    % Konverterar magnitude och fas till komplexa överföringsfunktioner
    H1 = H1data.sig_1_AMP0(:,2).* exp(1i .* H1data.sig_2_Phi0(:,2) * pi/180);
    H1p = H1pdata.sig_1_AMP0(:,2).* exp(1i .* H1pdata.sig_2_Phi0(:,2) * pi/180);
    H2 =  H2data.sig_1_AMP0(:,2).* exp(1i .* H2data.sig_2_Phi0(:,2) * pi/180);

    % Avstånd mellan absorbent och mikrofonpositioner 
    D = D0 - sample; 
    x_short = D + s_short; 
    x_long = D + s_long; 

    % === Reflektionskoefficienten ===

    % Vågtalet
    k = 2*pi*f/c; 

    % Korta mikrofonavståndet, 7cm
    H21_short = H2 ./ H1; 

    HI_short = exp(-1i .* k * s_short); 
    HR_short = exp(1i .* k * s_short); 

    r_short = ((H21_short - HI_short)./(HR_short - H21_short)) .* exp(2i .* k .* x_short);

    % Långa mikrofonavståndet, 14cm 
    H21_long = H2 ./ H1p; 

    HI_long = exp(-1i .* k .* s_long); 
    HR_long = exp(1i .* k .* s_long); 

    r_long = ((H21_long - HI_long)./(HR_long - H21_long)) .* exp(2i .* k .* x_long); 

    % === Absorptionsfaktor === 
    alpha_short = 1 - abs(r_short).^2;
    alpha_long = 1 - abs(r_long).^2; 

    % === Impedansen === 
    z_short = (1 + r_short) ./ (1 - r_short);
    z_long = (1 + r_long) ./ (1 - r_long); 

    % === Lagra resultaten === 
    result.f = f;

    result.rShort = r_short;
    result.rLong = r_long;

    result.alphaShort = alpha_short;
    result.alphaLong = alpha_long;

    result.zShort = z_short;
    result.zLong = z_long;

end 