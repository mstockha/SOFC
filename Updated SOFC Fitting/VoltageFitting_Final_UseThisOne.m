% Title: VoltageEqtnFitting.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 28 August 2026
% 
% % % Description: % % % 
% This file includes data digitized for the SOFC to fit the cell voltage 
% equation coefficients. All current datapoints are in units of Amps per 
% sq. centimeter, all voltage differences are in volts, and all power 
% datapoints are in Watts per sq. cm. This is the final fitting file. 
clc; clear;

%% Plot Data

load("VoltageFittingDataAscend.mat");     % load experimental dataset

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
plot(i_900, Power_900,  i_1000, Power_1000)
hold off
title('Power Density Data')
xlabel('Current Density (A/cm^2)')
ylabel('Power Density (W/cm^2)')
legend('600', '700', '800', '900', '1000', '600', '700', '800', '900', '1000')
xlim([0,3.5])
ylim([0,1.2])


%% Voltage Curve Fitting: nonlin least-squares fit I-V curve for each Temperature
 
% Model: Voltage Equation for each temperature
    % j = current density (known input)
    % params = [V0, a, Ri, j0, jL]
    % V0 = thermonuetral/Nernst voltage params(1)
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
upper_600 = [1.25 1 1 10 1.4];                 % upper bounds
lower_600 = [1 0.2 0 0 1.001];     % lower bounds

% curve fit for each dataset
[parameters_600v, residual_600v] = lsqcurvefit(Veqtn_600, initials, ExpCurrent600v_Train, ExpVoltage600v_Train, lower_600, upper_600);
lower_700 = [1 0.2 0 0 parameters_600v(end)];     % lower bounds
upper_700 = [parameters_600v(1) 1 1 10 4];                 % upper bounds
[parameters_700v, residual_700v] = lsqcurvefit(Veqtn_700, initials, ExpCurrent700v_Train, ExpVoltage700v_Train, lower_700, upper_700);
lower_800 = [1 0.2 0 0 parameters_700v(end)];     % lower bounds
upper_800 = [parameters_700v(1) 1 1 10 4];                 % upper bounds
[parameters_800v, residual_800v] = lsqcurvefit(Veqtn_800, initials, ExpCurrent800v_Train, ExpVoltage800v_Train, lower_800, upper_800);
lower_900 = [1 0.2 0.0001 0 parameters_800v(end)];     % lower bounds
upper_900 = [parameters_800v(1) 1 1 10 4];                 % upper bounds
[parameters_900v, residual_900v] = lsqcurvefit(Veqtn_900, initials, ExpCurrent900v_Train, ExpVoltage900v_Train, lower_900, upper_900);
lower_1000 = [1 0.2 0.0001 0 parameters_900v(end)];     % lower bounds
upper_1000 = [parameters_900v(1) 1 1 10 4];   
[parameters_1000v, residual_1000v] = lsqcurvefit(Veqtn_1000, initials, ExpCurrent1000v_Train, ExpVoltage1000v_Train, lower_1000, upper_1000);

% Output table
    % column vectors
Temperature = [600; 700; 800; 900; 1000];
V0 = [parameters_600v(1); parameters_700v(1); parameters_800v(1); parameters_900v(1); parameters_1000v(1)];
% V0 = [0.95; 0.95; 0.95; 0.95; 0.95];
a  = [parameters_600v(2); parameters_700v(2); parameters_800v(2); parameters_900v(2); parameters_1000v(2)];
Ri = [parameters_600v(3); parameters_700v(3); parameters_800v(3); parameters_900v(3); parameters_1000v(3)];
j0 = [parameters_600v(4); parameters_700v(4); parameters_800v(4); parameters_900v(4); parameters_1000v(4)];
jL = [parameters_600v(5); parameters_700v(5); parameters_800v(5); parameters_900v(5); parameters_1000v(5)];
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

temps = Temperature + 273;

CellParams600 = VoltageFit(temps(1), V0, a, Ri, j0, jL, temps);
CellParams700 = VoltageFit(temps(2), V0, a, Ri, j0, jL, temps);
CellParams800 = VoltageFit(temps(3), V0, a, Ri, j0, jL, temps);
CellParams900 = VoltageFit(temps(4), V0, a, Ri, j0, jL, temps);
CellParams1000 = VoltageFit(temps(5), V0, a, Ri, j0, jL, temps);


%% Training Data Model
    % 600
    % calculate voltage and power based on parameters
ModelVoltage600_Train = Veqtn(CellParams600, ExpCurrent600v_Train);
Vp600_Train = Veqtn(CellParams600, ExpCurrent600p_Train);
ModelPower600_Train = Vp600_Train .* ExpCurrent600p_Train;

    % cut power values after maximum
[Pmax600, kMax600] = max(ModelPower600_Train);
        % loop to remove values
k = length(ModelPower600_Train) - kMax600;
for count = length(ModelPower600_Train):-1:1
    if count > kMax600
        ModelPower600_Train(count) = [];
        % ExpCurrent600p_Train(count) = [];
    end
end

    % 700
    % calculate voltage based on parameters (V)
