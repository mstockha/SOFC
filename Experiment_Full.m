%% User Inputs

dt = 1;             % time step (seconds)
A = 500;            % cell reacting area (cm^2)
delTemp = 10;        % temperature step for iteration


%% Mission Data

load("FC_power_required.mat");          % load data workspace

% Load mission data
load("mission_t_v_h.mat");
M = mission_t_v_h(3,:);         % altitude (m)
V = mission_t_v_h(2,:);         % velocity (m/s)

% set power consumption time scale for plotting
time_scale = 0:8639;
time = time_scale.*dt;


%% test data - % rows = temperatures, columns = power splits
% SOFC ops temp
Temps = 600:delTemp:1000;   n = length(Temps);
Splits = 0.05:0.05:1;          m = length(Splits);

% allocate solution matrices
    % Minimum Cell Number
cellNum = zeros(m,n);
    % LNG Values
LNG_SOFC = zeros(m,n); 
LNG_Turbine = zeros(m,n); 
LNG_Duct = zeros(m,n);
LNG_Total = zeros(m,n);
    % Liquid Water Values
waterTank = zeros(m,n);
    % Steam Values
steam_SOFC = zeros(m,n); 
steam_turbine = zeros(m,n); 
steam_duct = zeros(m,n);
steam_Total = zeros(m,n);
    % Air Values
air_SOFC = zeros(m,n); 
air_turbine = zeros(m,n); 
air_duct = zeros(m,n);
air_Total = zeros(m,n);
BypassRatio = zeros(m,n);
    % Carbon Dioxide Values
dioxide_FR = zeros(m,n);
dioxide_turbine = zeros(m,n);
dioxide_duct = zeros(m,n);
dioxide_Total = zeros(m,n);
    % Carbon Monoxide Values
monoxide_FR = zeros(m,n);
    % Heat Exchange Values
heat_FR = zeros(m,n);
heat_steam = zeros(m,n);
heat_air = zeros(m,n);
heat_duct = zeros(m,n);
heat_LNG = zeros(m,n);
heat_rejected = zeros(m,n);
heat_turbine = zeros(m,n);
heat_SOFC = zeros(m,n);
    % Tank Mass
tank_SOFC = zeros(m,n);
tank_Turbine = zeros(m,n);
tank_DuctBurner = zeros(m,n);
Tank_Carriage = zeros(m,n);

%% data collection
for j = 1:n
    for k = 1:m
    fprintf('\nj = %i, k = %i\n', j, k)
    fprintf('Temperature = %i, Power Split = %.2f\n',Temps(j), Splits(k))
    % determine power for turbine and SOFC
        % total kW power consumed --> W power consumed from SOFC
    E = thrust_power_required(2,:).*Splits(k).*1000;
        % total kW power consumed --> W power consumed from turbine
    P = thrust_power_required(2,:).*(1-Splits(k)).*1000;

    % for negative power consumption values, set power to zero
    for i = 1:8640
        if E(i)<0
            E(i)=0;
        end
    end   

    % call SOFC driver to run analyses
    [Turbine_Model, SOFC_Model, FuelReformation, SteamRecycling, ...
        HeatFlow, DuctBurnHeater, TankMass, SystemReactants] = ...
        SOFCdriver(Temps(j), E, P, dt, A);
    % preserve data
        % Cell Number
    cellNum(j,k) = SOFC_Model.Specs.CellNum;
        % LNG Values
    LNG_SOFC(j,k) = FuelReformation.ReactantTotals.LNG; 
    LNG_Turbine(j,k) = sum(Turbine_Model.Inflow.LNG .* dt); 
    LNG_Duct(j,k) = sum(DuctBurnHeater.InflowLNG .* dt);
    LNG_Total(j,k) = SystemReactants.LNG;
        % Liquid Water Values
    waterTank(j,k) = SteamRecycling.Performance.WaterCarriage;
        % Steam Values
    steam_SOFC(j,k) = SOFC_Model.Reactants.TotalSteam; 
    steam_turbine(j,k) = sum(Turbine_Model.Outflow.Steam .* dt); 
    steam_duct(j,k) = sum(DuctBurnHeater.OutflowSteam .* dt);
    steam_Total(j,k) = SystemReactants.Steam;
        % Air Values
    air_SOFC(j,k) = SOFC_Model.Reactants.TotalInflow_Air; 
    air_turbine(j,k) = sum(Turbine_Model.Inflow.Air .* dt); 
    air_duct(j,k) = sum(DuctBurnHeater.InflowAir .* dt);
    air_Total(j,k) = SystemReactants.AirTotal;
    BypassRatio(j,k) = mean(SOFC_Model.Performance.BypassRatio);
        % Carbon Dioxide Values
    dioxide_FR(j,k) = FuelReformation.ReactantTotals.CarbonDiox;
    dioxide_turbine(j,k) = sum(Turbine_Model.Outflow.CarbonDiox.*dt);
    dioxide_duct(j,k) = sum(DuctBurnHeater.OutflowCarbonDiox .* dt);
    dioxide_Total(j,k) = SystemReactants.CarbonDiox;
        % Carbon Monoxide Values
    monoxide_FR(j,k) = SystemReactants.CarbonMonox;
        % Heat Exchange Values
    heat_turbine(j,k) = sum(dt.*Turbine_Model.Outflow.Heat);
    heat_SOFC(j,k) = SOFC_Model.Reactants.TotalHeat;
    heat_duct(j,k) = sum(dt.*HeatFlow.Burner);
    heat_FR(j,k) = FuelReformation.ReactantTotals.HeatRequired;
    heat_LNG(j,k) = sum(dt.*HeatFlow.LNG);
    heat_steam(j,k) = sum(dt.*HeatFlow.Steam);
    heat_air(j,k) = sum(dt.*HeatFlow.Air);
    heat_rejected(j,k) = HeatFlow.NetHeat_Rejected;
        % Tank Mass
    tank_SOFC(j,k) = TankMass.Primary_SOFC;
    tank_Turbine(j,k) = TankMass.Turbine;
    tank_DuctBurner(j,k) = TankMass.DuctBurner;
    Tank_Carriage(j,k) = TankMass.Total;
    end
