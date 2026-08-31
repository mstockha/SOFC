function [min_cells, i, V, power] = SOFCsize(E,T,pH2,A)

%% Estimate Voltage Equation Values
% Model: Voltage Equation for each temperature
    % i = current density (known input)
    % params = [a, Ri, j0, jL]
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density

% cell voltage equation (cve) best fit coefficients
temp = [700,750,800];           % temperature [celsius]
a_set = [0.314316089366992 0.428130999067575 0.463210831501386];
j0_set = [0.0501096183073099 0.0366926976186371 0.0492195525169935];
jL_set = [2.32125351949934 2.92470041660807 3.32757120645683];

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
params_a = polyfit(temp, a_set, 2);     a = polyval(params_a, T);
params_j0 = polyfit(temp, j0_set, 2);   j0 = polyval(params_j0, T);
params_jL = polyfit(temp, jL_set, 2);   jL = polyval(params_jL, T);
Ri = 0.1;        % dRi/dt = 0 per curve fitting


%% Single Cell Sizing: Voltage Equation Analysis

% set constants for cell voltage equation
V0 = 1.06;             % Nernst voltage (V)
R = 8.314;              % universal gas constant (J/mol*K)
n = 2;                  % number of charges/electrons transferred
F = 96485.34;              % Faraday's constant (C/mol)

% set current density from 0 to limiting current density (A/cm^2)
i = 0:0.01:(jL - 0.01);   

% calculate voltage based on parameters (V)
V = V0 - i.*Ri - (R.*T)./(a.*n.*F) .* (log(i./j0) ...
    + (1 + a).*log(jL./abs(jL - i)));

% calculate cell power (W/cm^2)
power = i.*V;

% maximum available power density, according to voltage relation
pdens_max = max(power);


%% Determine minimum cell # from maximum power required

E_max = max(E);                     % max experimental power required (W)
min_cells = E_max/(pdens_max*A);    % cell # required @ each time point
min_cells = ceil(min_cells);        % round up to nearest whole number


%% Verify model - output i-V and i-P curves

load("VoltageFittingData.mat");     % load experimental dataset

figure(101) % I-V Curve
plot(i,V)
xlabel('Current Density (A/cm^2)')
ylabel('Voltage (V)')

figure(102) % I-P Curve
plot(i,power,"LineWidth", 2);
ylim([0 1.2]);
xlabel("Current Density (A/cm^2)",'FontSize',13)
ylabel("Power Density (W/cm^2)",'FontSize',13)

end