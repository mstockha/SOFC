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

[Cells650, i650, V650, P650] = PolarizationCurve(650);
[Cells750, i750, V750, P750] = PolarizationCurve(750);
[Cells850, i850, V850, P850] = PolarizationCurve(850);


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


imax650 = max(i650); Vmax650 = max(V650); Pmax650 = max(P650);
Vavg650 = mean(V650); Pavg650 = mean(P650);
Vstd650 = std(V650); Pstd650 = std(P650);

imax750 = max(i750); Vmax750 = max(V750); Pmax750 = max(P750);
Vavg750 = mean(V750); Pavg750 = mean(P750);
Vstd750 = std(V750); Pstd750 = std(P750);

imax850 = max(i850); Vmax850 = max(V850); Pmax850 = max(P850);
Vavg850 = mean(V850); Pavg850 = mean(P850);
Vstd850 = std(V850); Pstd850 = std(P850);


%% Build Table
% Fitting Temperatures
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

% Intermediary Temperatures
Temperature = [650; 750; 850];
MaxVolts = [Vmax650; Vmax750; Vmax850];
AvgVolts = [Vavg650; Vavg750; Vavg850];
SDVolts = [Vstd650; Vstd750; Vstd850];
MaxP = [Pmax650; Pmax750; Pmax850];
AvgP = [Pavg650; Pavg750; Pavg850];
SDP = [Pstd650; Pstd750; Pstd850];
MaxI = [imax650; imax750; imax850];

Outputs = table(Temperature, MaxVolts, AvgVolts, SDVolts, MaxP, AvgP, SDP, MaxI);
    % display table
fprintf('\n\tStatistical Analysis of Ascending fit to numerical model average\n')
disp(Outputs)

%% Local Function for Cell Polarization & Power Curves
function [CellParams, i, V, power] = PolarizationCurve(T)
% local function for cell voltage equation
% local function for cell voltage equation
Veqtn = @(params,j) params(1) ...
    - ((8.314.*params(6))./(params(2).*2.*96485.34) .* log((j+0.01)./params(4)) ...
    + j.*params(3) + (8.314.*params(6))./(2.*96485.34) .* (1 + 1/params(2)) ...
    .* log(params(5)./(params(5) - j)));
% params = [V0, a, Ri, j0, jL, T (Kelvin)]

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

% V0_set = [1.0276	1.0145	1.0075	1.005	0.924423695453649];
% Ri_set = [0.641530799341247 0.388420612425614 0.261137090440196 0.209672826238255 0.168875502408782];
% j0_set = [0.0789021319358237 0.380617272326173 0.509871515813084 0.945706271560702 1.17705190520681]; 
% jL_set = [1.00100000000002 1.02068700810361 1.31203885315528 1.54100002710257 1.66640934704912];
% 
% V0_set = [1.0241 0.96451 0.93557 0.92268 0.9135];
% Ri_set = [0.56458 0.38842 0.26114 0.20966 0.16887];
% j0_set = [0.069061 0.39284 0.9483 1.3138 1.4364]; 
% jL_set = [0.7487 1.0207 1.312 1.5409 1.6664];

V0_set = [1.0241 1.0418 1.0697 1.0609 1.0742];
Ri_set = [0.57569 0.39476 0.26468 0.21215 0.17121];
j0_set = [0.077183 0.067096 0.055216 0.089159 0.080058]; 
jL_set = [0.075934 1.03 1.3181 1.5461 1.6712];


% linear fit for best fit parameters: cve coefficents fit as Var = f(T)
T = T + 273;

params_V0 = polyfit(temps, V0_set, 3);   V0 = polyval(params_V0, T);
params_Ri = polyfit(temps, Ri_set, 3);   Ri = polyval(params_Ri, T);
params_j0 = polyfit(temps, j0_set, 3);   j0 = polyval(params_j0, T);
params_jL = polyfit(temps, jL_set, 2);   jL = polyval(params_jL, T);
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