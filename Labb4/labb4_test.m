% Parametrar 
s = 0.025;       % Distance between measurement points [m]
h = 0.002;       % Beam thickness [m]
rho = 7850;      % Steel density [kg/m^3]
epsilon = 0.01;  % Loss factor

EX = 2.1e11 * (1 + 1j*epsilon);
D = (EX*h^3)/12;