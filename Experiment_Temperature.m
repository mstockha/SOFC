%% User Inputs

pH2 = 0.98;         % partial pressure of Hydrogen (atm)
dt = 1;             % time step (seconds)
A = 500;            % cell reacting area (cm^2)
PowerSplit = 1;   % percentage of power supplied by SOFC  
delTemp = 20;        % temperature step for iteration


%% Mission Data

load("FC_power_required.mat");          % load data workspace

% convert power consumption to Watts, apply SOFC/turbine power split
    % total kW power consumed --> W power consumed from SOFC
E = thrust_power_required(2,:).*PowerSplit.*1000;
    % total kW power consumed --> W power consumed from turbine
P = thrust_power_required(2,:).*(1-PowerSplit).*1000;

% for negative power consumption values, set power to zero
for j = 1:8640
    if E(j)<0
        E(j)=0;
    end
end   

% Load mission data
load("mission_t_v_h.mat");
M = mission_t_v_h(3,:);         % altitude (m)
V = mission_t_v_h(2,:);         % velocity (m/s)

% set power consumption time scale for plotting
time_scale = 0:(length(E)-1);
time = time_scale.*dt;


%% test data
% SOFC ops temp
Temps = 600:delTemp:1000;
n = length(Temps);

% allocate solution matrices
    % Minimum Cell Number
cellNum = zeros(1,n);
    % LNG Values
LNG_SOFC = zeros(1,n); 
LNG_Turbine = zeros(1,n); 
LNG_Duct = zeros(1,n);
LNG_Total = zeros(1,n);
    % Liquid Water Values
waterTank = zeros(1,n);
    % Steam Values
steam_SOFC = zeros(1,n); 
steam_turbine = zeros(1,n); 
steam_duct = zeros(1,n);
steam_Total = zeros(1,n);
    % Air Values
air_SOFC = zeros(1,n); 
air_turbine = zeros(1,n); 
air_duct = zeros(1,n);
air_Total = zeros(1,n);
    % Carbon Dioxide Values
dioxide_FR = zeros(1,n);
dioxide_turbine = zeros(1,n);
dioxide_duct = zeros(1,n);
dioxide_Total = zeros(1,n);
    % Carbon Monoxide Values
monoxide_FR = zeros(1,n);
    % Heat Exchange Values
heat_FR = zeros(1,n);
heat_steam = zeros(1,n);
heat_air = zeros(1,n);
heat_duct = zeros(1,n);
heat_LNG = zeros(1,n);
heat_rejected = zeros(1,n);
heat_turbine = zeros(1,n);
heat_SOFC = zeros(1,n);
    % Tank Mass
tank_SOFC = zeros(1,n);
tank_Turbine = zeros(1,n);
tank_DuctBurner = zeros(1,n);

%% data collection
for j = 1:n
    disp(j)
    [Turbine_Model, SOFC_Model, FuelReformation, SteamRecycling, ...
        HeatFlow, DuctBurnHeater, TankMass, SystemReactants] = ...
        SOFCdriver(Temps(j), E, P, pH2, dt, A);
        
        % Cell Number
    cellNum(j) = SOFC_Model.Specs.CellNum;
        % LNG Values
    LNG_SOFC(j) = FuelReformation.ReactantTotals.LNG; 
    LNG_Turbine(j) = sum(Turbine_Model.Inflow.LNG .* dt); 
    LNG_Duct(j) = sum(DuctBurnHeater.InflowLNG .* dt);
    LNG_Total(j) = SystemReactants.LNG;
        % Liquid Water Values
    waterTank(j) = SteamRecycling.Performance.WaterCarriage;
        % Steam Values
    steam_SOFC(j) = SOFC_Model.Reactants.TotalSteam; 
    steam_turbine(j) = sum(Turbine_Model.Outflow.Steam .* dt); 
    steam_duct(j) = sum(DuctBurnHeater.OutflowSteam .* dt);
    steam_Total(j) = SystemReactants.Steam;
        % Air Values
    air_SOFC(j) = SOFC_Model.Reactants.TotalInflow_Air; 
    air_turbine(j) = sum(Turbine_Model.Inflow.Air .* dt); 
    air_duct(j) = sum(DuctBurnHeater.InflowAir .* dt);
    air_Total(j) = SystemReactants.AirTotal;
        % Carbon Dioxide Values
    dioxide_FR(j) = FuelReformation.ReactantTotals.CarbonDiox;
    dioxide_turbine(j) = sum(Turbine_Model.Outflow.CarbonDiox.*dt);
    dioxide_duct(j) = sum(DuctBurnHeater.OutflowCarbonDiox .* dt);
    dioxide_Total(j) = SystemReactants.CarbonDiox;
        % Carbon Monoxide Values
    monoxide_FR(j) = SystemReactants.CarbonMonox;
        % Heat Exchange Values
    heat_turbine(j) = sum(dt.*Turbine_Model.Outflow.Heat);
    heat_SOFC(j) = SOFC_Model.Reactants.TotalHeat;
    heat_duct(j) = sum(dt.*HeatFlow.Burner);
    heat_FR(j) = FuelReformation.ReactantTotals.HeatRequired;
    heat_LNG(j) = sum(dt.*HeatFlow.LNG);
    heat_steam(j) = sum(dt.*HeatFlow.Steam);
    heat_air(j) = sum(dt.*HeatFlow.Air);
    heat_rejected(j) = HeatFlow.NetHeat_Rejected;
        % Tank Mass
    tank_SOFC(j) = TankMass.Primary_SOFC;
    tank_Turbine(j) = TankMass.Turbine;
    tank_DuctBurner(j) = TankMass.DuctBurner;
end


%% Analyze Results

