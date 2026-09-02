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
plot(Current_600, Voltage_600)
hold on
plot(Current_700, Voltage_700, Current_800, Voltage_800)
plot(Current_900, Voltage_900, Current_1000, Voltage_1000)
plot(Current_750_Zhao, Voltage_750_Zhao)
plot(Current_800_Zhao, Voltage_800_Zhao)
plot(Current_850_Zhao, Voltage_850_Zhao)
plot(Current_700_Buon, Voltage_700_Buon)
plot(Current_750_Buon, Voltage_750_Buon)
plot(Current_800_Buon, Voltage_800_Buon)
hold off
title('Cell Voltage Data')
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('600 C', '700 C', '800 C', '900 C', '1000 C', '750', '800', '850', '700', '750','800')
xlim([-0.5,2.5])
ylim([0,1])
%%
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


% Veqtn_600 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*873)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*873) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));
% Veqtn_700 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*973)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*973) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));
% Veqtn_750 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*1023)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*1023) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));
% Veqtn_800 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*1073)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*1073) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));
% Veqtn_900 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*1173)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*1173) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));
% Veqtn_1000 = @(params, j) 1.06 - j.*params(2) ...
%     - (8.314.*1273)./(params(1).*2.*96485.34).* (log(j) - log(params(3)))...
%     - (8.314.*1273) ./(2.*96485.34) .* (1 + 1./params(1)) .* (log(params(4)) - log(params(4) - j));

Veqtn_600 = @(params, j) 1.06 - j.*params(2) - (8.314.*873)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));
Veqtn_700 = @(params, j) 1.06 - j.*params(2) - (8.314.*973)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));
Veqtn_750 = @(params, j) 1.06 - j.*params(2) - (8.314.*1023)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));
Veqtn_800 = @(params, j) 1.06 - j.*params(2) - (8.314.*1073)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));
Veqtn_900 = @(params, j) 1.06 - j.*params(2) - (8.314.*1173)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));
Veqtn_1000 = @(params, j) 1.06 - j.*params(2) - (8.314.*1273)./(params(1).*2.*96485.34) .* (log(j) - log(params(3)) + (1 + params(1)).*log(params(4)) - log(params(4) - j));

% Set parameter conditions (true for all temperatures)
initials = [0.5 0.04 0.1 4];           % initial guesses
upper = [0.7 0.1 10 4];                 % upper bounds
lower_600 = [0.2 0 0 1.1];     % lower bounds
lower_700 = [0.2 0 0 2.1313];     % lower bounds
lower_750 = [0.2 0 0 2.73];     % lower bounds
lower_800 = [0.2 0 0 3.023];     % lower bounds
lower_900 = [0.2 0.0001 0 1.99];     % lower bounds
lower_1000 = [0.2 0.0001 0 2.2];     % lower bounds

% curve fit for each dataset
[parameters_600, residual_600] = lsqcurvefit(Veqtn_600, initials, Current_600, Voltage_600, lower_600, upper);

[parameters_700, residual_700] = lsqcurvefit(Veqtn_700, initials, Current_700_Buon, Voltage_700_Buon, lower_700, upper);
[parameters_750, residual_750] = lsqcurvefit(Veqtn_750, initials, Current_750_Buon, Voltage_750_Buon, lower_750, upper);
[parameters_800, residual_800] = lsqcurvefit(Veqtn_800, initials, Current_800_Buon, Voltage_800_Buon, lower_800, upper);

[parameters_900, residual_900] = lsqcurvefit(Veqtn_900, initials, Current_900, Voltage_900, lower_900, upper);
[parameters_1000, residual_1000] = lsqcurvefit(Veqtn_1000, initials, Current_1000, Voltage_1000, lower_1000, upper);



%% Voltage calculation based on parameters
V600 = Veqtn_600(parameters_600, Current_600);
V600_p = Veqtn_600(parameters_600, i_600);

V700 = Veqtn_700(parameters_700, Current_700_Buon);
V700_p = Veqtn_700(parameters_700, i_700_Buon);
V750 = Veqtn_750(parameters_750, Current_750_Buon);
V750_p = Veqtn_750(parameters_750, i_750_Buon);
V800 = Veqtn_800(parameters_800, Current_800_Buon);
V800_p = Veqtn_800(parameters_800, i_800_Buon);

V900 = Veqtn_900(parameters_900, Current_900);
V900_p = Veqtn_900(parameters_900, i_900);
V1000 = Veqtn_1000(parameters_1000, Current_1000);
V1000_p = Veqtn_1000(parameters_1000, i_1000);

% Power calculation from calculated voltage
P600 = V600_p .* i_600;
P700 = V700_p .* i_700_Buon;
P750 = V750_p .* i_750_Buon;
P800 = V800_p .* i_800_Buon;
P900 = V900_p .* i_900;
P1000 = V1000_p .* i_1000;


%% Format Outputs & Validation

% Output table
    % column vectors
Temperature = [600; 700; 750; 800; 900; 1000];
a  = [parameters_600(1); parameters_700(1); parameters_750(1); parameters_800(1); parameters_900(1); parameters_1000(1)];
Ri = [parameters_600(2); parameters_700(2); parameters_750(2); parameters_800(2); parameters_900(2); parameters_1000(2)];
j0 = [parameters_600(3); parameters_700(3); parameters_750(3); parameters_800(3); parameters_900(3); parameters_1000(3)];
jL = [parameters_600(4); parameters_700(4); parameters_750(4); parameters_800(4); parameters_900(4); parameters_1000(4)];
Residual = [residual_600; residual_700; residual_750; residual_800; residual_900; residual_1000];
    % create table
Outputs = table(Temperature, a, Ri, j0, jL, Residual);
    % display table
disp(Outputs)

% plot theoretical results
figure(3)   % Voltage
plot(Current_600, Voltage_600, 'o', Current_600, V600)
hold on
plot(Current_700_Buon, Voltage_700_Buon, 'diamond', Current_700_Buon, V700)
plot(Current_750_Buon, Voltage_750_Buon, '.', Current_750_Buon, V750)
plot(Current_800_Buon, Voltage_800_Buon, '*', Current_800_Buon, V800)
%plot(Current_900, Voltage_900, 'square', Current_900, V900) 'Experimental Data - 900', 'Fitted Curve - 900', ...
plot(Current_1000, Voltage_1000, '^', Current_1000, V1000)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Voltage (V)')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 750', 'Fitted Curve - 750', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 1000', 'Fitted Curve -1000')

figure(4)   % Power
plot(i_600, Power_600, 'o', i_600, P600)
hold on
plot(i_700_Buon, Power_700_Buon, 'diamond', i_700_Buon, P700)
plot(i_750_Buon, Power_750_Buon, '.', i_750_Buon, P750)
plot(i_800_Buon, Power_800_Buon, '*', i_800_Buon, P800)
%plot(i_900, Power_900, 'square', i_900, P900)    'Experimental Data - 900', 'Fitted Curve - 900', ...
plot(i_1000, Power_1000, '^', i_1000, P1000)
xlabel('Current Density (A/cm^2)')
ylabel('Cell Power Density (W/cm^2)')
legend('Experimental Data - 600', 'Fitted Curve - 600', ...
    'Experimental Data - 700', 'Fitted Curve - 700', ...
    'Experimental Data - 750', 'Fitted Curve - 750', ...
    'Experimental Data - 800', 'Fitted Curve - 800', ...
    'Experimental Data - 1000', 'Fitted Curve -1000')