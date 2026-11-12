clc; clear

%% User Inputs 
dt = 1;             % time step (seconds)
A = 500;            % cell reacting area (cm^2)
delTemp = 50;       % temperature step for iteration
delSplit = 0.05;    % power split step for iteration

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
Splits = 0:delSplit:1;          m = length(Splits);

% allocate solution matrices
    % Minimum Cell Number
cellNum = zeros(n,m);
    % LNG Values
LNG_SOFC = zeros(n,m); 
LNG_Turbine = zeros(n,m); 
LNG_Duct = zeros(n,m);
LNG_Total = zeros(n,m);
    % Liquid Water Values
waterTank = zeros(n,m);
    % Steam Values
steam_SOFC = zeros(n,m); 
steam_turbine = zeros(n,m); 
steam_duct = zeros(n,m);
steam_Total = zeros(n,m);
    % Air Values
air_SOFC = zeros(n,m); 
air_turbine = zeros(n,m); 
air_duct = zeros(n,m);
air_Total = zeros(n,m);
BypassRatio = zeros(n,m);
    % Carbon Dioxide Values
dioxide_FR = zeros(n,m);
dioxide_turbine = zeros(n,m);
dioxide_duct = zeros(n,m);
dioxide_Total = zeros(n,m);
    % Carbon Monoxide Values
monoxide_FR = zeros(n,m);
    % Heat Exchange Values
heat_FR = zeros(n,m);
heat_steam = zeros(n,m);
heat_air = zeros(n,m);
heat_duct = zeros(n,m);
heat_LNG = zeros(n,m);
heat_rejected = zeros(n,m);
heat_turbine = zeros(n,m);
heat_SOFC = zeros(n,m);
    % Tank Mass
tank_SOFC = zeros(n,m);
tank_Turbine = zeros(n,m);
tank_DuctBurner = zeros(n,m);
Tank_Carriage = zeros(n,m);

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

%% Plot Results wrt Power Split for each Temperature
figure(7)
plot(Splits, LNG_Total(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Total(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(8)
plot(Splits, LNG_SOFC(1,:),'--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_SOFC(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
ylim([150, 3200])
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(9)
plot(Splits, LNG_Duct(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Duct(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(10)
plot(Splits, LNG_Turbine(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Turbine(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(11)
plot(Splits, cellNum(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
hold on
for i = 2:length(Temps)
    plot(Splits, cellNum(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Installed Cell Number for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('Cell Number')


figure(12)
subplot(2,2,1)
plot(Splits, LNG_Total(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Total(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,2)
plot(Splits, LNG_SOFC(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_SOFC(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
ylim([150, 3200])
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,3)
plot(Splits, LNG_Turbine(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Turbine(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,4)
plot(Splits, LNG_Duct(1,:), '--', 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Duct(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


%% Plot Results wrt Power Split for each Temperature
figure(13)
plot(Splits, LNG_Total(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Total(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(14)
plot(Splits, LNG_SOFC(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_SOFC(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
ylim([150, 3200])
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(15)
plot(Splits, LNG_Duct(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Duct(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(16)
plot(Splits, LNG_Turbine(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Turbine(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


figure(17)
plot(Splits, cellNum(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
hold on
for i = 2:length(Temps)
    plot(Splits, cellNum(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Installed Cell Number for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('Cell Number')


figure(18)
subplot(2,2,1)
plot(Splits, LNG_Total(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Total(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,2)
plot(Splits, LNG_SOFC(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_SOFC(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
ylim([150, 3200])
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,3)
plot(Splits, LNG_Turbine(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Turbine(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')

subplot(2,2,4)
plot(Splits, LNG_Duct(1,:), 'DisplayName', sprintf('%i C', Temps(1)), LineWidth=1.5)
%plot(Splits, LNG_SOFC(1,:), Splits, LNG_Turbine(1,:), Splits, LNG_Duct(1,:))
hold on
for i = 2:length(Temps)
    plot(Splits, LNG_Duct(i,:), 'DisplayName', sprintf('%i C', Temps(i)), LineWidth=1.5)
    %plot(Splits, LNG_SOFC(i,:), Splits, LNG_Turbine(i,:), Splits, LNG_Duct(i,:))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Power Split (% Power from SOFC)')
ylabel('LNG Usage (kg)')


%% Plot Results wrt Temperature for each Power Split
figure(19)
plot(Temps, LNG_Total(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Total(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')


figure(20)
plot(Temps, LNG_SOFC(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_SOFC(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')


figure(21)
plot(Temps, LNG_Duct(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Duct(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')


figure(22)
plot(Temps, LNG_Turbine(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Turbine(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')


figure(23)
plot(Temps, cellNum(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
hold on
for i = 2:length(Splits)
    plot(Temps, cellNum(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Installed Cell Number for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('Cell Number')


figure(24)
subplot(2,2,1)
plot(Temps, LNG_Total(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Total(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
end
hold off
legend('show')
title('Total LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')

subplot(2,2,2)
plot(Temps, LNG_SOFC(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_SOFC(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('SOFC LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')

subplot(2,2,3)
plot(Temps, LNG_Turbine(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Turbine(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('Turbine LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')

subplot(2,2,4)
plot(Temps, LNG_Duct(:,1), '--', 'DisplayName', sprintf('%.2f', Splits(1)), LineWidth=1.5)
%plot(Temps, LNG_SOFC(:,1), Temps, LNG_Turbine(:,1), Temps, LNG_Duct(:,1))
hold on
for i = 2:length(Splits)
    plot(Temps, LNG_Duct(:,i), 'DisplayName', sprintf('%.2f', Splits(i)), LineWidth=1.5)
    %plot(Temps, LNG_SOFC(:,i), Temps, LNG_Turbine(:,i), Temps, LNG_Duct(:,i))
end
hold off
legend('show')
title('Duct LNG Usage for Power Split AND Temperature')
xlabel('Temperature (C)')
ylabel('LNG Usage (kg)')