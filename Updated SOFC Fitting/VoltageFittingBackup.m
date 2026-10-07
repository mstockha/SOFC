% Title: VoltageEqtnFitting.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 28 August 2026
% 
% % % Description: % % % 
% This file includes data digitized for the SOFC to fit the cell voltage 
% equation coefficients. All current datapoints are in units of Amps per 
% sq. centimeter, all voltage differences are in volts, and all power 
% datapoints are in Watts per sq. cm. Plots can be found at:

clc; clear; 

%% Plot Data

load("VoltageFittingData.mat");     % load experimental dataset

figure(1)       % experimental voltage curves
yyaxis left
plot(Current_600, Voltage_600)
hold on
plot(Current_700, Voltage_700, Current_800, Voltage_800)
plot(Current_900, Voltage_900, Current_1000, Voltage_1000)
hold off
title('Cell Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
ylim([0,1.2])

yyaxis right        % experimental power curves
plot(i_600, Power_600, i_700, Power_700, i_800, Power_800)
hold on
plot(i_900, Power_900, i_1000, Power_1000)
hold off
title('Power Density Data')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '700', '800', '900', '1000', '600', '700', '800', '900', '1000')
xlim([0,3.5])
ylim([0,1.2])



%% Curve Fitting: nonlin least-squares fit I-V curve for each Temperature
 
% Model: Voltage Equation for each temperature
    % j = current density (known input)
    % params = [a, Ri, j0, jL]
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density
    
Veqtn_600 = @(params, j) 1.06 - (8.314.*873)./(params(1).*2.*96485.34) .* log(j./params(3)) - j.*params(2) - (8.314.*873)./(2.*96485.34) .* (1 + 1/params(1)) .* log(params(4)./(params(4) - j));
Veqtn_700 = @(params, j) 1.06 - (8.314.*973)./(params(1).*2.*96485.34) .* log(j./params(3)) - j.*params(2) - (8.314.*973)./(2.*96485.34) .* (1 + 1/params(1)) .* log(params(4)./(params(4) - j));
Veqtn_800 = @(params, j) 1.06 - (8.314.*1073)./(params(1).*2.*96485.34) .* log(j./params(3)) - j.*params(2) - (8.314.*1073)./(2.*96485.34) .* (1 + 1/params(1)) .* log(params(4)./(params(4) - j));
Veqtn_900 = @(params, j) 1.06 - (8.314.*1173)./(params(1).*2.*96485.34) .* log(j./params(3)) - j.*params(2) - (8.314.*1173)./(2.*96485.34) .* (1 + 1/params(1)) .* log(params(4)./(params(4) - j));
Veqtn_1000 = @(params, j) 1.06 - (8.314.*1273)./(params(1).*2.*96485.34) .* log(j./params(3)) - j.*params(2) - (8.314.*1273)./(2.*96485.34) .* (1 + 1/params(1)) .* log(params(4)./(params(4) - j));

% Set parameter conditions (true for all temperatures)
initials = [0.5 0.04 0.1 4];           % initial guesses
upper1 = [1 1 10 2];                 % upper bounds
upper2 = [1 1 10 4];                 % upper bounds
lower_600 = [0.2 0 0 1.001];     % lower bounds

% curve fit for each dataset
[parameters_600, residual_600] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper1);
lower_700 = [0.2 0 0 parameters_600(end)];     % lower bounds
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower_700, upper2);
lower_800 = [0.2 0 0 parameters_700(end)];     % lower bounds
[parameters_800, residual_800] = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower_800, upper2);
lower_900 = [0.2 0.0001 0 parameters_800(end)];     % lower bounds
[parameters_900, residual_900] = lsqcurvefit(Veqtn_900, initials, Current_900, Voltage_900, lower_900, upper2);
lower_1000 = [0.2 0.0001 0 parameters_900(end)];     % lower bounds
[parameters_1000, residual_1000] = lsqcurvefit(Veqtn_1000, initials, Current_1000, Voltage_1000, lower_1000, upper2);

