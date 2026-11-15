% Title: VoltageEqtnFitting_Chemistry.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 28 August 2026
% 
% % % Description: % % % 
% This file includes data digitized for the SOFC to fit the cell voltage 
% equation coefficients. All current datapoints are in units of Amps per 
% sq. centimeter, all voltage differences are in volts, and all power 
% datapoints are in Watts per sq. cm. This file does not split the data
% into training and validation sets, and uses a polynomial fit to fit the
% parameters for intermediary temepratures. For these reasons this file is
% not in use. It is provided for comparison, because this was my best
% original fit, and there was originally an argument for relaxed modelling
% practices (I just didn't really approve of it).

clc; clear;

%% Plot Data

load("VoltageFittingData_Islam2025.mat");     % load experimental dataset

figure(1)       % experimental voltage curves
yyaxis left
plot(Current_600, Voltage_600)
hold on
plot(Current_650, Voltage_650, Current_700, Voltage_700, Current_750, Voltage_750)
hold off
title('Cell Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0,1.2])

yyaxis right        % experimental power curves
plot(i_600, Power_600)
hold on
plot(i_650, Power_650, i_700, Power_700, i_750, Power_750)
hold off
title('Power Density Data')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '650', '700', '750')
xlim([0,8])
ylim([0,4])


%% BUILD MODELS %%
% Parameters = [E0, a, j0, jL]
% voltage equation based on chemistry losses
Veqtn_600 = @(params, j) params(1) ...
    + 8.314*(600+273)/(2*96485.34) * log(1/1.5 * sqrt(0.5*1/1.5)/1) ...
    - (8.314*(600+273)/(2*96485.34*params(2)) .* log((j+0.01)/params(3))) ...
    - (8.314*(600+273)/(2*96485.34) * (1 + 1/params(2)) * log(params(4)/(params(4) - j))) ...
    - j.*(3126*exp(-0.014*(600+273)));
Veqtn_650 = @(params, j) params(1) ...
    + 8.314*(650+273)/(2*96485.34) * log(1/1.5 * sqrt(0.5*1/1.5)/1) ...
    - (8.314*(650+273)/(2*96485.34*params(2)) .* log((j+0.01)/params(3))) ...
    - (8.314*(650+273)/(2*96485.34) * (1 + 1/params(2)) * log(params(4)/(params(4) - j))) ...
    - j.*(3126*exp(-0.014*(650+273)));
Veqtn_700 = @(params, j) params(1) ...
    + 8.314*(700+273)/(2*96485.34) * log(1/1.5 * sqrt(0.5*1/1.5)/1) ...
    - (8.314*(700+273)/(2*96485.34*params(2)) .* log((j+0.01)/params(3))) ...
    - (8.314*(700+273)/(2*96485.34) * (1 + 1/params(2)) * log(params(4)/(params(4) - j))) ...
    - j.*(3126*exp(-0.014*(700+273)));
Veqtn_750 = @(params, j) params(1) ...
    + 8.314*(750+273)/(2*96485.34) * log(1/1.5 * sqrt(0.5*1/1.5)/1) ...
    - (8.314*(750+273)/(2*96485.34*params(2)) .* log((j+0.01)/params(3))) ...
    - (8.314*(750+273)/(2*96485.34) * (1 + 1/params(2)) * log(params(4)/(params(4) - j))) ...
    - j.*(3126*exp(-0.014*(750+273)));

% initial guess, upper and lower bounds
initials = [1.06 0.5 0.04 0.1 4];           % initial guesses
lower_600 = [0.9  0.2 0 0  max(Current_600)+0.001];     % lower bounds 600
lower_650 = [0.9  0.2 0 0  max(Current_650)+0.001];     % lower bounds 650
lower_700 = [0.9  0.2 0 0  max(Current_700)+0.001];     % lower bounds 700
lower_750 = [0.9  0.2 0 0  max(Current_750)+0.001];     % lower bounds 750
upper     = [1.25 1   1 10 10];                         % upper bounds


[parameters_600, residual_600] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper);
[parameters_650, residual_650] = lsqcurvefit(Veqtn_650, initials, Current_650, Voltage_650, lower_650, upper);
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower_700, upper);
[parameters_750, residual_750] = lsqcurvefit(Veqtn_750, initials, Current_750, Voltage_750, lower_750, upper);

% Output table
    % column vectors
Temperature = [600; 650; 700; 750];
V0 = [parameters_600(1); parameters_650(1); parameters_700(1); parameters_750(1);];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_600(2); parameters_650(2); parameters_700(2); parameters_750(2);];
j0 = [parameters_600(3); parameters_650(3); parameters_700(3); parameters_750(3);];
jL = [parameters_600(4); parameters_650(4); parameters_700(4); parameters_750(4);];
    % create table
Outputs = table(Temperature, V0, a, j0, jL);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares\n')
disp(Outputs)