ModelVoltage700_Train = Veqtn(CellParams700, ExpCurrent700v_Train);
Vp700_Train = Veqtn(CellParams700, ExpCurrent700p_Train);
ModelPower700_Train = Vp700_Train .* ExpCurrent700p_Train;

    % cut power values after maximum
[Pmax700, kMax700] = max(ModelPower700_Train);
        % loop to remove values
k = length(ModelPower700_Train) - kMax700;
for count = length(ModelPower700_Train):-1:1
    if count > kMax700
        ModelPower700_Train(count) = [];
        % ExpCurrent700p_Train(count) = [];
    end
end

    % 800
    % calculate voltage based on parameters (V)
ModelVoltage800_Train = Veqtn(CellParams800, ExpCurrent800v_Train);
Vp800_Train = Veqtn(CellParams800, ExpCurrent800p_Train);
ModelPower800_Train = Vp800_Train .* ExpCurrent800p_Train;

    % cut power values after maximum
[Pmax800, kMax800] = max(ModelPower800_Train);
        % loop to remove values
k = length(ModelPower800_Train) - kMax800;
for count = length(ModelPower800_Train):-1:1
    if count > kMax800
        ModelPower800_Train(count) = [];
        % ExpCurrent800p_Train(count) = [];
    end
end

    % 900
    % calculate voltage based on parameters (V)
ModelVoltage900_Train = Veqtn(CellParams900, ExpCurrent900v_Train);
Vp900_Train = Veqtn(CellParams900, ExpCurrent900p_Train);
ModelPower900_Train = Vp900_Train .* ExpCurrent900p_Train;

    % cut power values after maximum
[Pmax900, kMax900] = max(ModelPower900_Train);
        % loop to remove values
k = length(ModelPower900_Train) - kMax900;
for count = length(ModelPower900_Train):-1:1
    if count > kMax900
        ModelPower900_Train(count) = [];
        % ExpCurrent900p_Train(count) = [];
    end
end

    % 1000
    % calculate voltage based on parameters (V)
ModelVoltage1000_Train = Veqtn(CellParams1000, ExpCurrent1000v_Train);
Vp1000_Train = Veqtn(CellParams1000, ExpCurrent1000p_Train);
ModelPower1000_Train = Vp1000_Train .* ExpCurrent1000p_Train;

    % cut power values after maximum
[Pmax1000, kMax1000] = max(ModelPower1000_Train);
        % loop to remove values
k = length(ModelPower1000_Train) - kMax1000;
for count = length(ModelPower1000_Train):-1:1
    if count > kMax1000
        ModelPower1000_Train(count) = [];
        % ExpCurrent1000p_Train(count) = [];
    end
end