% Voltage calculation based on parameters
V600 = Veqtn_600(parameters_600, Current_600);
V700 = Veqtn_700(parameters_700, Current_700);
V800 = Veqtn_800(parameters_800, Current_800);
V900 = Veqtn_900(parameters_900, Current_900);
V1000 = Veqtn_1000(parameters_1000, Current_1000);

V600_p = Veqtn_600(parameters_600, i_600);
V700_p = Veqtn_700(parameters_700, i_700);
V800_p = Veqtn_800(parameters_800, i_800);
V900_p = Veqtn_900(parameters_900, i_900);
V1000_p = Veqtn_1000(parameters_1000, i_1000);

% Power calculation from calculated voltage
P600 = V600_p .* i_600;
P700 = V700_p .* i_700;
P800 = V800_p .* i_800;
P900 = V900_p .* i_900;
P1000 = V1000_p .* i_1000;


%% Format Outputs & Validation
fprintf('\n\n')

% Actual vs predicted plot
figure(3)
title('Model Validation: Actual vs Predicted')
subplot(1,5,1)
plot(V600, Voltage_600, '.')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(V700, Voltage_700, '.')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(V800, Voltage_800, '.')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(V900, Voltage_900, '.')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 900 C')


subplot(1,5,5)
plot(V1000, Voltage_1000, '.')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 1000 C')


% Residual vs predicted
resid600 = Voltage_600 - V600;
resid700 = Voltage_700 - V700;
resid800 = Voltage_800 - V800;
resid900 = Voltage_900 - V900;
resid1000 = Voltage_1000 - V1000;

figure(4)
title('Model Validation: Residual vs Predicted')
subplot(1,5,1)
plot(V600, resid600, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual |V*_i - V_i|  (V)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(V700, resid700, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual |V*_i - V_i|  (V)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(V800, resid800, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual |V*_i - V_i|  (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(V900, resid900, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual |V*_i - V_i|  (V)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(V1000, resid1000, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual |V*_i - V_i|  (V)')
title('Temperature: 1000 C')


% RMSE and standard deviation calculation for each temperature
root600 = rmse(V600, Voltage_600); Sigma600 = std(Voltage_600);
root700 = rmse(V700, Voltage_700); Sigma700 = std(Voltage_700);
root800 = rmse(V800, Voltage_800); Sigma800 = std(Voltage_800);
root900 = rmse(V900, Voltage_900); Sigma900 = std(Voltage_900);
root1000 = rmse(V1000, Voltage_1000); Sigma1000 = std(Voltage_1000);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600 = root600 / Sigma600 * 100;
EvalRoot700 = root700 / Sigma700 * 100;
EvalRoot800 = root800 / Sigma800 * 100;
EvalRoot900 = root900 / Sigma900 * 100;
EvalRoot1000 = root1000 / Sigma1000 * 100;

% Output table
    % column vectors
Temperature = [600; 700; 800; 900; 1000];
a  = [parameters_600(1); parameters_700(1); parameters_800(1); parameters_900(1); parameters_1000(1)];
Ri = [parameters_600(2); parameters_700(2); parameters_800(2); parameters_900(2); parameters_1000(2)];
j0 = [parameters_600(3); parameters_700(3); parameters_800(3); parameters_900(3); parameters_1000(3)];
jL = [parameters_600(4); parameters_700(4); parameters_800(4); parameters_900(4); parameters_1000(4)];
    % create table
Outputs = table(Temperature, a, Ri, j0, jL);
    % display table
disp(Outputs)

% Output table
    % column vectors
Norm = [residual_600; residual_700; residual_800; residual_900; residual_1000];
RMSE = [root600; root700; root800; root900; root1000];
StandardDeviation = [Sigma600; Sigma700; Sigma800; Sigma900; Sigma1000];
PercentRMSE = [EvalRoot600; EvalRoot700; EvalRoot800; EvalRoot900; EvalRoot1000];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
disp(Outputs)