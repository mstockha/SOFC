% Title: VoltageEqtnFitting_Chemistry2.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 12 November 2026
% 

clc; clear;

%% Plot Data

load("VoltageFittingData_Islam2025.mat");     % load experimental dataset

figure(1)       % experimental voltage curves
yyaxis left
plot(Current_600, Voltage_600)
hold on
plot(Current_650, Voltage_650, Current_700, Voltage_700, Current_750, Voltage_750)
hold off
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0,1.2])

yyaxis right        % experimental power curves
plot(i_600, Power_600)
hold on
plot(i_650, Power_650, i_700, Power_700, i_750, Power_750)
hold off
title('Data from Islam, et al., 2025')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '650', '700', '750')
xlim([0,8])
ylim([0,4])


%% BUILD MODELS - Iron with YSZ %%
% Parameters = [E0, a, j0, jL]
% voltage equation based on chemistry losses
Veqtn_600_Fe1 = @(params,j) params(1) ...
    + (8.314.*(600+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(600+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.* (0.000275 / (9e5/(600+273) * exp(-1.4/(8.314*(600+273))))) ...
    + (8.314.*(600+273))./(2.*96485.34) .*(1+1/params(2)) .* log(params(4) ./ (params(4) - j)));

Veqtn_650_Fe1 = @(params,j) params(1) ...
    + (8.314.*(650+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(650+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.* (0.000275 / (9e5/(650+273) * exp(-1.4/(8.314*(650+273))))) ...
    + (8.314.*(650+273))./(2.*96485.34) .*(1+1/params(2)) .* log(params(4) ./ (params(4) - j)));

Veqtn_700_Fe1 = @(params,j) params(1) ...
    + (8.314.*(700+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(700+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.* (0.000275 / (9e5/(700+273) * exp(-1.4/(8.314*(700+273))))) ...
    + (8.314.*(700+273))./(2.*96485.34) .*(1+1/params(2)) .* log(params(4) ./ (params(4) - j)));

Veqtn_750_Fe1 = @(params,j) params(1) ...
    + (8.314.*(750+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(750+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.* (0.000275 / (9e5/(750+273) * exp(-1.4/(8.314*(750+273))))) ...
    + (8.314.*(750+273))./(2.*96485.34) .*(1+1/params(2)) .* log(params(4) ./ (params(4) - j)));

% initial guess, upper and lower bounds
initials = [1.1 0.5 0.1 4];           % initial guesses
lower_600 = [0.9  0.2 1e-6  max(i_600)+0.001];     % lower bounds 600
lower_650 = [0.9  0.2 1e-6  max(i_650)+0.001];     % lower bounds 650
lower_700 = [0.9  0.2 1e-6  max(i_700)+0.001];     % lower bounds 700
lower_750 = [0.9  0.2 1e-6  max(i_750)+0.001];     % lower bounds 750
upper     = [1.25 1   10 8];                         % upper bounds

[parameters_600, residual_600] = lsqcurvefit(Veqtn_600_Fe1, initials, Current_600, Voltage_600, lower_600, upper);
[parameters_650, residual_650] = lsqcurvefit(Veqtn_650_Fe1, initials, Current_650, Voltage_650, lower_650, upper);
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700_Fe1, initials, Current_700, Voltage_700, lower_700, upper);
[parameters_750, residual_750] = lsqcurvefit(Veqtn_750_Fe1, initials, Current_750, Voltage_750, lower_750, upper);

% Output table
    % column vectors
Temperature = [600; 650; 700; 750];
V0 = [parameters_600(1); parameters_650(1); parameters_700(1); parameters_750(1)];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_600(2); parameters_650(2); parameters_700(2); parameters_750(2)];
j0 = [parameters_600(3); parameters_650(3); parameters_700(3); parameters_750(3)];
jL = [parameters_600(4); parameters_650(4); parameters_700(4); parameters_750(4)];
residuals = [residual_600; residual_650; residual_700; residual_750];
    % create table
Outputs = table(Temperature, V0, a, j0, jL, residuals);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares - Fe\n')
disp(Outputs)

% anonymous function for general temperature (electrolyte = YSZ + Fe, P =
% 1atm)
Veqtn_Fe1 = @(params,j) params(1) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .* log(0.97*sqrt(0.21)) ...
    - ((8.314.*(params(5)+273))./(params(2).*2.*96485.34) .* log((j+0.01)./params(3)) ...
    + j.* (0.000275 / (9e5/(params(5)+273) * exp(-1.4/(8.314*(params(5)+273))))) ...
    + (8.314.*(params(5)+273))./(2.*96485.34) .*(1+1/params(2)) .* log(params(4) ./ (params(4) - j)));

% Goodness of Fit
    % set parameters
temps = Temperature + 273;
params600_Islam = [parameters_600, 600];
params650_Islam = [parameters_650, 650];
params700_Islam = [parameters_700, 700];
params750_Islam = [parameters_750, 750];

    % Experimental data collection
Volts600_Islam = Veqtn_Fe1(params600_Islam, Current_600); P600_Islam = Veqtn_Fe1(params600_Islam, i_600) .* i_600;
Volts650_Islam = Veqtn_Fe1(params650_Islam, Current_650); P650_Islam = Veqtn_Fe1(params650_Islam, i_650)  .* i_650;
Volts700_Islam = Veqtn_Fe1(params700_Islam, Current_700); P700_Islam = Veqtn_Fe1(params700_Islam, i_700)  .* i_700;
Volts750_Islam = Veqtn_Fe1(params750_Islam, Current_750); P750_Islam = Veqtn_Fe1(params750_Islam, i_750)  .* i_750;
    % find residuals
ResVolts600_Islam = Volts600_Islam - Voltage_600; ResP600_Islam = P600_Islam - Power_600;
ResVolts650_Islam = Volts650_Islam - Voltage_650; ResP650_Islam = P650_Islam - Power_650;
ResVolts700_Islam = Volts700_Islam - Voltage_700; ResP700_Islam = P700_Islam - Power_700;
ResVolts750_Islam = Volts750_Islam - Voltage_750; ResP750_Islam = P750_Islam - Power_750;

figure(2)
subplot(2,4,1)
plot(Voltage_600, Volts600_Islam, '*', Voltage_600, Voltage_600, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,2)
plot(Voltage_650, Volts650_Islam, '*', Voltage_650, Voltage_650, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,3)
plot(Voltage_700, Volts700_Islam, '*', Voltage_700, Voltage_700, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,4)
plot(Voltage_750, Volts750_Islam, '*', Voltage_750, Voltage_750, 'r-')
xlabel('Actual Voltage (V)')
ylabel('Predicted Voltage (V)')

subplot(2,4,5)
plot(Power_600, P600_Islam, '*', Power_600, Power_600, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,6)
plot(Power_650, P650_Islam, '*', Power_650, Power_650, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,7)
plot(Power_700, P700_Islam, '*', Power_700, Power_700, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

subplot(2,4,8)
plot(Power_750, P750_Islam, '*', Power_750, Power_750, 'r-')
xlabel('Actual Power (W/cm^2)')
ylabel('Predicted Power (W/cm^2)')

