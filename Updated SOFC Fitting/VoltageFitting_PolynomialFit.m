% Title: VoltageEqtnFitting.m
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

load("VoltageFittingData2.mat");     % load experimental dataset

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
    % params = [V0, a, Ri, j0, jL]
    % V0 = thermonuetral/Nernst voltage
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density
    
Veqtn_600 = @(params, j) params(1) - (8.314.*873)./(params(2).*2.*96485.34) .* log(j./params(4)) - j.*params(3) - (8.314.*873)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j));
Veqtn_700 = @(params, j) params(1) - (8.314.*973)./(params(2).*2.*96485.34) .* log(j./params(4)) - j.*params(3) - (8.314.*973)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j));
Veqtn_800 = @(params, j) params(1) - (8.314.*1073)./(params(2).*2.*96485.34) .* log(j./params(4)) - j.*params(3) - (8.314.*1073)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j));
Veqtn_900 = @(params, j) params(1) - (8.314.*1173)./(params(2).*2.*96485.34) .* log(j./params(4)) - j.*params(3) - (8.314.*1173)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j));
Veqtn_1000 = @(params, j) params(1) - (8.314.*1273)./(params(2).*2.*96485.34) .* log(j./params(4)) - j.*params(3) - (8.314.*1273)./(2.*96485.34) .* (1 + 1/params(2)) .* log(params(5)./(params(5) - j));

% Set parameter conditions (true for all temperatures)
initials = [1.06 0.5 0.04 0.1 4];           % initial guesses
upper_600 = [1.25 1 1 10 2];                 % upper bounds
lower_600 = [1 0.2 0 0 1.001];     % lower bounds

% curve fit for each dataset
[parameters_600, residual_600] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper_600);
lower_700 = [1 0.2 0 0 parameters_600(end)];     % lower bounds
upper_700 = [parameters_600(1) 1 1 10 4];                 % upper bounds
[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700, Voltage_700, lower_700, upper_700);
lower_800 = [1 0.2 0 0 parameters_700(end)];     % lower bounds
upper_800 = [parameters_700(1) 1 1 10 4];                 % upper bounds
[parameters_800, residual_800] = lsqcurvefit(Veqtn_800, initials, Current_800, Voltage_800, lower_800, upper_800);
lower_900 = [1 0.2 0.0001 0 parameters_800(end)];     % lower bounds
upper_900 = [parameters_800(1) 1 1 10 4];                 % upper bounds
[parameters_900, residual_900] = lsqcurvefit(Veqtn_900, initials, Current_900, Voltage_900, lower_900, upper_900);
lower_1000 = [1 0.2 0.0001 0 parameters_900(end)];     % lower bounds
upper_1000 = [parameters_900(1) 1 1 10 4];   
[parameters_1000, residual_1000] = lsqcurvefit(Veqtn_1000, initials, Current_1000, Voltage_1000, lower_1000, upper_1000);

% Output table
    % column vectors
Temperature = [600; 700; 800; 900; 1000];
V0 = [parameters_600(1); parameters_700(1); parameters_800(1); parameters_900(1); parameters_1000(1)];
a  = [parameters_600(2); parameters_700(2); parameters_800(2); parameters_900(2); parameters_1000(2)];
Ri = [parameters_600(3); parameters_700(3); parameters_800(3); parameters_900(3); parameters_1000(3)];
j0 = [parameters_600(4); parameters_700(4); parameters_800(4); parameters_900(4); parameters_1000(4)];
jL = [parameters_600(5); parameters_700(5); parameters_800(5); parameters_900(5); parameters_1000(5)];
    % create table
Outputs = table(Temperature, V0, a, Ri, j0, jL);
    % display table
fprintf('\n\tParameter Table Based on Non-Linear Least Squares\n')
disp(Outputs)


%% Build Model
% local function for cell voltage equation
Veqtn = @(params,j) params(1) ...
    - (8.314.*params(6))./(params(2).*2.*96485.34) .* log(j./params(4)) ...
    - j.*params(3) - (8.314.*params(6))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(5)./(params(5) - j));
% params = [V0, a, Ri, j0, jL, T (Kelvin)]


% cell voltage equation (cve) best fit coefficients
temps = [873 973 1073 1173 1273];           % temperature [celsius]

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
paramsV0 = polyfit(temps, V0, 3); 
paramsRi = polyfit(temps, Ri, 2);   
paramsj0 = polyfit(temps, j0, 2);   
paramsjL = polyfit(temps, jL, 3);   
a = polyfit(temps, a, 3);        % da/dT = 0 per curve fitting
% params = [V0, a, Ri, j0, jL, T (Kelvin)]

%% Model: Training Data
    % 600 C