% optimized inputs
[LNG_min, Temp_LNG] = min(LNG_Total);  Temp_minFuel = Temps(Temp_LNG);
[Turbine_min, Temp_Turbine] = min(LNG_Turbine);  Temp_minTurbine = Temps(Temp_Turbine);
[SOFC_min, Temp_SOFC] = min(LNG_SOFC);  Temp_minSOFC = Temps(Temp_SOFC);
[Duct_min, Temp_Duct] = min(LNG_Duct);  Temp_minDuct = Temps(Temp_Duct);

[Water_min, Temp_water] = min(waterTank);  Temp_minH2O = Temps(Temp_water);
[Air_min, Temp_air] = min(air_Total);  Temp_minAir = Temps(Temp_air);
[Cells_min, Temp_cells] = min(cellNum); Temp_minCells = Temps(Temp_cells);

% optimized outputs
[Steam_min, Temp_steam] = min(steam_Total);  Temp_minSteam = Temps(Temp_steam);
[CO2_min, Temp_CO2] = min(dioxide_Total);  Temp_minCO2 = Temps(Temp_CO2);
[CO_min, Temp_CO] = min(monoxide_FR);  Temp_minCO = Temps(Temp_CO);
[RejectedHeat_min, Temp_heat] = min(heat_rejected);  Temp_minHeat = Temps(Temp_heat);


%% plotting results
figure(1)
subplot(4,1,1)
plot(Temps, cellNum)
title('Reactant Consumption Trends')
xlabel('Temperature (Celsius)')
ylabel('Installed SOFC Cells Required (units)')
hold on
plot(Temp_minCells, Cells_min, '*')
hold off

subplot(4,1,2)
plot(Temps, LNG_Total, 'k-', Temp_minFuel, LNG_min, '*')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
legend('', 'Minimum LNG')

subplot(4,1,3)
plot(Temps, waterTank)
xlabel('Temperature (Celsius)')
ylabel('Total Water Carriage (kg)')
hold on
plot(Temp_minH2O, Water_min, '*')
hold off

subplot(4,1,4)
plot(Temps, air_Total)
xlabel('Temperature (Celsius)')
ylabel('Total Air Consumption (kg)')
hold on
plot(Temp_minAir, Air_min, '*')
hold off


figure(2)
subplot(4,1,1)
plot(Temps, steam_Total)
title('Exhaust Rejection Trends')
xlabel('Temperature (Celsius)')
ylabel('Total Steam Exhaust (kg)')
hold on
plot(Temp_minSteam, Steam_min, '*')
hold off

subplot(4,1,2)
plot(Temps, monoxide_FR)
xlabel('Temperature (Celsius)')
ylabel('Total CO Exhaust (kg)')
hold on
plot(Temp_minCO, CO_min, '*')
hold off

subplot(4,1,3)
plot(Temps, dioxide_Total)
xlabel('Temperature (Celsius)')
ylabel('Total CO_2 Exhaust (kg)')
hold on
plot(Temp_minCO2, CO2_min, '*')
hold off

subplot(4,1,4)
plot(Temps, heat_rejected)
xlabel('Temperature (Celsius)')
ylabel('Total Waste Heat (kJ)')
hold on
plot(Temp_minHeat, RejectedHeat_min, '*')
hold off


figure(3)
subplot(4,1,1)
plot(Temps, LNG_Total, 'k-', Temp_minFuel, LNG_min, '*')
title('Total LNG Flow')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
legend('', 'Minimum LNG')

subplot(4,1,2)
plot(Temps, LNG_Turbine, 'k-', Temp_minTurbine, Turbine_min, '*')
title('Turbine LNG Flow')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
legend('', 'Minimum Turbine LNG')

subplot(4,1,3)
plot(Temps, LNG_SOFC, 'k-', Temp_minSOFC, SOFC_min, '*')
title('SOFC LNG Flow')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
legend('', 'Minimum SOFC LNG')

subplot(4,1,4)
plot(Temps, LNG_Duct, 'k-', Temp_minDuct, Duct_min, '*')
title('Burner LNG Flow')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
legend('', 'Minimum Duct LNG')


figure(4)
plot(Temps, heat_turbine, Linewidth = 2)
hold on
plot(Temps, heat_SOFC, Temps, heat_duct)
plot(Temps, heat_FR, Temps, heat_LNG, Temps, heat_air, Temps, heat_steam)
plot(Temps, heat_rejected, 'k-')
hold off
title('Total Heat Flow')
xlabel('Temperature (Celsius)')
ylabel('Total Heat Consumed (kJ')
legend('Turbine', 'SOFC', 'Duct Burner', 'Fuel Reformer', ...
    'LNG Heating', 'Air Heating', 'H_2O Heating', 'Net Heat Rejected')


figure(5);
plot(time, Turbine_Model.Outflow.Heat, LineWidth=3);
hold on
plot(time, SOFC_Model.Performance.HeatFlow, LineWidth=2);
plot(time, FuelReformation.Inflow.HeatRequired, LineWidth=2);
plot(time, HeatFlow.LNG, LineWidth=2);
plot(time, HeatFlow.Steam, LineWidth=2);
plot(time, HeatFlow.Air, LineWidth=2);
plot(time, HeatFlow.Burner, LineWidth=2);
plot(time, HeatFlow.TotalFlow, 'k-', LineWidth=2);
hold off
xlabel("time (s)", FontSize=18);
ylabel("Heat per Second Needed (kJ/s)", FontSize=18);
title("Heat per Second Comparisons over Time", FontSize=18)
legend('Turbine', 'SOFC Heat', 'Fuel Reformer Heat', ...
    'Heat Required to Heat up Methane', 'Heat Required to Heat up Water', ...
    'Heat Required to Heat up Air', 'Heat from Burner', ...
    'Total System Heat', fontsize=18);