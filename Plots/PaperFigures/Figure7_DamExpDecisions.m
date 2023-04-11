%% Dam Expansion Decisions
% September 2022

clear all;
% 0% DISCOUNT RATE
N=5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
cmap = cbrewer('qual', 'Set3', 8);
%cmap1 = cbrewer('qual', 'Set2', 8);
%cmapStat = [0.8 0.8 0.8; 0.5 0.5 0.5; 0.3 0.3 0.3];
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
cmap1 = cbrewer('qual', 'Set2', 8);
cmap2 = cbrewer('div', 'Spectral',11);
cmap3 = cbrewer('div', 'RdGy', 10);
cmap_3DR = cbrewer('seq', 'YlGnBu', 6);
%cmap_3DR = [cmap2(1,:); cmap2(3,:); cmap2(5,:); cmap2(6,:); cmap2(8,:); clrmp2(3,:); cmap2(11,:)];
%cmap_3DR = [cmap2(1,:); cmap2(6,:); cmap2(1,:); cmap2(4,:); cmap2(8,:); clrmp2(3,:); cmap2(11,:)];%cmap2(7,:); cmap2(8,:); clrmp2(3,:)];
cmapStat = [0.8 0.8 0.8; 0.5 0.5 0.5; 0.3 0.3 0.3; 0.2 0.2 0.2];

decade = {'2001-2020', '2021-2040', '2041-2060', '2061-2080', '2081-2100'};
clim = {'Dry', 'Mod', 'Wet'};
learn = {'High', 'Low'};
lbl = {'High, Dry', 'Low, Dry', 'High, Mod', 'Low, Mod', 'High, Wet', 'Low, Wet'};

