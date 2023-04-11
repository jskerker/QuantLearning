% Aug 2022
% Paper figure
% combine scatter plots w/ kl div vs 2090 precip w/ infr decisions or costs
%% Scatter plot- sort data by exp vs. no exp. - 3% DR

clear all;
clim = {'Dry', 'Wet'};
learn = {'High', 'Low'};
decades = [2010, 2030, 2050, 2070, 2090, 0];
% fileName = {'OptimalPolicies_KLD_High07_Mar_2022.mat',...
%     'OptimalPolicies_KLD_Low07_Mar_2022.mat'};
fileName = {'OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat',...
    'OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat'};

fileName_3DR = {'OptimalPolicies_High_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat',...
    'OptimalPolicies_Low_3DR_RunoffNov_BayesTMs_V2_Plan50_NoConst_6e-6_03_Aug_2022.mat'};


Mod = 72; %72
Wet = 81; % 81

for i=1:2 % dry/wet
    %for j=1:2 % high/low
%         fileName = strcat('Simulation_', learn{j}, '_Policy_',...
%             learn{j}, '_', clim{i}, '.mat');
%         disp(fileName);
        load(fileName{i}, 'P_state', 'rndSamps', 'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt');
        load(fileName_3DR{i}, 'storage', 'action', 'C_state');
        %load(fileName2{i}, 'action', 'storage', 'C_state');
        
        %rndSamps = rndSamps(1:500);
        
        % Precip
        Pdata_all{i} = P_state(rndSamps,:);
        Pdata = P_state(rndSamps,:);
        P_Mean = mean(Pdata, 2);
        P_2090 = Pdata(:,5);
        P_Mean_all{i} = P_Mean; %j+(i-1)*2
        P_2090_all{i} = P_2090;
        
        % wet/dry indices
        indDry{i} = find(mean(Pdata,2) < Mod);
        indWet{i} = find(mean(Pdata,2) >= Wet);
        
        % KL Divergence for Precip
        KLD2030I = KLDiv_Precip_Simple(:,7);%KLDiv_Yield_Log_Opt(:,7);
        KLD2070I = KLDiv_Precip_Simple(:,10); %KLDiv_Yield_Log_Opt(:,10);
        KLD2030_Prec{i} = KLD2030I;
        KLD2070_Prec{i} = KLD2070I;
        
        % KL Divergence for Shortages
        KLD2030I = KLDiv_Yield_Log_Opt(:,7);
        KLD2070I = KLDiv_Yield_Log_Opt(:,10);
        KLD2030_Short{i} = KLD2030I;
        KLD2070_Short{i} = KLD2070I;
        
        % Exp. Volume
        expVol = storage(C_state(rndSamps,5,3));

        % Timing of Exp.
        for k=1:length(rndSamps)
            timing = find(action(rndSamps(k),:,3)>2);
            if isempty(timing)
                expTiming(k) = 0; % not sure what this should be: nan, 0, 2110?
            else
                expTiming(k) = decades(timing);
            end
        end
        
        % KL divergence data sorting for scatter plots
        indExp{i} = find(expVol > 100);
        indNoExp{i} = find(expVol == 100); %j+(i-1)*2
        
    %end
end

% KLD vs. Precip- 2070I- no wet/dry separation
N=5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
[clrmp5]=cbrewer('div', 'Spectral', 11);

figure('Position', [205 70 1185 680]);
%labelKLD = {'2030I', '2050I', '2070I'};
i = 1;