%% Training Data Fit Analysis - Voltage
x = linspace(0,1,50);   % x = y plot vector
% Actual vs predicted plot
figure(2)
title('Training Data Validation: Actual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Train, ExpVoltage600v_Train, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 600 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,2)
plot(ModelVoltage700_Train, ExpVoltage700v_Train, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 700 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,3)
plot(ModelVoltage800_Train, ExpVoltage800v_Train, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 800 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,4)
plot(ModelVoltage900_Train, ExpVoltage900v_Train, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 900 C')
xlim([0,1])
ylim([0,1])


subplot(1,5,5)
plot(ModelVoltage1000_Train, ExpVoltage1000v_Train, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 1000 C')
xlim([0,1])
ylim([0,1])


% Residual vs predicted
resid600_Train = ExpVoltage600v_Train - ModelVoltage600_Train;
resid700_Train = ExpVoltage700v_Train - ModelVoltage700_Train;
resid800_Train = ExpVoltage800v_Train - ModelVoltage800_Train;
resid900_Train = ExpVoltage900v_Train - ModelVoltage900_Train;
resid1000_Train = ExpVoltage1000v_Train - ModelVoltage1000_Train;

figure(3)
title('Model Training Data Validation: Residual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Train, resid600_Train, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual  (V)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelVoltage700_Train, resid700_Train, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelVoltage800_Train, resid800_Train, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelVoltage900_Train, resid900_Train, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelVoltage1000_Train, resid1000_Train, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 1000 C')

% residuals (p2 norm)
Norm = [residual_600v; residual_700v; residual_800v; residual_900v; residual_1000v];
% RMSE and standard deviation calculation for each temperature
root600_Train = rmse(ModelVoltage600_Train, ExpVoltage600v_Train); Sigma600_Train = std(ExpVoltage600v_Train);
root700_Train = rmse(ModelVoltage700_Train, ExpVoltage700v_Train); Sigma700_Train = std(ExpVoltage700v_Train);
root800_Train = rmse(ModelVoltage800_Train, ExpVoltage800v_Train); Sigma800_Train = std(ExpVoltage800v_Train);
root900_Train = rmse(ModelVoltage900_Train, ExpVoltage900v_Train); Sigma900_Train = std(ExpVoltage900v_Train);
root1000_Train = rmse(ModelVoltage1000_Train, ExpVoltage1000v_Train); Sigma1000_Train = std(ExpVoltage1000v_Train);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600_Train = root600_Train / Sigma600_Train * 100;
EvalRoot700_Train = root700_Train / Sigma700_Train * 100;
EvalRoot800_Train = root800_Train / Sigma800_Train * 100;
EvalRoot900_Train = root900_Train / Sigma900_Train * 100;
EvalRoot1000_Train = root1000_Train / Sigma1000_Train * 100;

% Output table
    % column vectors
RMSE = [root600_Train; root700_Train; root800_Train; root900_Train; root1000_Train];
StandardDeviation = [Sigma600_Train; Sigma700_Train; Sigma800_Train; Sigma900_Train; Sigma1000_Train];
PercentRMSE = [EvalRoot600_Train; EvalRoot700_Train; EvalRoot800_Train; EvalRoot900_Train; EvalRoot1000_Train];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
fprintf('\n\tModel Fit, Training Data - Voltage\n')
disp(Outputs)



%% Training Data Model Fit Analysis - Power
% Actual vs predicted plot
figure(4)
title('Model Validation: Actual vs Predicted - Power, Training')
subplot(1,5,1)
plot(ModelPower600_Train, ExpPower600p_Train(1:length(ModelPower600_Train)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 600 C')
xlim([0,0.31])
ylim([0,0.31])

subplot(1,5,2)
plot(ModelPower700_Train, ExpPower700p_Train(1:length(ModelPower700_Train)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 700 C')
xlim([0,0.43])
ylim([0,0.43])

subplot(1,5,3)
plot(ModelPower800_Train, ExpPower800p_Train(1:length(ModelPower800_Train)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 800 C')
xlim([0,0.55])
ylim([0,0.55])

subplot(1,5,4)
plot(ModelPower900_Train, ExpPower900p_Train(1:length(ModelPower900_Train)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 900 C')
xlim([0,0.65])
ylim([0,0.65])


subplot(1,5,5)
plot(ModelPower1000_Train, ExpPower1000p_Train(1:length(ModelPower1000_Train)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 1000 C')
xlim([0,0.7])
ylim([0,0.7])


% Residual vs predicted
residP600 = ExpPower600p_Train(1:length(ModelPower600_Train)) - ModelPower600_Train;
residP700 = ExpPower700p_Train(1:length(ModelPower700_Train)) - ModelPower700_Train;
residP800 = ExpPower800p_Train(1:length(ModelPower800_Train)) - ModelPower800_Train;
residP900 = ExpPower900p_Train(1:length(ModelPower900_Train)) - ModelPower900_Train;
residP1000 = ExpPower1000p_Train(1:length(ModelPower1000_Train)) - ModelPower1000_Train;

figure(5)
title('Model Validation: Residual vs Predicted - Power, Training')
subplot(1,5,1)
plot(ModelPower600_Train, residP600, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual  (W/m^2)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelPower700_Train, residP700, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelPower800_Train, residP800, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelPower900_Train, residP900, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelPower1000_Train, residP1000, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 1000 C')

% RMSE and standard deviation calculation for each temperature
residual_600 = sum(residP600.^2);
residual_700 = sum(residP700.^2);
residual_800 = sum(residP800.^2);
residual_900 = sum(residP900.^2);
residual_1000 = sum(residP1000.^2);

root600 = rmse(ModelPower600_Train, ExpPower600p_Train(1:length(ModelPower600_Train))); Sigma600 = std(ExpPower600p_Train);
root700 = rmse(ModelPower700_Train, ExpPower700p_Train(1:length(ModelPower700_Train))); Sigma700 = std(ExpPower700p_Train);
root800 = rmse(ModelPower800_Train, ExpPower800p_Train(1:length(ModelPower800_Train))); Sigma800 = std(ExpPower800p_Train);
root900 = rmse(ModelPower900_Train, ExpPower900p_Train(1:length(ModelPower900_Train))); Sigma900 = std(ExpPower900p_Train);
root1000 = rmse(ModelPower1000_Train, ExpPower1000p_Train(1:length(ModelPower1000_Train))); Sigma1000 = std(ExpPower1000p_Train);

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
fprintf('\n\tModel Fit, Training Data - Power\n')
disp(Outputs)


%% Validation Data Model
    % 600
    % calculate voltage and power based on parameters
ModelVoltage600_Validate = Veqtn(CellParams600, ExpCurrent600v_Validate);
Vp600_Validate = Veqtn(CellParams600, ExpCurrent600p_Validate);
ModelPower600_Validate = Vp600_Validate .* ExpCurrent600p_Validate;

    % cut power values after maximum
[Pmax600Validate, kMax600] = max(ModelPower600_Validate);
        % loop to remove values
k = length(ModelPower600_Validate) - kMax600;
for count = length(ModelPower600_Validate):-1:1
    if count > kMax600
        ModelPower600_Validate(count) = [];
        % ExpCurrent600p_Validate(count) = [];
    end
end

    % 700
    % calculate voltage based on parameters (V)
ModelVoltage700_Validate = Veqtn(CellParams700, ExpCurrent700v_Validate);
Vp700_Validate = Veqtn(CellParams700, ExpCurrent700p_Validate);
ModelPower700_Validate = Vp700_Validate .* ExpCurrent700p_Validate;

    % cut power values after maximum
[Pmax700Validate, kMax700] = max(ModelPower700_Validate);
        % loop to remove values
k = length(ModelPower700_Validate) - kMax700;
for count = length(ModelPower700_Validate):-1:1
    if count > kMax700
        ModelPower700_Validate(count) = [];
        % ExpCurrent700p_Validate(count) = [];
    end
end

    % 800
    % calculate voltage based on parameters (V)
ModelVoltage800_Validate = Veqtn(CellParams800, ExpCurrent800v_Validate);
Vp800_Validate = Veqtn(CellParams800, ExpCurrent800p_Validate);
ModelPower800_Validate = Vp800_Validate .* ExpCurrent800p_Validate;

    % cut power values after maximum
[Pmax800Validate, kMax800] = max(ModelPower800_Validate);
        % loop to remove values
k = length(ModelPower800_Validate) - kMax800;
for count = length(ModelPower800_Validate):-1:1
    if count > kMax800
        ModelPower800_Validate(count) = [];
        % ExpCurrent800p_Validate(count) = [];
    end
end

    % 900
    % calculate voltage based on parameters (V)
ModelVoltage900_Validate = Veqtn(CellParams900, ExpCurrent900v_Validate);
Vp900_Validate = Veqtn(CellParams900, ExpCurrent900p_Validate);
ModelPower900_Validate = Vp900_Validate .* ExpCurrent900p_Validate;

    % cut power values after maximum
[Pmax900Validate, kMax900] = max(ModelPower900_Validate);
        % loop to remove values
k = length(ModelPower900_Validate) - kMax900;
for count = length(ModelPower900_Validate):-1:1
    if count > kMax900
        ModelPower900_Validate(count) = [];
        % ExpCurrent900p_Validate(count) = [];
    end
end

    % 1000
    % calculate voltage based on parameters (V)
ModelVoltage1000_Validate = Veqtn(CellParams1000, ExpCurrent1000v_Validate);
Vp1000_Validate = Veqtn(CellParams1000, ExpCurrent1000p_Validate);
ModelPower1000_Validate = Vp1000_Validate .* ExpCurrent1000p_Validate;

    % cut power values after maximum
[Pmax1000Validate, kMax1000] = max(ModelPower1000_Validate);
        % loop to remove values
k = length(ModelPower1000_Validate) - kMax1000;
for count = length(ModelPower1000_Validate):-1:1
    if count > kMax1000
        ModelPower1000_Validate(count) = [];
        % ExpCurrent1000p_Validate(count) = [];
    end
end


%% Validation Data Fit Analysis - Voltage

% Actual vs predicted plot
figure(6)
title('Validation Data Validation: Actual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Validate, ExpVoltage600v_Validate, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 600 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,2)
plot(ModelVoltage700_Validate, ExpVoltage700v_Validate, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 700 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,3)
plot(ModelVoltage800_Validate, ExpVoltage800v_Validate, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 800 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,4)
plot(ModelVoltage900_Validate, ExpVoltage900v_Validate, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 900 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,5)
plot(ModelVoltage1000_Validate, ExpVoltage1000v_Validate, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 1000 C')
xlim([0,1])
ylim([0,1])

% Residual vs predicted
resid600_Validate = ExpVoltage600v_Validate - ModelVoltage600_Validate;
resid700_Validate = ExpVoltage700v_Validate - ModelVoltage700_Validate;
resid800_Validate = ExpVoltage800v_Validate - ModelVoltage800_Validate;
resid900_Validate = ExpVoltage900v_Validate - ModelVoltage900_Validate;
resid1000_Validate = ExpVoltage1000v_Validate - ModelVoltage1000_Validate;

figure(7)
title('Model Validation Data Validation: Residual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Validate, resid600_Validate, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual  (V)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelVoltage700_Validate, resid700_Validate, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelVoltage800_Validate, resid800_Validate, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelVoltage900_Validate, resid900_Validate, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelVoltage1000_Validate, resid1000_Validate, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 1000 C')

% residuals (p2 norm)
Norm = [residual_600v; residual_700v; residual_800v; residual_900v; residual_1000v];
% RMSE and standard deviation calculation for each temperature
root600_Validate = rmse(ModelVoltage600_Validate, ExpVoltage600v_Validate); Sigma600_Validate = std(ExpVoltage600v_Validate);
root700_Validate = rmse(ModelVoltage700_Validate, ExpVoltage700v_Validate); Sigma700_Validate = std(ExpVoltage700v_Validate);
root800_Validate = rmse(ModelVoltage800_Validate, ExpVoltage800v_Validate); Sigma800_Validate = std(ExpVoltage800v_Validate);
root900_Validate = rmse(ModelVoltage900_Validate, ExpVoltage900v_Validate); Sigma900_Validate = std(ExpVoltage900v_Validate);
root1000_Validate = rmse(ModelVoltage1000_Validate, ExpVoltage1000v_Validate); Sigma1000_Validate = std(ExpVoltage1000v_Validate);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600_Validate = root600_Validate / Sigma600_Validate * 100;
EvalRoot700_Validate = root700_Validate / Sigma700_Validate * 100;
EvalRoot800_Validate = root800_Validate / Sigma800_Validate * 100;
EvalRoot900_Validate = root900_Validate / Sigma900_Validate * 100;
EvalRoot1000_Validate = root1000_Validate / Sigma1000_Validate * 100;

% Output table
    % column vectors
RMSE = [root600_Validate; root700_Validate; root800_Validate; root900_Validate; root1000_Validate];
StandardDeviation = [Sigma600_Validate; Sigma700_Validate; Sigma800_Validate; Sigma900_Validate; Sigma1000_Validate];
PercentRMSE = [EvalRoot600_Validate; EvalRoot700_Validate; EvalRoot800_Validate; EvalRoot900_Validate; EvalRoot1000_Validate];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
fprintf('\n\tModel Fit, Validation Data - Voltage\n')
disp(Outputs)



%% Validation Data Model Fit Analysis - Power
% Actual vs predicted plot
figure(8)
title('Model Validation: Actual vs Predicted - Power, Validateing')
subplot(1,5,1)
plot(ModelPower600_Validate, ExpPower600p_Validate(1:length(ModelPower600_Validate)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 600 C')
xlim([0,0.31])
ylim([0,0.31])

subplot(1,5,2)
plot(ModelPower700_Validate, ExpPower700p_Validate(1:length(ModelPower700_Validate)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 700 C')
xlim([0,0.43])
ylim([0,0.43])

subplot(1,5,3)
plot(ModelPower800_Validate, ExpPower800p_Validate(1:length(ModelPower800_Validate)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 800 C')
xlim([0,0.55])
ylim([0,0.55])

subplot(1,5,4)
plot(ModelPower900_Validate, ExpPower900p_Validate(1:length(ModelPower900_Validate)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 900 C')
xlim([0,0.65])
ylim([0,0.65])

subplot(1,5,5)
plot(ModelPower1000_Validate, ExpPower1000p_Validate(1:length(ModelPower1000_Validate)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 1000 C')
xlim([0,0.7])
ylim([0,0.7])

% Residual vs predicted
residP600 = ExpPower600p_Validate(1:length(ModelPower600_Validate)) - ModelPower600_Validate;
residP700 = ExpPower700p_Validate(1:length(ModelPower700_Validate)) - ModelPower700_Validate;
residP800 = ExpPower800p_Validate(1:length(ModelPower800_Validate)) - ModelPower800_Validate;
residP900 = ExpPower900p_Validate(1:length(ModelPower900_Validate)) - ModelPower900_Validate;
residP1000 = ExpPower1000p_Validate(1:length(ModelPower1000_Validate)) - ModelPower1000_Validate;

figure(9)
title('Model Validation: Residual vs Predicted - Power, Validation')
subplot(1,5,1)
plot(ModelPower600_Validate, residP600, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual  (W/m^2)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelPower700_Validate, residP700, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelPower800_Validate, residP800, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelPower900_Validate, residP900, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelPower1000_Validate, residP1000, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 1000 C')

% RMSE and standard deviation calculation for each temperature
residual_600 = sum(residP600.^2);
residual_700 = sum(residP700.^2);
residual_800 = sum(residP800.^2);
residual_900 = sum(residP900.^2);
residual_1000 = sum(residP1000.^2);

root600 = rmse(ModelPower600_Validate, ExpPower600p_Validate(1:length(ModelPower600_Validate))); Sigma600 = std(ExpPower600p_Validate);
root700 = rmse(ModelPower700_Validate, ExpPower700p_Validate(1:length(ModelPower700_Validate))); Sigma700 = std(ExpPower700p_Validate);
root800 = rmse(ModelPower800_Validate, ExpPower800p_Validate(1:length(ModelPower800_Validate))); Sigma800 = std(ExpPower800p_Validate);
root900 = rmse(ModelPower900_Validate, ExpPower900p_Validate(1:length(ModelPower900_Validate))); Sigma900 = std(ExpPower900p_Validate);
root1000 = rmse(ModelPower1000_Validate, ExpPower1000p_Validate(1:length(ModelPower1000_Validate))); Sigma1000 = std(ExpPower1000p_Validate);

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
fprintf('\n\tModel Fit, Validation Data - Power\n')
disp(Outputs)


%% Validation Data Model
    % 600
    % calculate voltage and power based on parameters
ModelVoltage600_Test = Veqtn(CellParams600, ExpCurrent600v_Test);
Vp600_Test = Veqtn(CellParams600, ExpCurrent600p_Test);
ModelPower600_Test = Vp600_Test .* ExpCurrent600p_Test;

    % cut power values after maximum
[Pmax600Test, kMax600] = max(ModelPower600_Test);
        % loop to remove values
k = length(ModelPower600_Test) - kMax600;
for count = length(ModelPower600_Test):-1:1
    if count > kMax600
        ModelPower600_Test(count) = [];
        % ExpCurrent600p_Test(count) = [];
    end
end

    % 700
    % calculate voltage based on parameters (V)
ModelVoltage700_Test = Veqtn(CellParams700, ExpCurrent700v_Test);
Vp700_Test = Veqtn(CellParams700, ExpCurrent700p_Test);
ModelPower700_Test = Vp700_Test .* ExpCurrent700p_Test;

    % cut power values after maximum
[Pmax700Test, kMax700] = max(ModelPower700_Test);
        % loop to remove values
k = length(ModelPower700_Test) - kMax700;
for count = length(ModelPower700_Test):-1:1
    if count > kMax700
        ModelPower700_Test(count) = [];
        % ExpCurrent700p_Test(count) = [];
    end
end

    % 800
    % calculate voltage based on parameters (V)
ModelVoltage800_Test = Veqtn(CellParams800, ExpCurrent800v_Test);
Vp800_Test = Veqtn(CellParams800, ExpCurrent800p_Test);
ModelPower800_Test = Vp800_Test .* ExpCurrent800p_Test;

    % cut power values after maximum
[Pmax800Test, kMax800] = max(ModelPower800_Test);
        % loop to remove values
k = length(ModelPower800_Test) - kMax800;
for count = length(ModelPower800_Test):-1:1
    if count > kMax800
        ModelPower800_Test(count) = [];
        % ExpCurrent800p_Test(count) = [];
    end
end

    % 900
    % calculate voltage based on parameters (V)
ModelVoltage900_Test = Veqtn(CellParams900, ExpCurrent900v_Test);
Vp900_Test = Veqtn(CellParams900, ExpCurrent900p_Test);
ModelPower900_Test = Vp900_Test .* ExpCurrent900p_Test;

    % cut power values after maximum
[Pmax900Test, kMax900] = max(ModelPower900_Test);
        % loop to remove values
k = length(ModelPower900_Test) - kMax900;
for count = length(ModelPower900_Test):-1:1
    if count > kMax900
        ModelPower900_Test(count) = [];
        % ExpCurrent900p_Test(count) = [];
    end
end

    % 1000
    % calculate voltage based on parameters (V)
ModelVoltage1000_Test = Veqtn(CellParams1000, ExpCurrent1000v_Test);
Vp1000_Test = Veqtn(CellParams1000, ExpCurrent1000p_Test);
ModelPower1000_Test = Vp1000_Test .* ExpCurrent1000p_Test;

    % cut power values after maximum
[Pmax1000Test, kMax1000] = max(ModelPower1000_Test);
        % loop to remove values
k = length(ModelPower1000_Test) - kMax1000;
for count = length(ModelPower1000_Test):-1:1
    if count > kMax1000
        ModelPower1000_Test(count) = [];
        % ExpCurrent1000p_Test(count) = [];
    end
end


%% Test Data Fit Analysis - Voltage

% Actual vs predicted plot
figure(10)
title('Test Data Validation: Actual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Test, ExpVoltage600v_Test, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 600 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,2)
plot(ModelVoltage700_Test, ExpVoltage700v_Test, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 700 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,3)
plot(ModelVoltage800_Test, ExpVoltage800v_Test, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 800 C')
xlim([0,1])
ylim([0,1])

subplot(1,5,4)
plot(ModelVoltage900_Test, ExpVoltage900v_Test, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 900 C')
xlim([0,1])
ylim([0,1])


subplot(1,5,5)
plot(ModelVoltage1000_Test, ExpVoltage1000v_Test, '.', x,x,'r-')
xlabel('Predicted Voltage (V)')
ylabel('Actual Voltage (V)')
title('Temperature: 1000 C')
xlim([0,1])
ylim([0,1])


% Residual vs predicted
resid600_Test = ExpVoltage600v_Test - ModelVoltage600_Test;
resid700_Test = ExpVoltage700v_Test - ModelVoltage700_Test;
resid800_Test = ExpVoltage800v_Test - ModelVoltage800_Test;
resid900_Test = ExpVoltage900v_Test - ModelVoltage900_Test;
resid1000_Test = ExpVoltage1000v_Test - ModelVoltage1000_Test;

figure(11)
title('Model Test Data Validation: Residual vs Predicted')
subplot(1,5,1)
plot(ModelVoltage600_Test, resid600_Test, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual  (V)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelVoltage700_Test, resid700_Test, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelVoltage800_Test, resid800_Test, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelVoltage900_Test, resid900_Test, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelVoltage1000_Test, resid1000_Test, '.')
xlabel('Predicted Voltage (V)')
ylabel('Residual (V)')
title('Temperature: 1000 C')

% residuals (p2 norm)
Norm = [residual_600v; residual_700v; residual_800v; residual_900v; residual_1000v];
% RMSE and standard deviation calculation for each temperature
root600_Test = rmse(ModelVoltage600_Test, ExpVoltage600v_Test); Sigma600_Test = std(ExpVoltage600v_Test);
root700_Test = rmse(ModelVoltage700_Test, ExpVoltage700v_Test); Sigma700_Test = std(ExpVoltage700v_Test);
root800_Test = rmse(ModelVoltage800_Test, ExpVoltage800v_Test); Sigma800_Test = std(ExpVoltage800v_Test);
root900_Test = rmse(ModelVoltage900_Test, ExpVoltage900v_Test); Sigma900_Test = std(ExpVoltage900v_Test);
root1000_Test = rmse(ModelVoltage1000_Test, ExpVoltage1000v_Test); Sigma1000_Test = std(ExpVoltage1000v_Test);
% compare RMSE to standard deviation to evaluate fit
EvalRoot600_Test = root600_Test / Sigma600_Test * 100;
EvalRoot700_Test = root700_Test / Sigma700_Test * 100;
EvalRoot800_Test = root800_Test / Sigma800_Test * 100;
EvalRoot900_Test = root900_Test / Sigma900_Test * 100;
EvalRoot1000_Test = root1000_Test / Sigma1000_Test * 100;

% Output table
    % column vectors
RMSE = [root600_Test; root700_Test; root800_Test; root900_Test; root1000_Test];
StandardDeviation = [Sigma600_Test; Sigma700_Test; Sigma800_Test; Sigma900_Test; Sigma1000_Test];
PercentRMSE = [EvalRoot600_Test; EvalRoot700_Test; EvalRoot800_Test; EvalRoot900_Test; EvalRoot1000_Test];
    % create table
Outputs = table(Temperature, Norm, RMSE, StandardDeviation, PercentRMSE);
    % display table
fprintf('\n\tModel Fit, Test Data - Voltage\n')
disp(Outputs)



%% Test Data Model Fit Analysis - Power
% Actual vs predicted plot
figure(12)
title('Model Validation: Actual vs Predicted - Power, Test Data')
subplot(1,5,1)
plot(ModelPower600_Test, ExpPower600p_Test(1:length(ModelPower600_Test)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 600 C')
xlim([0,0.31])
ylim([0,0.31])

subplot(1,5,2)
plot(ModelPower700_Test, ExpPower700p_Test(1:length(ModelPower700_Test)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 700 C')
xlim([0,0.43])
ylim([0,0.43])

subplot(1,5,3)
plot(ModelPower800_Test, ExpPower800p_Test(1:length(ModelPower800_Test)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 800 C')
xlim([0,0.55])
ylim([0,0.55])

subplot(1,5,4)
plot(ModelPower900_Test, ExpPower900p_Test(1:length(ModelPower900_Test)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 900 C')
xlim([0,0.65])
ylim([0,0.65])


subplot(1,5,5)
plot(ModelPower1000_Test, ExpPower1000p_Test(1:length(ModelPower1000_Test)), '.', x,x,'r-')
xlabel('Predicted Power (W/m^2)')
ylabel('Actual Power (W/m^2)')
title('Temperature: 1000 C')
xlim([0,0.7])
ylim([0,0.7])


% Residual vs predicted
residP600 = ExpPower600p_Test(1:length(ModelPower600_Test)) - ModelPower600_Test;
residP700 = ExpPower700p_Test(1:length(ModelPower700_Test)) - ModelPower700_Test;
residP800 = ExpPower800p_Test(1:length(ModelPower800_Test)) - ModelPower800_Test;
residP900 = ExpPower900p_Test(1:length(ModelPower900_Test)) - ModelPower900_Test;
residP1000 = ExpPower1000p_Test(1:length(ModelPower1000_Test)) - ModelPower1000_Test;

figure(13)
title('Model Validation: Residual vs Predicted - Power, Test Data')
subplot(1,5,1)
plot(ModelPower600_Test, residP600, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual  (W/m^2)')
title('Temperature: 600 C')

subplot(1,5,2)
plot(ModelPower700_Test, residP700, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 700 C')

subplot(1,5,3)
plot(ModelPower800_Test, residP800, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 800 C')

subplot(1,5,4)
plot(ModelPower900_Test, residP900, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 900 C')

subplot(1,5,5)
plot(ModelPower1000_Test, residP1000, '.')
xlabel('Predicted Power (W/m^2)')
ylabel('Residual (W/m^2)')
title('Temperature: 1000 C')

% RMSE and standard deviation calculation for each temperature
residual_600 = sum(residP600.^2);
residual_700 = sum(residP700.^2);
residual_800 = sum(residP800.^2);
residual_900 = sum(residP900.^2);
residual_1000 = sum(residP1000.^2);

root600 = rmse(ModelPower600_Test, ExpPower600p_Test(1:length(ModelPower600_Test))); Sigma600 = std(ExpPower600p_Test);
root700 = rmse(ModelPower700_Test, ExpPower700p_Test(1:length(ModelPower700_Test))); Sigma700 = std(ExpPower700p_Test);
root800 = rmse(ModelPower800_Test, ExpPower800p_Test(1:length(ModelPower800_Test))); Sigma800 = std(ExpPower800p_Test);
root900 = rmse(ModelPower900_Test, ExpPower900p_Test(1:length(ModelPower900_Test))); Sigma900 = std(ExpPower900p_Test);
root1000 = rmse(ModelPower1000_Test, ExpPower1000p_Test(1:length(ModelPower1000_Test))); Sigma1000 = std(ExpPower1000p_Test);

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
fprintf('\n\tModel Fit, Test Data - Power\n')
disp(Outputs)

%% plot theoretical results
% combine sample set vectors
    % 600 C
ModelVoltage600 = Veqtn(CellParams600, Current_600);
Vp600 = Veqtn(CellParams600, i_600);
ModelPower600 = Vp600 .* i_600;

    % 700 C
ModelVoltage700 = Veqtn(CellParams700, Current_700);
Vp700 = Veqtn(CellParams700, i_700);
ModelPower700 = Vp700 .* i_700;

    % 800 C
ModelVoltage800 = Veqtn(CellParams800, Current_800);
Vp800 = Veqtn(CellParams800, i_800);
ModelPower800 = Vp800 .* i_800;

    % 900 C
ModelVoltage900 = Veqtn(CellParams900, Current_900);
Vp900 = Veqtn(CellParams900, i_900);
ModelPower900 = Vp900 .* i_900;

    % 1000 C
ModelVoltage1000 = Veqtn(CellParams1000, Current_1000);
Vp1000 = Veqtn(CellParams1000, i_1000);
ModelPower1000 = Vp1000 .* i_1000;

% Plot theoretical results over experimental points
figure(14)   % Voltage
subplot(1,2,1)
plot(Current_600, Voltage_600, 'o', Current_600, ModelVoltage600, '-')
hold on
plot(Current_700, Voltage_700, 'diamond', Current_700, ModelVoltage700, '-')
plot(Current_800, Voltage_800, '*', Current_800, ModelVoltage800, '-')
plot(Current_900, Voltage_900, 'square', Current_900, ModelVoltage900, '-') 
plot(Current_1000, Voltage_1000, '^', Current_1000, ModelVoltage1000, '-')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
title('Polarization Curve Validation')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve - 1000')

subplot(1,2,2)  % Power
plot(i_600, Power_600, 'o', i_600, ModelPower600, '-')
hold on
plot(i_700, Power_700, 'diamond', i_700, ModelPower700, '-')
plot(i_800, Power_800, '*', i_800, ModelPower800, '-')
plot(i_900, Power_900, 'square', i_900, ModelPower900, '-')    
plot(i_1000, Power_1000, '^', i_1000, ModelPower1000, '-')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Power Density (W/cm^2)')
title('Power Curve Validation')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 900', 'Fitted Curve - 900', ...
    'Experimental Data - 1000', 'Fitted Curve - 1000')


%% Testing at 750 for comparison to paper
CellParams750 = VoltageFit((750+273), V0, a, Ri, j0, jL, temps);
i750 = [0.1	0.2	0.25	0.37	0.41	0.55	0.6	0.71	0.8];
V750 = Veqtn(CellParams750, i750);
P750 = i750 .* V750;


%% Local Function: Finds model parameters based on cubic linear interpolation
function Parameters = VoltageFit(T, VSet, aSet, RiSet, j0Set, jLSet, temps)

if T >= temps(1) && T <= temps(2)
    V0 = interp1(temps(1:2), VSet(1:2), T, "linear");
    a = interp1(temps(1:2), aSet(1:2), T, "linear");
    Ri = interp1(temps(1:2), RiSet(1:2), T, "linear");
    j0 = interp1(temps(1:2), j0Set(1:2), T, "linear");
    jL = interp1(temps(1:2), jLSet(1:2), T, "linear");
elseif T > temps(2) && T <= temps(3)
    V0 = interp1(temps(2:3), VSet(1:2), T, "linear");
    a = interp1(temps(2:3), aSet(2:3), T, "linear");
    Ri = interp1(temps(2:3), RiSet(2:3), T, "linear");
    j0 = interp1(temps(2:3), j0Set(2:3), T, "linear");
    jL = interp1(temps(2:3), jLSet(2:3), T, "linear");
elseif T > temps(3) && T <= temps(4)
    V0 = interp1(temps(3:4), VSet(3:4), T, "linear");
    a = interp1(temps(3:4), aSet(3:4), T, "linear");
    Ri = interp1(temps(3:4), RiSet(3:4), T, "linear");
    j0 = interp1(temps(3:4), j0Set(3:4), T, "linear");
    jL = interp1(temps(3:4), jLSet(3:4), T, "linear");
elseif T > temps(4) && T <= temps(5)
    V0 = interp1(temps(4:5), VSet(4:5), T, "linear");
    a = interp1(temps(4:5), aSet(4:5), T, "linear");
    Ri = interp1(temps(4:5), RiSet(4:5), T, "linear");
    j0 = interp1(temps(4:5), j0Set(4:5), T, "linear");
    jL = interp1(temps(4:5), jLSet(4:5), T, "linear");
else
    fprintf('\n\n ERROR: Temperature out of bounds!')
end

Parameters =  [V0, a, Ri, j0, jL, T];

end