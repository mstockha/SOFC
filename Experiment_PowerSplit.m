%% test data
% power splits
Splits = 0.3:0.05:1;
n = length(Splits);

% SOFC ops temp
Temps = 780;

% allocate solution matrices
methane = zeros(1,n);
LNGtank = zeros(1,n);
RejectedHeat = zeros(1,n);
water = zeros(1,n);
steam = zeros(1,n);
burner = zeros(8640,n);
cellNum = zeros(1,n);

%% data collection
for i = 1
    for j = 1:n
        i,j
        [totalmethane, tankmass, total_heat, wmin, winitial, totalexhauststeam, burnerheat, time, cells] = SOFCdriver(Temps, 0.98, 1, Splits(j));
        methane(i,j) = totalmethane;
        LNGtank(i,j) = tankmass;
        RejectedHeat(i,j) = total_heat;
        water(i,j) = wmin;
        steam(i,j) = totalexhauststeam;
        burner(:,j) = burnerheat;
        cellNum(i,j) = cells;
    end
end
%%
% % for i = n:-1:1
% %     if methane(i) == 0
% %         methane(i) = [];
% %         LNGtank(i) = [];
% %         RejectedHeat(i) = [];
% %         water(i) = [];
% %         steam(i) = [];
% %         Temps(i) = [];
% %     end
% % end
% 
[LNG_min, Temp_LNG] = min(methane);  Split_minFuel = Splits(Temp_LNG);
[Water_min, Temp_water] = min(water);  Split_minH2O = Splits(Temp_water);
[Steam_min, Temp_steam] = min(steam);  Split_minSteam = Splits(Temp_steam);
[Cells_min, Temp_cells] = min(cellNum); Split_minCells = Splits(Temp_cells);

%% plotting results
figure(1)
title('Reactant Consumption Trends')
subplot(3,1,1)
plot(Splits, cellNum)
xlabel('Temperature (Celsius)')
ylabel('Installed SOFC Cells Required (units)')
% hold on
% plot(Split_minCells, Cells_min, 'pentagram')
% hold off

subplot(3,1,2)
plot(Splits, methane)
xlabel('Temperature (Celsius)')
ylabel('Total Methane Consumed (kg)')
% hold on
% plot(Split_minFuel, LNG_min, 'pentagram')
% hold off

subplot(3,1,3)
plot(Splits, water)
xlabel('Temperature (Celsius)')
ylabel('Total Steam Consumed (kg)')
% hold on
% plot(Split_minH2O, Water_min, 'pentagram')
% hold off


figure(2)
title('Product Rejection Trends')
subplot(2,1,1)
plot(Splits, steam)
xlabel('Temperature (Celsius)')
ylabel('Total Steam Exhaust (kg)')

subplot(2,1,2)
plot(Splits, RejectedHeat)
xlabel('Temperature (Celsius)')
ylabel('Total Waste Heat (kg)')

figure(3)
plot(time,burner(:,1))
hold on

for i = 3:2:n
    plot(time, burner(:,i))
end

hold off
title('Burner Heat Trends')
xlabel('Time (s)')
ylabel('Burner Heatflow (kJ/s)')
legend