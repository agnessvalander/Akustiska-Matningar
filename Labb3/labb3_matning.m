%% Program för faktiska mätningar från labb 3
clear, close, clc
%% Definitioner 

c = 343; %Ljudhastigheten 
D0 = 0.175; % Avstånd från öppning till mätposition 1 [m] 

s_short = 0.07; % Avstånd mellan mätposition 1 och 2
s_long = 0.14; % Avstånd mellan mätposition 1' och 2 

sample_thicc = 0.040; % Tjockleken av absorbent [m], sätt till 0 för mätningar av tomt rör

df_empty = 'empty_tube'; 
df_poly = 'polyester';
df_mineral = 'mineralull';
df_skum = 'skum'

%% Inläsning av data 

% Tomt rör 
[~, E1, ~] = readMWLdaq_LV(fullfile(df_empty,'empty_p1_2.dat')); 
[~, E1p, ~]  = readMWLdaq_LV(fullfile(df_empty,'empty_p1p_2.dat')); 
[~, E2, ~]  = readMWLdaq_LV(fullfile(df_empty,'empty_p2_2.dat')); 

% Med absorbent, 40mm tjocklek 
[~, A1, ~]  = readMWLdaq_LV(fullfile(df_poly,'poly_p1_1.dat')); 
[~, A1p, ~]  = readMWLdaq_LV(fullfile(df_poly,'poly_p1p_1.dat'));
[~, A2, ~ ] = readMWLdaq_LV(fullfile(df_poly,'poly_p2_1.dat'));

%% Beräkningar 

% För mätningar UTAN absorbent 
empty = analyse_tube(E1,E1p,E2,0,D0,s_short,s_long,c);

% För mätningar MED absorbent
absorber = analyse_tube(A1,A1p,A2,sample_thicc,D0,s_short,s_long,c);

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

legend('2-1','2-1p')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('Empty impedance tube')

figure(2) % Absorptionsfaktorn med absorbent 
semilogx(absorber.f, absorber.alphaShort,'r','LineWidth',1)
hold on
semilogx(absorber.f, absorber.alphaLong,'k','LineWidth',1)
grid on 

xlim([80 2000]);
ylim([-0.1 1.1]);

legend('2-1','2-1p')
xlabel('Frequency [Hz]')
ylabel('\alpha')
title('Impedance tube with absorber')

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