end


% %% Analyze Results

% % optimized inputs
% [LNG_min, Temp_LNG] = min(LNG_Total);  Temp_minFuel = Temps(Temp_LNG);
% [Turbine_min, Temp_Turbine] = min(LNG_Turbine);  Temp_minTurbine = Temps(Temp_Turbine);
% [SOFC_min, Temp_SOFC] = min(LNG_SOFC);  Temp_minSOFC = Temps(Temp_SOFC);
% [Duct_min, Temp_Duct] = min(LNG_Duct);  Temp_minDuct = Temps(Temp_Duct);
% 
% [Water_min, Temp_water] = min(waterTank);  Temp_minH2O = Temps(Temp_water);
% [Air_min, Temp_air] = min(air_Total);  Temp_minAir = Temps(Temp_air);
% [Cells_min, Temp_cells] = min(cellNum); Temp_minCells = Temps(Temp_cells);
% 
% % optimized outputs
% [Steam_min, Temp_steam] = min(steam_Total);  Temp_minSteam = Temps(Temp_steam);
% [CO2_min, Temp_CO2] = min(dioxide_Total);  Temp_minCO2 = Temps(Temp_CO2);
% [CO_min, Temp_CO] = min(monoxide_FR);  Temp_minCO = Temps(Temp_CO);
% [RejectedHeat_min, Temp_heat] = min(heat_rejected);  Temp_minHeat = Temps(Temp_heat);
% 
% 
% %% plotting results
% figure(1)
% plot(Temps, cellNum(:,1))
% hold on
% for k = 2:m
%     plot(Temps, cellNum(:,k))
% end
% hold off
% title('Reactant Consumption Trends')
% xlabel('Temperature (Celsius)')
% ylabel('Installed SOFC Cells Required (units)')
% legend('PS = 0', '0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', ...
%     '0.4', '0.45', '0.5', '0.55', '0.6', '0.65', '0.7', '0.75', ...
%     '0.8', '0.85', '0.9', '0.95', '1.0')
% 
% 
% figure(2)
% plot(Temps, LNG_Total(:,k), 'k-')
% hold on
% for k = 2:m
%     plot(Temps, LNG_Total(:,k))
% end
% hold off
% xlabel('Temperature (Celsius)')
% ylabel('Total Methane Consumed (kg)')
% legend('PS = 0', '0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', ...
%     '0.4', '0.45', '0.5', '0.55', '0.6', '0.65', '0.7', '0.75', ...
%     '0.8', '0.85', '0.9', '0.95', '1.0')
% 
% % subplot(4,1,3)
% % plot(Temps, waterTank)
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Water Carriage (kg)')
% % 
% % subplot(4,1,4)
% % plot(Temps, air_Total)
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Air Consumption (kg)')
% 
% 
% % figure(2)
% % subplot(4,1,1)
% % plot(Temps, steam_Total)
% % title('Exhaust Rejection Trends')
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Steam Exhaust (kg)')
% % 
% % subplot(4,1,2)
% % plot(Temps, monoxide_FR)
% % xlabel('Temperature (Celsius)')
% % ylabel('Total CO Exhaust (kg)')
% % 
% % subplot(4,1,3)
% % plot(Temps, dioxide_Total)
% % xlabel('Temperature (Celsius)')
% % ylabel('Total CO_2 Exhaust (kg)')
% % 
% % subplot(4,1,4)
% % plot(Temps, heat_rejected)
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Waste Heat (kJ)')
% 
% 
% figure(3)
% plot(Temps, LNG_Total(:,1), '-', Temps, LNG_Turbine(:,1), '--')
% hold on
% plot(Temps, LNG_SOFC(:,1),':', Temps, LNG_Duct(:,2), '.-')
% for k = 2:m
%     plot(Temps, LNG_Total(:,k), '-', Temps, LNG_Turbine(:,k), '--')
%     hold on
%     plot(Temps, LNG_SOFC(:,k),':', Temps, LNG_Duct(:,k), '.-')
% end
% legend('PS = 0', '0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', ...
%     '0.4', '0.45', '0.5', '0.55', '0.6', '0.65', '0.7', '0.75', ...
%     '0.8', '0.85', '0.9', '0.95', '1.0')
% 
% % subplot(4,1,1)
% % plot(Temps, LNG_Total, 'k-')
% % title('Total LNG Flow')
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Methane Consumed (kg)')
% % 
% % subplot(4,1,2)
% % plot(Temps, LNG_Turbine, 'k-')
% % title('Turbine LNG Flow')
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Methane Consumed (kg)')
% % legend('', 'Minimum Turbine LNG')
% % 
% % subplot(4,1,3)
% % plot(Temps, LNG_SOFC, 'k-')
% % title('SOFC LNG Flow')
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Methane Consumed (kg)')
% % 
% % subplot(4,1,4)
% % plot(Temps, LNG_Duct, 'k-')
% % title('Burner LNG Flow')
% % xlabel('Temperature (Celsius)')
% % ylabel('Total Methane Consumed (kg)')
% 
% 
% figure(4)
% yyaxis left
% plot(Temps, air_Total(:,1), '-', Temps, air_turbine(:,1), '--')
% hold on
% plot(Temps, air_SOFC(:,1), ':', Temps, air_duct(:,1), '.-')
% for k = 1:m
%     plot(Temps, air_Total(:,k), '-', Temps, air_turbine(:,k), '--')
%     hold on
%     plot(Temps, air_SOFC(:,k), ':', Temps, air_duct(:,k), '.-')
% end
% hold off
% title('Air Flow Analysis')
% xlabel('Temperature (Celsius)')
% ylabel('Total Air Consumed (kg)')
% 
% yyaxis right
% plot(Temps, BypassRatio(:,1))
% ylabel('Bypass Ratio')
% legend('Total Airflow', 'Turbine Airflow', 'SOFC Airflow', 'Duct Burn Flow')
% for k = 2:m
%     plot(Temps, BypassRatio(:,k))
% end
% legend('PS = 0', '0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', ...
%     '0.4', '0.45', '0.5', '0.55', '0.6', '0.65', '0.7', '0.75', ...
%     '0.8', '0.85', '0.9', '0.95', '1.0')
% 
% 
% figure(5)
% plot(Temps, steam_Total(:,1), '-', Temps, steam_turbine(:,1), '--')
% hold on
% plot(Temps, steam_SOFC(:,1), ':', Temps, steam_duct(:,1), '.-')
% for k = 1:m
%     plot(Temps, steam_Total(:,k), '-', Temps, steam_turbine(:,k), '--')
%     hold on
%     plot(Temps, steam_SOFC(:,k), ':', Temps, steam_duct(:,k), '.-')
% end
% hold off
% title('Steam Flow Analysis')
% xlabel('Temperature (Celsius)')
% ylabel('Total Steam Output (kg)')
% legend('Total Steam', 'Turbine Steam', 'SOFC Steam', 'Duct Burn Steam')
% 
% 
% figure(6)
% plot(Temps, dioxide_Total(:,1), '-', Temps, dioxide_turbine(:,1), '--')
% hold on
% plot(Temps, dioxide_SOFC(:,1), ':', Temps, dioxide_duct(:,1), '.-')
% for k = 1:m
%     plot(Temps, dioxide_Total(:,k), '-', Temps, dioxide_turbine(:,k), '--')
%     hold on
%     plot(Temps, dioxide_SOFC(:,k), ':', Temps, dioxide_duct(:,k), '.-')
% end
% hold off
% title('Carbon Dioxide Analysis')
% xlabel('Temperature (Celsius)')
% ylabel('Total CO_2 Output (kg)')
% legend('Total CO_2', 'Turbine CO_2', 'Fuel Reformer CO_2', 'Duct Burn CO_2')
% xlim([600,1000])
% 
% 
% figure(7)
% plot(Temps, heat_rejected(:,1))
% hold on
% for k = 2:m
%     plot(Temps, heat_rejected(:,k))
% end
% hold off
% title('Heat Exhausted Analysis')
% xlabel('Temperature (Celsius)')
% ylabel('Total Heat Rejected to Exhaust (kJ)')
% legend('PS = 0', '0.05', '0.1', '0.15', '0.2', '0.25', '0.3', '0.35', ...
%     '0.4', '0.45', '0.5', '0.55', '0.6', '0.65', '0.7', '0.75', ...
%     '0.8', '0.85', '0.9', '0.95', '1.0')