Mod =  72; %70, 74
Wet = 81;
labels = {'Dry', 'Moderate', 'Wet'};
%load('OptimalPolicies_High_0DR_RunoffNov_Plan25_FlexConstraint100_15e-7_20_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
load('OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;
s_C_high = s_C;
storHigh = storage;

% indDryHigh = find(P_state_high(:,5) < Mod);
% indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
% indWetHigh = find(P_state_high(:,5) >= Wet);

% indDryHigh = find(mean(P_state_high,2) < Mod);
% indModHigh = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
% indWetHigh = find(mean(P_state_high,2) >= Wet);

indHigh{1} = find(P_state_high(:,5) < Mod);
indHigh{2} = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indHigh{3} = find(P_state_high(:,5) >= Wet);

indDryHigh = find(P_state_high(:,5) < Mod);
indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetHigh = find(P_state_high(:,5) >= Wet);

%load('OptimalPolicies_Low_0DR_RunoffNov_Plan25_FlexConstraint100_15e-7_20_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
load('OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_low = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;
s_C_low = s_C;
storLow = storage;

indLow{1} = find(P_state_low(:,5) < Mod);
indLow{2} = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indLow{3} = find(P_state_low(:,5) >= Wet);

indDryLow = find(P_state_low(:,5) < Mod);
indModLow = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetLow = find(P_state_low(:,5) >= Wet);

for b=1:2 % high/low
    if b==1
        action = actionHigh;
        s_C = s_C_high;
        ind = indHigh;
        stor = storHigh;
    elseif b==2
        action = actionLow;
        s_C = s_C_low;
        ind = indLow;
        stor = storLow;
    end
    
    s_C_bins = s_C - 0.01;
    s_C_bins(end+1) = s_C(end)+0.01;
    
    for i=1:3 % dry, mod, wet
        clear actCounts;
        clear actCounts_test;
        for k=1:5
            actCounts(k,:) = histcounts(action(ind{i},k,3), s_C_bins);
            actCounts_test(k,:) = histcounts(action(ind{i},k,3), s_C_bins);
        end

        for j=2:5
            actCounts(j,1) = actCounts(1,1);
            actCounts(j,2) = actCounts(j-1,2) - sum(actCounts(j,3:end));
            actCounts(j,3:end) = actCounts(j-1,3:end) + actCounts(j,3:end);
        end
        
        actCountsEOC((b-1)*3+i,:) = actCounts(5,:);
        
    end
end

actCountsReorder = [actCountsEOC(1,:); actCountsEOC(4,:); actCountsEOC(2,:); ...
    actCountsEOC(5,:); actCountsEOC(3,:); actCountsEOC(6,:)];
actCountsReorder = actCountsReorder ./ sum(actCountsReorder,2);

% subplot 1
figure('Position', [350 230 950 665]);
x = [1.1 1.9 3.1 3.9 5.1 5.9];
colormap(cmap);

subplot(2,1,1)
b1 = bar(x, actCountsReorder, 'stacked');
for k=1:length(b1)
    if k==1
        statStor = [120 130 140 150];
        %statStor = [140 150];
        indStor(k) = find(stor(1) == statStor);
        b1(k).FaceColor = cmapStat(indStor(k)-1,:);
    else
        flexStor = [90 100 110 120 130 140 150]; % 90, 100
        indStor(k) = find(stor(k) == flexStor);
        b1(k).FaceColor = cmap_3DR(indStor(k)-1,:);
    end
    
end
%a1 = get(gca,'YTickLabel');
%set(gca,'YTickLabel',a1, 'FontSize',12);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
t2 = strcat('Discount Rate: 0%');
xticks(x);
xticklabels(lbl);
ylabel('Frequency', 'FontSize', 16);
title(t2, 'FontSize', 16)

%capState = {'Static', 'Flex, Unexpanded', 'Flex, Exp:+10', ...
%   'Flex, Exp:+20', 'Flex, Exp:+30', 'Flex, Exp:+40', 'Flex, Exp:+50'};
for k=1:length(b1)
    if k==1
        capState(k) = strcat('Static: ', {' '}, num2str(statStor(indStor(1))), ' MCM');
    elseif k==2
        capState(k) = strcat('Flex: ', {' '}, num2str(flexStor(indStor(k))), ' MCM (Unexp.)'); %\newline
    else
        capState(k) = strcat('Flex: ', {' '}, num2str(flexStor(indStor(k))), ' MCM');
    end
end
legend(capState, 'location', 'southeast', 'FontSize', 11);

%% 3% discount rate
load('OptimalPolicies_High_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;
s_C_high = s_C;
storHigh = storage;

% indDryHigh = find(P_state_high(:,5) < Mod);
% indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
% indWetHigh = find(P_state_high(:,5) >= Wet);

% indDryHigh = find(mean(P_state_high,2) < Mod);
% indModHigh = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
% indWetHigh = find(mean(P_state_high,2) >= Wet);

indHigh{1} = find(P_state_high(:,5) < Mod);
indHigh{2} = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indHigh{3} = find(P_state_high(:,5) >= Wet);

indDryHigh = find(P_state_high(:,5) < Mod);
indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetHigh = find(P_state_high(:,5) >= Wet);

%load('OptimalPolicies_Low_0DR_RunoffNov_Plan25_FlexConstraint100_15e-7_20_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
load('OptimalPolicies_Low_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action', 's_C', 'storage');
P_state_low = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;
s_C_low = s_C;
storLow = storage;

indLow{1} = find(P_state_low(:,5) < Mod);
indLow{2} = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indLow{3} = find(P_state_low(:,5) >= Wet);

indDryLow = find(P_state_low(:,5) < Mod);
indModLow = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetLow = find(P_state_low(:,5) >= Wet);

for b=1:2 % high/low
    if b==1
        action = actionHigh;
        s_C = s_C_high;
        ind = indHigh;
        stor = storHigh;
    elseif b==2
        action = actionLow;
        s_C = s_C_low;
        ind = indLow;
        stor = storLow;
    end
    
    s_C_bins = s_C - 0.01;
    s_C_bins(end+1) = s_C(end)+0.01;
    
    for i=1:3 % dry, mod, wet
        clear actCounts;
        clear actCounts_test;
        for k=1:5
            actCounts(k,:) = histcounts(action(ind{i},k,3), s_C_bins);
            actCounts_test(k,:) = histcounts(action(ind{i},k,3), s_C_bins);
        end

        for j=2:5
            actCounts(j,1) = actCounts(1,1);
            actCounts(j,2) = actCounts(j-1,2) - sum(actCounts(j,3:end));
            actCounts(j,3:end) = actCounts(j-1,3:end) + actCounts(j,3:end);
        end
        
        actCountsEOC((b-1)*3+i,:) = actCounts(5,:);
        
    end
end

actCountsReorder = [actCountsEOC(1,:); actCountsEOC(4,:); actCountsEOC(2,:); ...
    actCountsEOC(5,:); actCountsEOC(3,:); actCountsEOC(6,:)];
actCountsReorder = actCountsReorder ./ sum(actCountsReorder,2);

% subplot 2
colormap(cmap);
subplot(2,1,2)
b1 = bar(x, actCountsReorder, 'stacked');
for k=1:length(b1)
    if k==1
        statStor = [120 130 140 150];
        %statStor = [140 150];
        indStor(k) = find(stor(1) == statStor);
        b1(k).FaceColor = cmapStat(indStor(k)-1,:);
    else
        flexStor = [90 100 110 120 130 140 150]; % 90, 100
        indStor(k) = find(stor(k) == flexStor);
        b1(k).FaceColor = cmap_3DR(indStor(k)-1,:);
    end
    
end
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
t2 = strcat('Discount Rate: 3%');
xticks(x);
xticklabels(lbl);
ylabel('Frequency', 'FontSize', 16);
title(t2, 'FontSize', 16)

% labels for each subplot
labs = {'(a)', '(b)'};
xx = [-0.4 -0.4];
yy = [2.5 1.15];
for i=1:length(labs)
    label(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 20, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end