data = KLD2070_Prec;
labelKLD = '2070I';
DR = ', 3%';
lab1 = 'KL Divergence for Precipitation:';
subplot(2,2,3)
s1 = scatter(P_2090_all{i}(indExp{i}), data{i}(indExp{i}), 25,clrmp5(4,:),'filled'); % high
hold on
s2 = scatter(P_2090_all{i+1}(indExp{i+1}), data{i+1}(indExp{i+1}), 25,clrmp1(3,:),'filled'); % low
%hold on
%s3 = scatter(P_2090_all{i}(indNoExp{i}), data{i}(indNoExp{i}), 30,clrmp3(4,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
%s4 = scatter(P_2090_all{i+1}(indNoExp{i+1}), data{i+1}(indNoExp{i+1}),30,clrmp4(5,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.6);

xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
ylabel('KL Divergence', 'FontSize', 14);
xlim([40 120]);
ylim([0 7]);
t1 = strcat(lab1, {' '}, labelKLD, DR);
title(t1, 'FontSize', 16);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
% l1 = legend([s1(1), s2(1), s3(1), s4(1)], {'High, Expansion', 'Low, Expansion', 'High, No Expansion', 'Low, No Expansion'},...
%     'FontSize', 13, 'location', 'northwest');
% l1.Box = 'off';
%l1.Position = [0.7787 0.7520 0.1232 0.1570];


% water shortages
data = KLD2070_Short;
lab2 = 'KL Divergence for Water Shortages:';
subplot(2,2,4) % dry
s1 = scatter(P_2090_all{i}(indExp{i}), data{i}(indExp{i}), 25,clrmp5(4,:),'filled'); % high
hold on
s2 = scatter(P_2090_all{i+1}(indExp{i+1}), data{i+1}(indExp{i+1}), 25,clrmp1(3,:),'filled'); % low
%hold on
%s3 = scatter(P_2090_all{i}(indNoExp{i}), data{i}(indNoExp{i}), 30,clrmp3(4,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
%s4 = scatter(P_2090_all{i+1}(indNoExp{i+1}), data{i+1}(indNoExp{i+1}),30,clrmp4(5,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.6);

xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
ylabel('KL Divergence', 'FontSize', 14);
xlim([40 120]);
ylim([0 7]);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
t1 = strcat(lab2, {' '}, labelKLD, DR);
title(t1, 'FontSize', 16);

% l2 = legend([s1(1), s2(1), s3(1), s4(1)], {'High, Expansion', 'Low, Expansion', 'High, No Expansion', 'Low, No Expansion'},...
%     'FontSize', 13, 'location', 'northeast');
% l2.Box = 'off';
%l2.Position = [0.7787 0.7520 0.1232 0.1570];

% labels a-d
labs = {'(a)', '(b)', '(c)', '(d)'};
xx = [-78 27 -78 27];
yy = [17.7 17.7 8.2 8.2];
for i=1:length(labs)
    label(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 20, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end
%% Scatter plot- sort data by static vs flex - 0% DR
% can also uncomment things so that it's exp vs no exp

clear all;
clim = {'Dry', 'Wet'};
learn = {'High', 'Low'};
decades = [2010, 2030, 2050, 2070, 2090, 0];
% fileName = {'OptimalPolicies_KLD_High07_Mar_2022.mat',...
%     'OptimalPolicies_KLD_Low07_Mar_2022.mat'};
fileName = {'OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat',...
    'OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat'};

Mod = 72; %72
Wet = 81; % 81

for i=1:2 % dry/wet
    %for j=1:2 % high/low
%         fileName = strcat('Simulation_', learn{j}, '_Policy_',...
%             learn{j}, '_', clim{i}, '.mat');
%         disp(fileName);
        load(fileName{i}, 'P_state', 'rndSamps', 'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt',...
            'storage', 'action', 'C_state');
        
        %rndSamps = rndSamps(1:500);
        
        % Precip
        Pdata_all{i} = P_state(rndSamps,:);
        Pdata = P_state(rndSamps,:);
        P_Mean = mean(Pdata, 2);
        P_2090 = Pdata(:,5);
        P_Mean_all{i} = P_Mean; %j+(i-1)*2
        P_2090_all{i} = P_2090;
        
        % wet/dry indices
        indDry{i} = find(mean(Pdata,2) < Mod);
        indWet{i} = find(mean(Pdata,2) >= Wet);
        
        % KL Divergence for Precip
        KLD2030I = KLDiv_Precip_Simple(:,7);%KLDiv_Yield_Log_Opt(:,7);
        KLD2070I = KLDiv_Precip_Simple(:,10); %KLDiv_Yield_Log_Opt(:,10);
        KLD2030_Prec{i} = KLD2030I;
        KLD2070_Prec{i} = KLD2070I;
        
        % KL Divergence for Shortages
        KLD2030I = KLDiv_Yield_Log_Opt(:,7);
        KLD2070I = KLDiv_Yield_Log_Opt(:,10);
        KLD2030_Short{i} = KLD2030I;
        KLD2070_Short{i} = KLD2070I;
        
        % Exp. Volume
        expVol = storage(C_state(rndSamps,5,3));
        
        % Static vs. Flex
        indStat{i} = find(action(rndSamps,1,3) == 1);
        indFlex{i} = find(action(rndSamps,1,3) == 2);

        % Timing of Exp.
        for k=1:length(rndSamps)
            timing = find(action(rndSamps(k),:,3)>2);
            if isempty(timing)
                expTiming(k) = 0; % not sure what this should be: nan, 0, 2110?
            else
                expTiming(k) = decades(timing);
            end
        end
        
        % KL divergence data sorting for scatter plots
        indExp{i} = find(expVol > 100);
        indNoExp{i} = find(expVol == 100); %j+(i-1)*2
        
    %end
end

% KLD vs. Precip- 2070I- no wet/dry separation
N=5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
[clrmp5]=cbrewer('div', 'Spectral', 11);

%figure('Position', [120 245 1270 430]);
%labelKLD = {'2030I', '2050I', '2070I'};
i = 1;

data = KLD2070_Prec;
labelKLD = '2070I';
lab1 = 'KL Divergence for Precipitation:';
DR = ', 0%';
subplot(2,2,1)
s1 = scatter(P_2090_all{i}(indExp{i}), data{i}(indExp{i}), 25,clrmp5(4,:),'filled'); % high
hold on
s2 = scatter(P_2090_all{i+1}(indExp{i+1}), data{i+1}(indExp{i+1}), 25,clrmp1(3,:),'filled'); % low
%hold on
%s3 = scatter(P_2090_all{i}(indNoExp{i}), data{i}(indNoExp{i}), 30,clrmp3(4,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
%s4 = scatter(P_2090_all{i+1}(indNoExp{i+1}), data{i+1}(indNoExp{i+1}),30,clrmp4(5,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.6);

% s7 = scatter(P_2090_all{i}(indFlex{i}), data{i}(indFlex{i}), 30, clrmp3(4,:), '^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.8)%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
% s8 = scatter(P_2090_all{i+1}(indFlex{i+1}), data{i+1}(indFlex{i+1}), 30, clrmp5(4,:), '^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.8)
% 
% s5 = scatter(P_2090_all{i}(indStat{i}), data{i}(indStat{i}), 10,'k', 'filled')%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% s6 = scatter(P_2090_all{i+1}(indStat{i+1}), data{i+1}(indStat{i+1}), 10,[0.5 0.5 0.5], 'filled')%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);

xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
ylabel('KL Divergence', 'FontSize', 14);
xlim([40 120]);
ylim([0 7]);
t1 = strcat(lab1, {' '}, labelKLD, DR);
title(t1, 'FontSize', 16);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
%l1 = legend([s1(1), s2(1), s3(1), s4(1)], {'High, Expansion', 'Low, Expansion', 'High, No Expansion', 'Low, No Expansion'},...
 %   'FontSize', 13, 'location', 'northwest');
%l1.Box = 'off';
%l1.Position = [0.7787 0.7520 0.1232 0.1570];

% subplot(2,2,2) % wet
% scatter(P_2090_all{i+2}(indNoExp{i+2}), data{i+2}(indNoExp{i+2}), 30,clrmp3(4,:),'d', 'LineWidth', 1.1);
% hold on
% scatter(P_2090_all{i+3}(indNoExp{i+3}), data{i+3}(indNoExp{i+3}),30,clrmp4(5,:),'d', 'LineWidth', 1.1);
% scatter(P_2090_all{i+2}(indExp{i+2}), data{i+2}(indExp{i+2}), 25,clrmp5(4,:),'filled'); % high
% hold on
% scatter(P_2090_all{i+3}(indExp{i+3}), data{i+3}(indExp{i+3}), 25, clrmp1(3,:),'filled'); % low
% xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
% ylabel('KL Divergence', 'FontSize', 14);
% ylim([0 6]);
% a1 = get(gca,'YTickLabel');
% set(gca,'YTickLabel',a1, 'FontSize',14);
% a2 = get(gca,'XTickLabel');
% set(gca,'XTickLabel',a2, 'FontSize',14);
% 
% t1 = strcat(lab1, {' '}, labelKLD, {' '}, clim{2});
% title(t1, 'FontSize', 16);


% water shortages
data = KLD2070_Short;
lab2 = 'KL Divergence for Water Shortages:';
subplot(2,2,2) % dry
s1 = scatter(P_2090_all{i}(indExp{i}), data{i}(indExp{i}), 25,clrmp5(4,:),'filled'); % high
hold on
s2 = scatter(P_2090_all{i+1}(indExp{i+1}), data{i+1}(indExp{i+1}), 25,clrmp1(3,:),'filled'); % low
%hold on
%s3 = scatter(P_2090_all{i}(indNoExp{i}), data{i}(indNoExp{i}), 30,clrmp3(4,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
%s4 = scatter(P_2090_all{i+1}(indNoExp{i+1}), data{i+1}(indNoExp{i+1}),30,clrmp4(5,:),'^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.6);

% s7 = scatter(P_2090_all{i}(indFlex{i}), data{i}(indFlex{i}), 30, clrmp3(4,:), '^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.8)%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% hold on
% s8 = scatter(P_2090_all{i+1}(indFlex{i+1}), data{i+1}(indFlex{i+1}), 30, clrmp5(4,:), '^', 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.8)
% 
% s5 = scatter(P_2090_all{i}(indStat{i}), data{i}(indStat{i}), 10,'k', 'filled')%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);
% s6 = scatter(P_2090_all{i+1}(indStat{i+1}), data{i+1}(indStat{i+1}), 10,[0.5 0.5 0.5], 'filled')%, 'LineWidth', 1.1, 'MarkerEdgeAlpha', 0.3);

xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
ylabel('KL Divergence', 'FontSize', 14);
xlim([40 120]);
ylim([0 7]);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
t1 = strcat(lab2, {' '}, labelKLD, DR);
title(t1, 'FontSize', 16);
%xlim([70 85]);
%l2 = legend([s1(1), s2(1), s3(1), s4(1)], {'High, Expansion', 'Low, Expansion', 'High, No Expansion', 'Low, No Expansion'},...
 %   'FontSize', 13, 'location', 'northwest');
%l2.Box = 'off';
%l2.Position = [0.7787 0.7520 0.1232 0.1570];

% legend for s5-s8
% l3 = legend([s5(1), s6(1), s7(1), s8(1)], {'High, Static', 'Low, Static', 'High, Flex', 'Low, Flex'},...
%    'FontSize', 13, 'location', 'northwest');
% l3.Box = 'off';
% l3.Position = [0.7787 0.7520 0.1232 0.1570];

% subplot(2,2,4) % wet
% s3 = scatter(P_2090_all{i+2}(indNoExp{i+2}), data{i+2}(indNoExp{i+2}), 30,clrmp3(4,:),'^', 'LineWidth', 1.1);
% hold on
% s4 = scatter(P_2090_all{i+3}(indNoExp{i+3}), data{i+3}(indNoExp{i+3}),30,clrmp4(5,:),'^', 'LineWidth', 1.1);
% s1 = scatter(P_2090_all{i+2}(indExp{i+2}), data{i+2}(indExp{i+2}), 25,clrmp5(4,:),'filled'); % high
% hold on
% s2 = scatter(P_2090_all{i+3}(indExp{i+3}), data{i+3}(indExp{i+3}), 25, clrmp1(3,:),'filled'); % low
% xlabel('2090 Precip (mm/mo)', 'FontSize', 14);
% ylabel('KL Divergence', 'FontSize', 14);
% a1 = get(gca,'YTickLabel');
% set(gca,'YTickLabel',a1, 'FontSize',14);
% a2 = get(gca,'XTickLabel');
% set(gca,'XTickLabel',a2, 'FontSize',14);
% ylim([0 6]);
% t1 = strcat(lab2, {' '}, labelKLD, {' '}, clim{2});
% title(t1, 'FontSize', 16);
% %xlim([70 85]);
