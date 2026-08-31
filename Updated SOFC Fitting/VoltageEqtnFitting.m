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

figure(1)       % experimental voltage curves
plot(Current_600, Voltage_600, '')
hold on
plot(Current_700, Voltage_700, Current_800, Voltage_800)
plot(Current_900, Voltage_900, Current_1000, Voltage_1000)
hold off
title('Cell Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('600 C', '700 C', '800 C', '900 C', '1000 C')
xlim([-0.5,2.5])
ylim([0,1])

figure(2)       % experimental power curves
plot(i_600, Power_600, i_700, Power_700, i_800, Power_800)
hold on
plot(i_900, Power_900, i_1000, Power_1000)
hold off
title('Power Density Data')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600 C', '700 C', '800 C', '900 C', '1000 C')
xlim([-0.5,2.5])
ylim([0,0.8])


%% Curve Fitting: nonlin least-squares fit I-V curve for each Temperature

% Model: Voltage Equation for each temperature
    % j = current density (known input)
    % params = [a, Ri, j0, jL]
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density
Veqtn_600 = @(j, params) 1.06 - j.*params(2) - (8.314.*873)./(params(1).*2.*96485.34) .* (log(max(j./params(3), eps)) + (1 + params(1)).*log(max(params(4)./abs(params(4) - j), eps)));
Veqtn_700 = @(j, params) 1.06 - j.*params(2) - (8.314.*973)./(params(1).*2.*96485.34) .* (log(max(j./params(3), eps)) + (1 + params(1)).*log(max(params(4)./abs(params(4) - j), eps)));
Veqtn_800 = @(j, params) 1.06 - j.*params(2) - (8.314.*1073)./(params(1).*2.*96485.34) .* (log(max(j./params(3), eps)) + (1 + params(1)).*log(max(params(4)./abs(params(4) - j), eps)));
Veqtn_900 = @(j, params) 1.06 - j.*params(2) - (8.314.*1173)./(params(1).*2.*96485.34) .* (log(max(j./params(3), eps)) + (1 + params(1)).*log(max(params(4)./abs(params(4) - j), eps)));
Veqtn_1000 = @(j, params) 1.06 - j.*params(2) - (8.314.*1273)./(params(1).*2.*96485.34) .* (log(max(j./params(3), eps)) + (1 + params(1)).*log(max(params(4)./abs(params(4) - j), eps)));

% Set parameter conditions (true for all temperatures)
initials = [0.3 0.04 0.10 2.5];           % initial guesses
upper = [0.8 0.1 10 4];                 % upper bounds
lower_600 = [0.1 0.0001 0.0001 1.1];     % lower bounds
lower_700 = [0.1 0.0001 0.0001 1.4];     % lower bounds
lower_800 = [0.1 0.0001 0.0001 1.8];     % lower bounds
lower_900 = [0.1 0.0001 0.0001 1.99];     % lower bounds
lower_1000 = [0.1 0.0001 0.0001 2.2];     % lower bounds

% curve fit for each dataset
[parameters_600, residual_600] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper);
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower_700, upper);
[parameters_800, residual_800] = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower_800, upper);
[parameters_900, residual_900] = lsqcurvefit(Veqtn_900, initials, Current_900, Voltage_900, lower_900, upper);
[parameters_1000, residual_1000] = lsqcurvefit(Veqtn_1000, initials, Current_1000, Voltage_1000, lower_1000, upper);


% Voltage calculation based on parameters
V600 = Veqtn_600(parameters_600, Current_600);
V700 = Veqtn_700(parameters_700, Current_700);
V800 = Veqtn_800(parameters_800, Current_800);
V900 = Veqtn_900(parameters_900, Current_900);
V1000 = Veqtn_1000(parameters_1000, Current_1000);

% due to square root operation, some values will be imaginary - set to NaN
V700(V700~=real(V700)) = NaN;
V800(V800~=real(V800)) = NaN;

% Power calculation from calculated voltage
P600 = V600 .* Current_600;
P700 = V700 .* Current_700;
P800 = V800 .* Current_800;
P900 = V900 .* Current_900;
P1000 = V1000 .* Current_1000;


%% Format Outputs & Validation

% Output table
    % column vectors
Temperature = [600; 700; 800; 900; 1000];
a  = [parameters_600(1); parameters_700(1); parameters_800(1); parameters_900(1); parameters_1000(1)];
Ri = [parameters_600(2); parameters_700(2); parameters_800(2); parameters_900(2); parameters_1000(2)];
j0 = [parameters_600(3); parameters_700(3); parameters_800(3); parameters_900(3); parameters_1000(3)];
jL = [parameters_600(4); parameters_700(4); parameters_800(4); parameters_900(4); parameters_1000(4)];
Residual = [residual_600; residual_700; residual_800; residual_900; residual_1000];
    % create table
Outputs = table(Temperature, a, Ri, j0, jL, Residual);
    % display table
disp(Outputs)

% plot theoretical results
figure(3)   % Voltage
plot(Current_600, Voltage_600, 'o', Current_600, V600, '-k')
hold on
plot(Current_700, Voltage_700, 'diamond', Current_700, V700, '-k')
plot(Current_800, Voltage_800, '*', Current_800, V800, 'k-')
plot(Current_900, Voltage_900, 'square', Current_900, V900, 'k-')
plot(Current_800, Voltage_1000, '^', Current_1000, V1000, 'k-')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve -1000')

figure(4)   % Power
plot(Current_600, Power_600, 'o', Current_600, P600, '-k')
hold on
plot(i_700, Power_700, 'diamond', i_700, P700, '-k')
plot(i_800, Power_800, '*', i_800, P800, 'k-')
plot(i_900, Power_900, 'square', i_900, P900, 'k-')
plot(i_800, Power_1000, '^', i_1000, P1000, 'k-')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Power Density (W/cm^2)')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve -1000')