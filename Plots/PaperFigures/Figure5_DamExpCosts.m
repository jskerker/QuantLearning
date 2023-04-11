%% Plot expected costs looking at the simulations- break down by dry, mod, wet
% September 2022

clear all;
% 0% DISCOUNT RATE
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('div', 'RdGy', 10);
[clrmp2]=cbrewer('div', 'RdYlBu', 10);

Mod =  72; %70, 74
Wet = 81;
labels = {'Dry', 'Moderate', 'Wet'};
load('OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;

indDryHigh = find(P_state_high(:,5) < Mod);
indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetHigh = find(P_state_high(:,5) >= Wet);

% indDryHigh = find(mean(P_state_high,2) < Mod);
% indModHigh = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
% indWetHigh = find(mean(P_state_high,2) >= Wet);

% indDryHigh = find(median(P_state_high,2) < Mod);
% indModHigh = find(median(P_state_high,2) >= Mod & median(P_state_high,2) < Wet);
% indWetHigh = find(median(P_state_high,2) >= Wet);
 
% indDryHigh = find(min(P_state_high,[],2) < Mod);
% indModHigh = find(min(P_state_high,[], 2) >= Mod & min(P_state_high,[], 2) < Wet);
% indWetHigh = find(min(P_state_high,[], 2) >= Wet);

%load('OptimalPolicies_Low_3DR_Plan_31_Mar_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_Low07_Mar_2022_17_37_11.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_Low_3DR_RunoffTest_Plan_IncVarDirect_6e-6_20_Apr_2022', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
% load('OptimalPolicies_Low_0DR_RunoffNov_Plan25_FlexConstOneExp100_15e-7_29_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
load('OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
P_state_low = P_state;
P_state_high = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;

indDryLow = find(P_state_low(:,5) < Mod);
indModLow = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetLow = find(P_state_low(:,5) >= Wet);

% indDryLow = find(mean(P_state_low,2) < Mod);
% indModLow = find(mean(P_state_low,2) >= Mod & mean(P_state_low,2) < Wet);
% indWetLow = find(mean(P_state_low,2) >= Wet);

% indDryLow = find(median(P_state_low,2) < Mod);
% indModLow = find(median(P_state_low,2) >= Mod & median(P_state_low,2) < Wet);
% indWetLow = find(median(P_state_low,2) >= Wet);

% indDryLow = find(min(P_state_low,[], 2) < Mod);
% indModLow = find(min(P_state_low,[], 2) >= Mod & min(P_state_low,[], 2) < Wet);
% indWetLow = find(min(P_state_low,[], 2) >= Wet);

figure('Position', [130 170 1360 660]);
for i=1:3
    % dry, mod, wet
    if i==1
        indHigh = indDryHigh;
        indLow = indDryLow;
    elseif i==2
        indHigh = indModHigh;
        indLow = indModLow;
    elseif i==3
        indHigh = indWetHigh;
        indLow = indWetLow;
    end
    
    % get data
    dCost = [mean(damCostTimeHigh(indHigh,1,1)) mean(damCostTimeHigh(indHigh,1,2))...
    mean(damCostTimeLow(indLow,1,1)) mean(damCostTimeLow(indLow,1,2))];

    dCostExp = [mean(sum(damCostTimeHigh(indHigh,2:5,1), 2)) mean(sum(damCostTimeHigh(indHigh,2:5,2), 2))...
    mean(sum(damCostTimeLow(indLow,2:5,1), 2)) mean(sum(damCostTimeLow(indLow,2:5,2), 2))];

    sCost = [mean(sum(shortageCostTimeHigh(indHigh,1:5,1), 2)) mean(sum(shortageCostTimeHigh(indHigh,1:5,2), 2))...
    mean(sum(shortageCostTimeLow(indLow,1:5,1), 2)) mean(sum(shortageCostTimeLow(indLow,1:5,2), 2))];

    infCost = dCost + dCostExp;
    totalCost = dCost + dCostExp + sCost;
    
    % plot
    subplot(2,3,i)
    x = [1.05 1.95 3.05 3.95];
    b1 = bar(x, [dCost; dCostExp; sCost]/1e6', 'stacked', 'FaceColor', 'flat');
    for j=1:4
        b1(1).CData(j,:) = clrmp2(3,:);
        b1(2).CData(j,:) = [0.5 0.5 0.5];
        b1(3).CData(j,:) = clrmp2(8,:);
    end
    hold on
    plot([2.5 2.5], [0 max(sum([dCost; dCostExp; sCost]))/1e6*1.3], '--', 'color', 'k', 'LineWidth', 2);
    if i==1
        plot([0 4.5], [800 800], 'color', 'k', 'LineWidth', 2);
    end
    
    ylim([0 max(sum([dCost; dCostExp; sCost]))/1e6*1.3]);
    text(1.25, 1.24*max(sum([dCost; dCostExp; sCost]))/1e6, 'High', 'FontSize', 13, 'FontWeight', 'bold');
    text(3.25, 1.24*max(sum([dCost; dCostExp; sCost]))/1e6, 'Low', 'FontSize', 13, 'FontWeight', 'bold');
    xlim([0.5 4.5]);
    xticks(x);
    xticklabels({'Flexible', 'Static', 'Flexible', 'Static'});
    y1 = ylabel('Expected Cost ($M)');
    y1.FontSize = 14;
    a1 = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a1, 'FontSize',13);
    a2 = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a2, 'FontSize',13);
    t1 = strcat(labels{i}, ': 0%');
    title(t1, 'FontSize', 14);
    
%     % infr cost labels 
%     lbl1 = strcat('$', num2str(infCost(1)/1E6, 3), 'M');
%     text(0.75, 0.5*infCost(1)/1e6, lbl1, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl2 = strcat('$', num2str(infCost(2)/1E6, 3), 'M');
%     text(1.7, 0.5*infCost(2)/1e6, lbl2, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl3 = strcat('$', num2str(infCost(3)/1E6, 3), 'M');
%     text(2.75, 0.5*infCost(3)/1e6, lbl3, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl4 = strcat('$', num2str(infCost(4)/1E6, 3), 'M');
%     text(3.7, 0.5*infCost(4)/1e6, lbl4, 'FontSize', 12, 'FontWeight', 'bold');
%     
%     % shortage cost labels
%     if i < 3
%         digits = 3;
%     else
%         digits = 2;
%     end
%     lbl5 = strcat('$', num2str(sCost(1)/1E6, digits), 'M');
%     text(0.75, totalCost(1)/1E6*0.95, lbl5, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl6 = strcat('$', num2str(sCost(2)/1E6, digits), 'M');
%     text(1.7, totalCost(2)/1E6*0.95, lbl6, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl7 = strcat('$', num2str(sCost(3)/1E6, digits), 'M');
%     text(2.75, totalCost(3)/1E6*0.95, lbl7, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl8 = strcat('$', num2str(sCost(4)/1E6, digits), 'M');
%     text(3.7, totalCost(4)/1E6*0.95, lbl8, 'FontSize', 12, 'FontWeight', 'bold');
%     disp(lbl6);
%     disp(num2str(sCost(2)));
    
%     % total cost labels 
%     lbl1 = strcat('$', num2str(totalCost(1)/1E6, 3), 'M');
%     text(0.75, totalCost(1)/1E6*1.06, lbl1, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl2 = strcat('$', num2str(totalCost(2)/1E6, 3), 'M');
%     text(1.7, totalCost(2)/1E6*1.06, lbl2, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl3 = strcat('$', num2str(totalCost(3)/1E6, 3), 'M');
%     text(2.75, totalCost(3)/1E6*1.06, lbl3, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl4 = strcat('$', num2str(totalCost(4)/1E6, 3), 'M');
%     text(3.7, totalCost(4)/1E6*1.06, lbl4, 'FontSize', 10, 'FontWeight', 'bold');
end

hBLG = bar(nan(3));   
legLabels = {'Dam/Infr. Costs', 'Flex. Dam Exp. Costs', 'Shortage Costs'}; % the bar object array for legend
hBLG(1).FaceColor=clrmp2(3,:);
hBLG(2).FaceColor = [0.5 0.5 0.5];
hBLG(3).FaceColor=clrmp2(8,:);
hLG=legend(hBLG,legLabels,'location','southwest');

%% 3% Discount rate (bottom panels on plot)
%figure
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('div', 'RdGy', 10);
[clrmp2]=cbrewer('div', 'RdYlBu', 10);

Mod =  72; %72, 81
Wet = 81;
labels = {'Dry', 'Moderate', 'Wet'};
load('OptimalPolicies_High_3DR_RunoffNov_BayesTMs_V2_Plan50_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_High_0DR_RunoffTest_Plan25_IncVarDir_9e-7_20_Apr_2022', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_High_0DR_Design_Constrict_05_Apr_2022', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_High08_Mar_2022_19_31_43.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime');
%load('OptimalPolicies_High11_Mar_2022_13_30_39.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime');
P_state_high = P_state;
damCostTimeHigh = damCostTime;
shortageCostTimeHigh = shortageCostTime;
totalCostTimeHigh = totalCostTime;
actionHigh = action;

indDryHigh = find(P_state_high(:,5) < Mod);
indModHigh = find(P_state_high(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetHigh = find(P_state_high(:,5) >= Wet);

% indDryHigh = find(mean(P_state_high,2) < Mod);
% indModHigh = find(mean(P_state_high,2) >= Mod & mean(P_state_high,2) < Wet);
% indWetHigh = find(mean(P_state_high,2) >= Wet);

% indDryHigh = find(median(P_state_high,2) < Mod);
% indModHigh = find(median(P_state_high,2) >= Mod & median(P_state_high,2) < Wet);
% indWetHigh = find(median(P_state_high,2) >= Wet);
 
% indDryHigh = find(min(P_state_high,[],2) < Mod);
% indModHigh = find(min(P_state_high,[], 2) >= Mod & min(P_state_high,[], 2) < Wet);
% indWetHigh = find(min(P_state_high,[], 2) >= Wet);

load('OptimalPolicies_Low_3DR_RunoffNov_BayesTMs_V2_Plan50_6e-6_03_Aug_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_Low_0DR_Design_Constrict_05_Apr_2022.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime', 'action');
%load('OptimalPolicies_Low08_Mar_2022_19_35_00.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime');
%load('OptimalPolicies_Low11_Mar_2022_13_33_01.mat', 'P_state', 'damCostTime', 'shortageCostTime', 'totalCostTime');
P_state_low = P_state;

P_state_high = P_state;
damCostTimeLow = damCostTime;
shortageCostTimeLow = shortageCostTime;
totalCostTimeLow = totalCostTime;
actionLow = action;

indDryLow = find(P_state_low(:,5) < Mod);
indModLow = find(P_state_low(:,5) >= Mod & P_state_high(:,5) < Wet);
indWetLow = find(P_state_low(:,5) >= Wet);

% indDryLow = find(mean(P_state_low,2) < Mod);
% indModLow = find(mean(P_state_low,2) >= Mod & mean(P_state_low,2) < Wet);
% indWetLow = find(mean(P_state_low,2) >= Wet);

% indDryLow = find(median(P_state_low,2) < Mod);
% indModLow = find(median(P_state_low,2) >= Mod & median(P_state_low,2) < Wet);
% indWetLow = find(median(P_state_low,2) >= Wet);

% indDryLow = find(min(P_state_low,[], 2) < Mod);
% indModLow = find(min(P_state_low,[], 2) >= Mod & min(P_state_low,[], 2) < Wet);
% indWetLow = find(min(P_state_low,[], 2) >= Wet);

%figure('Position', [260 350 1110 485]);
for i=1:3
    % dry, mod, wet
    if i==1
        indHigh = indDryHigh;
        indLow = indDryLow;
    elseif i==2
        indHigh = indModHigh;
        indLow = indModLow;
    elseif i==3
        indHigh = indWetHigh;
        indLow = indWetLow;
    end
    
    % get data
    dCost = [mean(damCostTimeHigh(indHigh,1,1)) mean(damCostTimeHigh(indHigh,1,2))...
    mean(damCostTimeLow(indLow,1,1)) mean(damCostTimeLow(indLow,1,2))];

    dCostExp = [mean(sum(damCostTimeHigh(indHigh,2:5,1), 2)) mean(sum(damCostTimeHigh(indHigh,2:5,2), 2))...
    mean(sum(damCostTimeLow(indLow,2:5,1), 2)) mean(sum(damCostTimeLow(indLow,2:5,2), 2))];

    sCost = [mean(sum(shortageCostTimeHigh(indHigh,1:5,1), 2)) mean(sum(shortageCostTimeHigh(indHigh,1:5,2), 2))...
    mean(sum(shortageCostTimeLow(indLow,1:5,1), 2)) mean(sum(shortageCostTimeLow(indLow,1:5,2), 2))];

    infCost = dCost + dCostExp;
    totalCost = dCost + dCostExp + sCost;
    
    % plot
    subplot(2,3,i+3)
    %subplot(1,3,i)
    x = [1.05 1.95 3.05 3.95];
    b1 = bar(x, [dCost; dCostExp; sCost]/1e6', 'stacked', 'FaceColor', 'flat');
    for j=1:4
        b1(1).CData(j,:) = clrmp2(3,:);
        b1(2).CData(j,:) = [0.5 0.5 0.5];
        b1(3).CData(j,:) = clrmp2(8,:);
    end
    hold on
    plot([2.5 2.5], [0 max(sum([dCost; dCostExp; sCost]))/1e6*1.3], '--', 'color', 'k', 'LineWidth', 2);
    
    if i==1
        plot([0 4.5], [600 600], 'color', 'k', 'LineWidth', 2);
    end
    ylim([0 max(sum([dCost; dCostExp; sCost]))/1e6*1.3]);
    text(1.25, 1.24*max(sum([dCost; dCostExp; sCost]))/1e6, 'High', 'FontSize', 13, 'FontWeight', 'bold');
    text(3.25, 1.24*max(sum([dCost; dCostExp; sCost]))/1e6, 'Low', 'FontSize', 13, 'FontWeight', 'bold');
    xlim([0.5 4.5]);
    xticks(x);
    xticklabels({'Flexible', 'Static', 'Flexible', 'Static'});
    y1 = ylabel('Expected Cost ($M)');
    y1.FontSize = 14;
    a3 = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a3, 'FontSize',13);
    a4 = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a4, 'FontSize',13);
    t1 = strcat(labels{i}, ': 3%');
    title(t1, 'FontSize', 14);
    
    % infr cost labels 
%     lbl1 = strcat('$', num2str(infCost(1)/1E6, 3), 'M');
%     text(0.75, 0.5*infCost(1)/1e6, lbl1, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl2 = strcat('$', num2str(infCost(2)/1E6, 3), 'M');
%     text(1.7, 0.5*infCost(2)/1e6, lbl2, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl3 = strcat('$', num2str(infCost(3)/1E6, 3), 'M');
%     text(2.75, 0.5*infCost(3)/1e6, lbl3, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl4 = strcat('$', num2str(infCost(4)/1E6, 3), 'M');
%     text(3.7, 0.5*infCost(4)/1e6, lbl4, 'FontSize', 12, 'FontWeight', 'bold');
    
%     % shortage cost labels
%     if i < 3
%         digits = 3;
%         disp('hi');
%     else
%         digits = 2;
%     end
%     lbl5 = strcat('$', num2str(sCost(1)/1E6, digits), 'M');
%     text(0.75, totalCost(1)/1E6*0.95, lbl5, 'FontSize', 12, 'FontWeight', 'bold');
%     if i < 3
%         lbl6 = strcat('$', num2str(sCost(2)/1E6, digits), 'M');
%     else
%         lbl6 = strcat('$', num2str(sCost(2)/1E6, digits-1), 'M');
%     end
%     text(1.7, totalCost(2)/1E6*0.95, lbl6, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl7 = strcat('$', num2str(sCost(3)/1E6, digits), 'M');
%     text(2.75, totalCost(3)/1E6*0.95, lbl7, 'FontSize', 12, 'FontWeight', 'bold');
%     lbl8 = strcat('$', num2str(sCost(4)/1E6, digits), 'M');
%     text(3.7, totalCost(4)/1E6*0.95, lbl8, 'FontSize', 12, 'FontWeight', 'bold');
%     disp(lbl6);
%     disp(num2str(sCost(2)));

%     % total cost labels 
%     lbl1 = strcat('$', num2str(totalCost(1)/1E6, 3), 'M');
%     text(0.75, totalCost(1)/1E6*1.06, lbl1, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl2 = strcat('$', num2str(totalCost(2)/1E6, 3), 'M');
%     text(1.7, totalCost(2)/1E6*1.06, lbl2, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl3 = strcat('$', num2str(totalCost(3)/1E6, 3), 'M');
%     text(2.75, totalCost(3)/1E6*1.06, lbl3, 'FontSize', 10, 'FontWeight', 'bold');
%     lbl4 = strcat('$', num2str(totalCost(4)/1E6, 3), 'M');
%     text(3.7, totalCost(4)/1E6*1.06, lbl4, 'FontSize', 10, 'FontWeight', 'bold');
end

% labels for each subplot
labs = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
xx = [-11 -5.65 -0.35 -11 -5.65 -0.35];
yy = [373 373 373 170 170 170];
for i=1:length(labs)
    lbl(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 20, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end