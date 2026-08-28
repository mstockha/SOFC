% Title: VoltageEqtnFitting.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 28 August 2026
% 
% % % Description: % % % 
% This file includes data digitized for the SOFC to fit the cell voltage 
% equation coefficients. All current datapoints are in units of Amps per 
% sq. centimeter, all voltage differences are in volts, and all power 
% datapoints are in Watts per sq. cm. Plots can be found at:



%% Plot Data

load("VoltageFittingData.mat");     % load experimental dataset

figure(1)       % experimental power and voltage curves
yyaxis left
plot(Current_700, Voltage_700, '*')
hold on
plot(Current_750, Voltage_750, 'o')
plot(Current_800, Voltage_800, 'diamond')
hold off
title('Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('V - 700 C', 'V - 800 C', 'V - 850 C')
xlim([0,3.5])
ylim([0,1.2])

yyaxis right
plot(i_700, Power_700, '*')
hold on
plot(i_750, Power_750, 'o')
plot(i_800, Power_800, 'diamond')
hold off
title('Power Density Data')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('V - 700 C', 'V - 800 C', 'V - 850 C', 'P - 700 C', 'P - 800 C', 'P - 850 C')
ylim([0,1.2])


%% Curve Fitting: nonlin least-squares fit I-V curve for each Temperature

% Model: Voltage Equation for each temperature
    % j = current density (known input)
    % params = [a, Ri, j0, jL]
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density
% Veqtn_700 = @(j, params) (1.06 - j.*params(2) - (8.314.*700)./(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j)))) - Voltage_700;
% Veqtn_750 = @(j, params) (1.06 - j.*params(2) - (8.314.*750)/(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j)))) - Voltage_750;
% Veqtn_800 = @(j, params) (1.06 - j.*params(2) - (8.314*800)/(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j)))) - Voltage_800;

Veqtn_700 = @(j, params) (1.06 - j.*params(2) - (8.314.*700)./(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j))));
Veqtn_750 = @(j, params) (1.06 - j.*params(2) - (8.314.*750)/(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j))));
Veqtn_800 = @(j, params) (1.06 - j.*params(2) - (8.314*800)/(params(1).*2.*96485.34) .* (log(j./params(3)) + (1 + params(1)).*log(params(4)./(params(4) - j))));

% Set parameter conditions (true for all temperatures)
initials = [0.3 0.04 0.10 2];           % initial guesses
upper = [0.8 0.1 10 4];                 % upper bounds
lower = [0.1 0.0001 0.0001 0.0001];     % lower bounds

% curve fit for each dataset
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower, upper);
[parameters_750, residual_750] = lsqcurvefit(Veqtn_750, initials, Current_750, Voltage_750, lower, upper);
[parameters_800, residual_800] = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower, upper);
% parameters_700 = lsqnonlin;
% parameters_750 = lsqcurvefit(Veqtn_750, initials, Current_750, Voltage_750, lower, upper);
% parameters_800 = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower, upper);


% Voltage calculation based on parameters
V700 = Veqtn_700(parameters_700, Current_700);
V750 = Veqtn_750(parameters_750, Current_750);
V800 = Veqtn_800(parameters_800, Current_800);

% due to square root operation, some values will be imaginary - set to NaN
V700(V700~=real(V700)) = NaN;
V750(V750~=real(V750)) = NaN;
V800(V800~=real(V800)) = NaN;

% Power calculation from calculated voltage
P700 = V700.*Current_700;
P750 = V750.*Current_750;
P800 = V800.*Current_800;


%% Format Outputs & Validation

% Output table
    % column vectors
Temperature = [700; 750; 800];
a  = [parameters_700(1); parameters_750(1); parameters_800(1)];
Ri = [parameters_700(2); parameters_750(2); parameters_800(2)];
j0 = [parameters_700(3); parameters_750(3); parameters_800(3)];
jL = [parameters_700(4); parameters_750(4); parameters_800(4)];
Residual = [residual_700; residual_750; residual_800];
    % create table
Outputs = table(Temperature, a, Ri, j0, jL, Residual);
    % display table
disp(Outputs)

% plot theoretical results
figure(2)   % Voltage
subplot(1,3,1) % 700 C
plot(Current_700, Voltage_700, '*', Current_700, V700, '-k')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')

subplot(1,3,2) % 750
plot(Current_750, Voltage_750, 'o', Current_750, V750, '-k')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')
title('Voltage Curve Fit Validation')

subplot(1,3,3) % 800
plot(Current_800, Voltage_800, 'diamond', Current_800, V800)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')


figure(3)   % Power
subplot(1,3,1) % 700
plot(i_700, Power_700, '*', Current_700, P700, '-k')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')

subplot(1,3,2) % 750
plot(i_750, Power_750, 'o', Current_750, P750, '-k')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')
title('Voltage Curve Fit Validation')

subplot(1,3,3) % 800
plot(i_800, Power_800, 'diamond', Current_800, P800)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data', 'Fitted Curve')