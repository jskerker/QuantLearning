%% Dam Value of flexibility boxplots
% Last updated: 9/1/2022
%% 0% DR
clear all;
% 0% DISCOUNT RATE
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('div', 'RdGy', 10);
[clrmp2]=cbrewer('div', 'RdYlBu', 10);
lbl = {'High, Dry (A)', 'Low, Dry (B)', 'High, Mod (A)', 'Low, Mod (B)', 'High, Wet (A)', 'Low, Wet (B)'};

Mod =  72; %70, 74
Wet = 81;
labels = {'Dry', 'Wet'};

load('OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;
s_C_high = s_C;
storHigh = storage;

% indHigh{1} = find(P_state_high(:,5) < Mod);
% indHigh{2} = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
% indHigh{3} = find(P_state_high(:,5) >= Wet);

indHigh{1} = find(mean(P_state_high,2) < Mod);
indHigh{2} = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
indHigh{3} = find(mean(P_state_high,2) >= Wet);

%load('OptimalPolicies_Low_0DR_RunoffNov_Plan25_FlexConstraint100_15e-7_20_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
load('OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_low = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;
s_C_low = s_C;
storLow = storage;

% indLow{1} = find(P_state_low(:,5) < Mod);
% indLow{2} = find(P_state_low(:,5) >= Mod & P_state_low(:,5) < Wet);
% indLow{3} = find(P_state_low(:,5) >= Wet);

indLow{1} = find(mean(P_state_low,2) < Mod);
indLow{2} = find(mean(P_state_low,2) >= Mod & mean(P_state_low,2) < Wet);
indLow{3} = find(mean(P_state_low,2) >= Wet);

% Boxplot of distribution of C-D
TotalFlexHigh = sum(totalCostTimeHigh(:,:,1)/1e6, 2);
TotalStatHigh = sum(totalCostTimeHigh(:,:,2)/1e6, 2);
A = TotalStatHigh - TotalFlexHigh;

TotalFlexLow = sum(totalCostTimeLow(:,:,1)/1e6, 2);
TotalStatLow = sum(totalCostTimeLow(:,:,2)/1e6, 2);
B = TotalStatLow - TotalFlexLow;

% find max dimension
maxDim = 0;
for i=1:3
    a = length(indHigh{i});
    b = length(indLow{i});
    if a > maxDim
        maxDim = a;
    elseif b > maxDim
        maxDim = b;
    end
end

% plot figure
AB = nan(maxDim, 3, 2);
for i=1:3
    AB(1:length(indHigh{i}),i,1) = A(indHigh{i});
    AB(1:length(indLow{i}),i,2) = B(indLow{i});
end

figure('Position', [221 235 796 712]);
subplot(2,1,1)
boxchart([AB(:,1,1) AB(:,1,2) AB(:,2,1) AB(:,2,2) AB(:,3,1) AB(:,3,2)]);
hold on
s1 = scatter([1 2 3 4 5 6], [nanmean(AB(:,1,1)) nanmean(AB(:,1,2)) nanmean(AB(:,2,1)) ...
    nanmean(AB(:,2,2)) nanmean(AB(:,3,1)) nanmean(AB(:,3,2))], 80, 'k', 'filled');
plot([0 6.5], [0 0], 'k', 'LineWidth', 0.8);
xticklabels(lbl);
ylabel({'Cost Differences'; '(Static - Flex) ($M)'});
a1x = get(gca,'XTickLabel');
set(gca,'XTickLabel',a1x, 'FontSize',14);
%yticks(-20:10:30);
% a1y = get(gca,'YTickLabel');
% set(gca,'YTickLabel',a1y, 'FontSize',14);
legend([s1], {'Mean'}, 'location', 'northwest', 'FontSize', 14);
legend('boxoff');
t2 = title('Value of Flexibility: 0%');

%% Add 3% DR

% load data
load('OptimalPolicies_High_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;
s_C_high = s_C;
storHigh = storage;

% indHigh{1} = find(P_state_high(:,5) < Mod);
% indHigh{2} = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
% indHigh{3} = find(P_state_high(:,5) >= Wet);

indHigh{1} = find(mean(P_state_high,2) < Mod);
indHigh{2} = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
indHigh{3} = find(mean(P_state_high,2) >= Wet);

load('OptimalPolicies_Low_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_low = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;
s_C_low = s_C;
storLow = storage;

% indLow{1} = find(P_state_low(:,5) < Mod);
% indLow{2} = find(P_state_low(:,5) >= Mod & P_state_low(:,5) < Wet);
% indLow{3} = find(P_state_low(:,5) >= Wet);

indLow{1} = find(mean(P_state_low,2) < Mod);
indLow{2} = find(mean(P_state_low,2) >= Mod & mean(P_state_low,2) < Wet);
indLow{3} = find(mean(P_state_low,2) >= Wet);

% get total costs for A and B
TotalFlexHigh = sum(totalCostTimeHigh(:,:,1)/1e6, 2);
TotalStatHigh = sum(totalCostTimeHigh(:,:,2)/1e6, 2);
A = TotalStatHigh - TotalFlexHigh;

TotalFlexLow = sum(totalCostTimeLow(:,:,1)/1e6, 2);
TotalStatLow = sum(totalCostTimeLow(:,:,2)/1e6, 2);
B = TotalStatLow - TotalFlexLow;
% plot figure
AB = nan(maxDim, 3, 2);

for i=1:3
    AB(1:length(indHigh{i}),i,1) = A(indHigh{i});
    AB(1:length(indLow{i}),i,2) = B(indLow{i});
end

subplot(2,1,2)
boxchart([AB(:,1,1) AB(:,1,2) AB(:,2,1) AB(:,2,2) AB(:,3,1) AB(:,3,2)]);
hold on
s1 = scatter([1 2 3 4 5 6], [nanmean(AB(:,1,1)) nanmean(AB(:,1,2)) nanmean(AB(:,2,1)) ...
    nanmean(AB(:,2,2)) nanmean(AB(:,3,1)) nanmean(AB(:,3,2))], 80, 'k', 'filled');
plot([0 6.5], [0 0], 'k', 'LineWidth', 0.8);
xticklabels(lbl);
ylabel({'Cost Differences'; '(Static - Flex) ($M)'});
a1x = get(gca,'XTickLabel');
set(gca,'XTickLabel',a1x, 'FontSize',14);
% a1y = get(gca,'YTickLabel');
% set(gca,'YTickLabel',a1y, 'FontSize',14);
t2 = title('Value of Flexibility: 3%');

% labels for each subplot
labs = {'(a)', '(b)'};
xx = [-0.4 -0.4];
yy = [66 25];
for i=1:length(labs)
    label(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 20, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end