params600_V0 = polyval(paramsV0, temps(1));
params600_Ri = polyval(paramsRi, temps(1));
params600_j0 = polyval(paramsj0, temps(1));
params600_jL = polyval(paramsjL, temps(1));

CellParams600 = [params600_V0, 1, params600_Ri, params600_j0, params600_jL, temps(1)];

ModelVoltage600 = Veqtn(CellParams600, Current_600);
Vp600 = Veqtn(CellParams600, i_600);
ModelPower600 = Vp600 .* i_600;

    % 700 C
params700_V0 = polyval(paramsV0, temps(2));
params700_Ri = polyval(paramsRi, temps(2));
params700_j0 = polyval(paramsj0, temps(2));
params700_jL = polyval(paramsjL, temps(2));

CellParams700 = [params700_V0, 1, params700_Ri, params700_j0, params700_jL, temps(2)];

ModelVoltage700 = Veqtn(CellParams700, Current_700);
Vp700 = Veqtn(CellParams700, i_700);
ModelPower700 = Vp700 .* i_700;

    % 800 C
params800_V0 = polyval(paramsV0, temps(3));
params800_Ri = polyval(paramsRi, temps(3));
params800_j0 = polyval(paramsj0, temps(3));
params800_jL = polyval(paramsjL, temps(3));

CellParams800 = [params800_V0, 1, params800_Ri, params800_j0, params800_jL, temps(3)];

ModelVoltage800 = Veqtn(CellParams800, Current_800);
Vp800 = Veqtn(CellParams800, i_800);
ModelPower800 = Vp800 .* i_800;

    % 900 C
params900_V0 = polyval(paramsV0, temps(4));
params900_Ri = polyval(paramsRi, temps(4));
params900_j0 = polyval(paramsj0, temps(4));
params900_jL = polyval(paramsjL, temps(4));

CellParams900 = [params900_V0, 1, params900_Ri, params900_j0, params900_jL, temps(4)];

ModelVoltage900 = Veqtn(CellParams900, Current_900);
Vp900 = Veqtn(CellParams900, i_900);
ModelPower900 = Vp900 .* i_900;

    % 1000 C
params1000_V0 = polyval(paramsV0, temps(5));
params1000_Ri = polyval(paramsRi, temps(5));
params1000_j0 = polyval(paramsj0, temps(5));
params1000_jL = polyval(paramsjL, temps(5));

CellParams1000 = [params1000_V0, 1, params1000_Ri, params1000_j0, params1000_jL, temps(5)];

ModelVoltage1000 = Veqtn(CellParams1000, Current_1000);
Vp1000 = Veqtn(CellParams1000, i_1000);
ModelPower1000 = Vp1000 .* i_1000;


% plot theoretical results
figure(2)   % Voltage
subplot(1,2,1)
plot(Current_600, Voltage_600, 'o', Current_600, ModelVoltage600)
hold on
plot(Current_700, Voltage_700, 'diamond', Current_700, ModelVoltage700)
plot(Current_800, Voltage_800, '*', Current_800, ModelVoltage800)
plot(Current_900, Voltage_900, 'square', Current_900, ModelVoltage900) 
plot(Current_1000, Voltage_1000, '^', Current_1000, ModelVoltage1000)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
title('Polarization Curve Validation')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve - 1000')

subplot(1,2,2)  % Power
plot(i_600, Power_600, 'o', i_600, ModelPower600)
hold on
plot(i_700, Power_700, 'diamond', i_700, ModelPower700)
plot(i_800, Power_800, '*', i_800, ModelPower800)
plot(i_900, Power_900, 'square', i_900, ModelPower900)    
plot(i_1000, Power_1000, '^', i_1000, ModelPower1000)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Power Density (W/cm^2)')
title('Power Curve Validation')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve - 1000')


%% Model Fit Analysis - Voltage
x = linspace(0,1,100);

