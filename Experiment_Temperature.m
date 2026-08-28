%% User Inputs

pH2 = 0.98;         % partial pressure of Hydrogen (atm)
dt = 1;             % time step (seconds)
A = 500;            % cell reacting area (cm^2)
PowerSplit = 1;     % percentage of power supplied by SOFC
delTemp = 10;       % temperature step for iteration


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
methane_SOFC = zeros(1,n);
LNGtank_Primary = zeros(1,n);
RejectedHeat = zeros(1,n);
water = zeros(1,n);
steam_SOFC = zeros(1,n);
airIn_SOFC = zeros(1,n);
CO_fuelref = zeros(1,n);
CO2_fuelref = zeros(1,n);
burner = zeros(8640,n);
burner_methane = zeros(1,n);
burner_air = zeros(1,n);
burner_steam = zeros(1,n);
burner_CO2 = zeros(1,n);
burnerTank = zeros(1,n);
cellNum = zeros(1,n);

%% data collection
for j = 1:n
    j
    [Turbine_Model, SOFC_Model, FuelReformation, SteamRecycling, HeatFlow, DuctBurnHeater, TankMass, SystemReactants] = SOFCdriver(Temps(j), E, P, pH2, dt, A)
    [totalmethane, tankmass_primary, total_heat, total_air, totalCO, totalCO2, wmin, winitial, totalexhauststeam, burnerheat, turbine_LNG, turbine_air, turbine_steam, turbine_CO2, tankmass_turbine, cells] = SOFCdriver(Temps(j), E, P, pH2, dt, A);
    methane_SOFC(j) = totalmethane;
    LNGtank_Primary(j) = tankmass_primary;
    RejectedHeat(j) = total_heat;
    water(j) = winitial;
    steam_SOFC(j) = totalexhauststeam;
    airIn_SOFC(j) = total_air;
    CO_fuelref(j) = totalCO;
    CO2_fuelref(j) = totalCO2;
    burner(:,j) = burnerheat;
    burner_methane(j) = sum(turbine_LNG.*dt);
    burner_air(j) = sum(turbine_air.*dt);
    burner_steam(j) = sum(turbine_steam.*dt);
    burner_CO2(j) = sum(turbine_CO2.*dt);
    burnerTank(j) = tankmass_turbine;
    cellNum(j) = cells;
end

%% determine total reactants, SOFC + burner
    % Input LNG
Input_LNG = methane_SOFC + burner_methane;
    % Input air
Input_air = airIn_SOFC + burner_air;
    % Exhaust Steam
Output_Steam = steam_SOFC + burner_steam;
    % Exhaust CO2
Output_CO2 = CO2_fuelref + burner_CO2;


%% Analyze Results

% optimized inputs
[LNG_min, Temp_LNG] = min(Input_LNG);  Temp_minFuel = Temps(Temp_LNG);
[Water_min, Temp_water] = min(water);  Temp_minH2O = Temps(Temp_water);
[Air_min, Temp_air] = min(Input_air);  Temp_minAir = Temps(Temp_air);
[Cells_min, Temp_cells] = min(cellNum); Temp_minCells = Temps(Temp_cells);

% optimized outputs
[Steam_min, Temp_steam] = min(Output_Steam);  Temp_minSteam = Temps(Temp_steam);
[CO2_min, Temp_CO2] = min(Output_CO2);  Temp_minCO2 = Temps(Temp_CO2);
[CO_min, Temp_CO] = min(CO_fuelref);  Temp_minCO = Temps(Temp_CO);
[RejectedHeat_min, Temp_heat] = min(RejectedHeat);  Temp_minHeat = Temps(Temp_heat);

  % Weights
TotalWeight = LNGtank_Primary + methane_SOFC + burnerTank + burner_methane + water;
[minWeight, Temp_weight] = min(TotalWeight); Temp_minCarriage = Temps(Temp_weight);


%% plotting results
figure(1)
subplot(4,1,1)
plot(Temps, cellNum)
title('Reactant Consumption Trends')
xlabel('Temperature (Celsius)')
ylabel('Installed SOFC Cells Required (units)')
hold on
plot(Temp_minCells, Cells_min, '*')
plot(Temp_minCarriage, cellNum(Temp_weight), 'pentagram')
hold off

subplot(4,1,2)
plot(Temps, Input_LNG, 'k-')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
hold on
plot(Temp_minFuel, LNG_min, '*')
plot(Temps, methane_SOFC, 'r--', Temps, burner_methane, 'b.-')
plot(Temp_minCarriage, Input_LNG(Temp_weight), 'pentagram')
hold off
legend('Total LNG', 'Minimum LNG', 'SOFC Dedicatied LNG', 'Burner Dedicated LNG', 'Minimum Weight')

subplot(4,1,3)
plot(Temps, water)
xlabel('Temperature (Celsius)')
ylabel('Total Water Carriage (kg)')
hold on
plot(Temp_minH2O, Water_min, '*')
plot(Temp_minCarriage, water(Temp_weight), 'pentagram')
hold off

subplot(4,1,4)
plot(Temps, Input_air)
xlabel('Temperature (Celsius)')
ylabel('Total Air Consumption (kg)')
hold on
plot(Temp_minAir, Air_min, '*')
plot(Temp_minCarriage, Input_air(Temp_weight), 'pentagram')
hold off


figure(2)
subplot(4,1,1)
plot(Temps, Output_Steam)
title('Exhaust Rejection Trends')
xlabel('Temperature (Celsius)')
ylabel('Total Steam Exhaust (kg)')
hold on
plot(Temp_minSteam, Steam_min, '*')
plot(Temp_minCarriage, Output_Steam(Temp_weight), 'pentagram')
hold off

subplot(4,1,2)
plot(Temps, CO_fuelref)
xlabel('Temperature (Celsius)')
ylabel('Total CO Exhaust (kg)')
hold on
plot(Temp_minCO, CO_min, '*')
plot(Temp_minCarriage, CO_fuelref(Temp_weight), 'pentagram')
hold off

subplot(4,1,3)
plot(Temps, Output_CO2)
xlabel('Temperature (Celsius)')
ylabel('Total CO_2 Exhaust (kg)')
hold on
plot(Temp_minCO2, CO2_min, '*')
plot(Temp_minCarriage, Output_CO2(Temp_weight), 'pentagram')
hold off

subplot(4,1,4)
plot(Temps, RejectedHeat)
xlabel('Temperature (Celsius)')
ylabel('Total Waste Heat (kJ)')
hold on
plot(Temp_minHeat, RejectedHeat_min, '*')
plot(Temp_minCarriage, RejectedHeat(Temp_weight), 'pentagram')
hold off


figure(3)
plot(Temps, Input_LNG, 'k-')
title('LNG Flow Analysis')
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
hold on
plot(Temp_minFuel, LNG_min, '*')
plot(Temps, methane_SOFC, 'r--', Temps, burner_methane, 'b.-')
plot(Temp_minCarriage, Input_LNG(Temp_weight), 'pentagram')
hold off
legend('Total LNG', 'Minimum LNG Burn', 'SOFC Dedicatied LNG', 'Burner Dedicated LNG', 'Minimum Carriage')

% figure(3)
% plot(time,burner(:,1))
% hold on
% for i = 2:n
%     plot(time, burner(:,i))
% end
% hold off
% title('Burner Heat Trends')
% xlabel('Time (s)')
% ylabel('Burner Heatflow (kJ/s)')
% legend