% Title: VoltageEqtnFittingData_AllDataSets.m
% Author: Miranda Stockhausen, mstockha@umich.edu
% Date Written: 6 November 2026
% 
% % % Description: % % % 
% This file evaluates the ascending curve sizing for each temperature, to 
% compare to the averaged data sets

clc; clear;

%% Data Collection
[Cells600, i600, V600, P600] = PolarizationCurve(600);
[Cells700, i700, V700, P700] = PolarizationCurve(700);
[Cells800, i800, V800, P800] = PolarizationCurve(800);
[Cells900, i900, V900, P900] = PolarizationCurve(900);
[Cells1000, i1000, V1000, P1000] = PolarizationCurve(1000);


%% Data Analysis
% 600 C
imax600 = max(i600); Vmax600 = max(V600); Pmax600 = max(P600);
Vavg600 = mean(V600); Pavg600 = mean(P600);
Vstd600 = std(V600); Pstd600 = std(P600);

% 700 C
imax700 = max(i700); Vmax700 = max(V700); Pmax700 = max(P700);
Vavg700 = mean(V700); Pavg700 = mean(P700);
Vstd700 = std(V700); Pstd700 = std(P700);

% 800 C
imax800 = max(i800); Vmax800 = max(V800); Pmax800 = max(P800);
Vavg800 = mean(V800); Pavg800 = mean(P800);
Vstd800 = std(V800); Pstd800 = std(P800);

% 900 C
imax900 = max(i900); Vmax900 = max(V900); Pmax900 = max(P900);
Vavg900 = mean(V900); Pavg900 = mean(P900);
Vstd900 = std(V900); Pstd900 = std(P900);

% 1000 C
imax1000 = max(i1000); Vmax1000 = max(V1000); Pmax1000 = max(P1000);
Vavg1000 = mean(V1000); Pavg1000 = mean(P1000);
Vstd1000 = std(V1000); Pstd1000 = std(P1000);


%% Build Table
Temperature = [600; 700; 800; 900; 1000];
MaxVolts = [Vmax600; Vmax700; Vmax800; Vmax900; Vmax1000];
AvgVolts = [Vavg600; Vavg700; Vavg800; Vavg900; Vavg1000];
SDVolts = [Vstd600; Vstd700; Vstd800; Vstd900; Vstd1000];
MaxP = [Pmax600; Pmax700; Pmax800; Pmax900; Pmax1000];
AvgP = [Pavg600; Pavg700; Pavg800; Pavg900; Pavg1000];
SDP = [Pstd600; Pstd700; Pstd800; Pstd900; Pstd1000];
MaxI = [imax600; imax700; imax800; imax900; imax1000];

Outputs = table(Temperature, MaxVolts, AvgVolts, SDVolts, MaxP, AvgP, SDP, MaxI);
    % display table
fprintf('\n\tStatistical Analysis of Ascending fit to numerical model average\n')
disp(Outputs)


%% Local Function for Cell Polarization & Power Curves
function [CellParams, i, V, power] = PolarizationCurve(T)
% local function for cell voltage equation
Veqtn = @(params,j) params(1) - j.*params(3) ...
     - (8.314.*params(6)./j)./(2.*96485.34.*params(4)) ...
     - (8.314.*params(6))./(2.*96485.34) .* (1 + 1/params(2)) ...
     .* log(params(5)./(params(5) - j)); 

% params = [V0, a, Ri, j0, jL, T (Kelvin)]

%% Estimate Voltage Equation Values
% Model: Voltage Equation for each temperature
    % i = current density (known input)
    % params = [V0, a, Ri, j0, jL]
    % V0 = thermonuetral/Nernst voltage
    % a = charge transfer coefficient 
    % Ri = Area specific resistance
    % j0 = exchange current density
    % jL = limiting current density

% cell voltage equation (cve) best fit coefficients
temps = [873 973 1073 1173 1273];           % temperature [celsius]
V0_set = [1.02756183616924	0.965833408425338	0.964258884813814	0.939305184875729	0.924423695453649];
Ri_set = [0.641530799341247 0.388420612425614 0.261137090440196 0.209672826238255 0.168875502408782];
j0_set = [0.0789021319358237 0.380617272326173 0.509871515813084 0.945706271560702 1.17705190520681]; 
jL_set = [1.00100000000002 1.02068700810361 1.31203885315528 1.54100002710257 1.66640934704912];

% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
T = T + 273;

params_V0 = polyfit(temps, V0_set, 3);   V0 = polyval(params_V0, T);
params_Ri = polyfit(temps, Ri_set, 3);   Ri = polyval(params_Ri, T);
params_j0 = polyfit(temps, j0_set, 3);   j0 = polyval(params_j0, T);
params_jL = polyfit(temps, jL_set, 3);   jL = polyval(params_jL, T);
a = 1;        % da/dT = 0 per curve fitting

CellParams = [V0, a, Ri, j0, jL];


%% Single Cell Sizing: Voltage Equation Analysis
% set current density from 0 to limiting current density (A/cm^2)
i = 0:0.01:(jL - 0.01); i(1) = 0.0001;

% calculate voltage based on parameters (V)
parameters = [CellParams, T];
V = Veqtn(parameters, i);

for count = 1:length(V)
    if V(count) < 0
        V(count) = 0;
    end
end

% due to operation, some values will be imaginary - set to NaN
V(V~=real(V)) = NaN;


% calculate cell power (W/cm^2)
power = i.*V;

end