% Actual vs predicted plot
figure(3)
title('Model Validation: Actual vs Predicted - Voltage')
subplot(1,5,1)
plot(ModelVoltage600, Voltage_600, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 600 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,2)
plot(ModelVoltage700, Voltage_700, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 700 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,3)
plot(ModelVoltage800, Voltage_800, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 800 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,4)
plot(ModelVoltage900, Voltage_900, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 900 C')
xlim([0,1])
ylim([0,1])


subplot(1,5,5)
plot(ModelVoltage1000, Voltage_1000, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 1000 C')
xlim([0,1])
ylim([0,1])


% Residual vs predicted
resid600 = Voltage_600 - ModelVoltage600;
resid700 = Voltage_700 - ModelVoltage700;
resid800 = Voltage_800 - ModelVoltage800;
resid900 = Voltage_900 - ModelVoltage900;
resid1000 = Voltage_1000 - ModelVoltage1000;

figure(4)
title('Model Validation: Residual vs Predicted - Voltage')
subplot(1,5,1)
plot(ModelVoltage600, resid600, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual  (V)')
title('Temperature: 600 C')


subplot(1,5,2)
plot(ModelVoltage700, resid700, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 700 C')


subplot(1,5,3)
plot(ModelVoltage800, resid800, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelVoltage900, resid900, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelVoltage1000, resid1000, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 1000 C')

% RMSE and standard deviation calculation for each temperature
root600 = rmse(ModelVoltage600, Voltage_600); Sigma600 = std(Voltage_600);
root700 = rmse(ModelVoltage700, Voltage_700); Sigma700 = std(Voltage_700);
root800 = rmse(ModelVoltage800, Voltage_800); Sigma800 = std(Voltage_800);
root900 = rmse(ModelVoltage900, Voltage_900); Sigma900 = std(Voltage_900);
root1000 = rmse(ModelVoltage1000, Voltage_1000); Sigma1000 = std(Voltage_1000);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600 = root600 / Sigma600 * 100;
EvalRoot700 = root700 / Sigma700 * 100;
EvalRoot800 = root800 / Sigma800 * 100;
EvalRoot900 = root900 / Sigma900 * 100;
EvalRoot1000 = root1000 / Sigma1000 * 100;

% Output table
    % column vectors
Norm = [residual_600; residual_700; residual_800; residual_900; residual_1000];
RMSE = [root600; root700; root800; root900; root1000];
StandardDeviation = [Sigma600; Sigma700; Sigma800; Sigma900; Sigma1000];
PercentRMSE = [EvalRoot600; EvalRoot700; EvalRoot800; EvalRoot900; EvalRoot1000];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
fprintf('\n\tModel Fit Data - Voltage\n')
disp(Outputs)


%% Model Fit Analysis - Power
% Actual vs predicted plot
figure(5)
title('Model Validation: Actual vs Predicted - Power')
subplot(1,5,1)
plot(ModelPower600, Power_600, '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 600 C')
xlim([0,0.31])
ylim([0,0.31])

subplot(1,5,2)
plot(ModelPower700, Power_700, '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 700 C')
xlim([0,0.43])
ylim([0,0.43])

subplot(1,5,3)
plot(ModelPower800, Power_800, '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 800 C')
xlim([0,0.55])
ylim([0,0.55])

subplot(1,5,4)
plot(ModelPower900, Power_900, '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 900 C')
xlim([0,0.65])
ylim([0,0.65])


subplot(1,5,5)
plot(ModelPower1000, Power_1000, '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 1000 C')
xlim([0,0.7])
ylim([0,0.7])


% Residual vs predicted
residP600 = Power_600 - ModelPower600;
residP700 = Power_700 - ModelPower700;
residP800 = Power_800 - ModelPower800;
residP900 = Power_900 - ModelPower900;
residP1000 = Power_1000 - ModelPower1000;

figure(6)
title('Model Validation: Residual vs Predicted - Power')
subplot(1,5,1)
plot(ModelPower600, residP600, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual  (W/m^2)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelPower700, residP700, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelPower800, residP800, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelPower900, residP900, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelPower1000, residP1000, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 1000 C')

% RMSE and standard deviation calculation for each temperature
residual_600 = sum((Power_600 - ModelPower600).^2);
residual_700 = sum((Power_700 - ModelPower700).^2);
residual_800 = sum((Power_800 - ModelPower800).^2);
residual_900 = sum((Power_900 - ModelPower900).^2);
residual_1000 = sum((Power_1000 - ModelPower1000).^2);

root600 = rmse(ModelPower600, Power_600); Sigma600 = std(Power_600);
root700 = rmse(ModelPower700, Power_700); Sigma700 = std(Power_700);
root800 = rmse(ModelPower800, Power_800); Sigma800 = std(Power_800);
root900 = rmse(ModelPower900, Power_900); Sigma900 = std(Power_900);
root1000 = rmse(ModelPower1000, Power_1000); Sigma1000 = std(Power_1000);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600 = root600 / Sigma600 * 100;
EvalRoot700 = root700 / Sigma700 * 100;
EvalRoot800 = root800 / Sigma800 * 100;
EvalRoot900 = root900 / Sigma900 * 100;
EvalRoot1000 = root1000 / Sigma1000 * 100;

% Output table
    % column vectors
p2Norm = [residual_600; residual_700; residual_800; residual_900; residual_1000];
RMSE = [root600; root700; root800; root900; root1000];
StandardDeviation = [Sigma600; Sigma700; Sigma800; Sigma900; Sigma1000];
PercentRMSE = [EvalRoot600; EvalRoot700; EvalRoot800; EvalRoot900; EvalRoot1000];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
fprintf('\n\tModel Fit Data - Power\n')
disp(Outputs)