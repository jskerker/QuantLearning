%% KL divergence boxplots for prior/prediction/information years
% Updated: January 2022

%decades = { '1990', '2010', '2030', '2050', '2070', '2090'};
N=5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
%colors = [clrmp2(3,:); clrmp3(3,:); clrmp1(3,:)];
colors = [clrmp1(5,:); clrmp2(5,:); clrmp1(3,:); clrmp2(3,:)];

% Prior year: 1990, Prediction Year: 2090

% load data
learning = {'High', 'Med', 'Low'};
climate = {'Dry', 'Mod', 'Wet'};
Mod =  72; %70, 74
Wet = 81;

%cd(strcat(projpath, '/Multiflex_expansion_SDP/ForSherlock_3DR'));
count = 1;
fileName = {'OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat',...
    'OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_19_Aug_2022.mat'};
for b=1:2 % policy
    load(fileName{b}, 'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt', 'P_state', 'rndSamps');
    KLDiv_Precip(:,:,b) = KLDiv_Precip_Simple;
    KLDiv_Yield(:,:,b) = KLDiv_Yield_Log_Opt;
    P_state_all(:,:,b) = P_state(rndSamps,:);
    
    ind{b,1} = find(P_state_all(:,5,b) < Mod);
    ind{b,2} = find(P_state_all(:,5,b) >= Mod & P_state_all(:,5,b) < Wet);
    ind{b,3} = find(P_state_all(:,5,b) >= Wet);
end

indHigh{1} = find(P_state_all(:,5,1) < Mod);
indHigh{2} = find(P_state_all(:,5,1) >= Mod & P_state_all(:,5,1) < Wet);
indHigh{3} = find(P_state_all(:,5,1) >= Wet);

indLow{1} = find(P_state_all(:,5,2) < Mod);
indLow{2} = find(P_state_all(:,5,2) >= Mod & P_state_all(:,5,2) < Wet);
indLow{3} = find(P_state_all(:,5,2) >= Wet);

%% try formatting KL div data as a table for scatter plot

varTypes = {'double', 'double', 'string'};
TblTest = table('Size', [8000 3], 'VariableTypes', varTypes, 'VariableNames', {'Yr', 'KLD', 'Lrn'});
ind2 = 0:1000:8000;
cols = [4,7,9,10];
for j=1:2 % learning: high, low
    for t=1:4 % time periods
        count = (j-1)*4+t
        
        if j==1
            Lrn = repmat({'High'}, [1000 1]);
            Yr = repmat(t+0.1, [1000 1]);
        elseif j==2
            Lrn = repmat({'Low'}, [1000 1]);
            Yr = repmat(t-0.1, [1000 1]);
        end
        TblTest(ind2(count)+1:ind2(count+1),1) = array2table(Yr);
        TblTest(ind2(count)+1:ind2(count+1),2) = array2table(KLDiv_Precip(:,cols(t),j));
        TblTest(ind2(count)+1:ind2(count+1),3) = array2table(Lrn);
        msg = strcat('start:', num2str(ind2(count)+1), ', end:', num2str(ind2(count+1)));
        disp(msg)
    end
end
%% Updated draft w/ just high and low learning using boxchart

j=1;
figure('Position', [82 285 1135 485]);
h=subplot(1,2,1); %subplot(3,1,[1 2])
b1 = boxchart(TblTest.Yr, TblTest.KLD, 'GroupByColor', TblTest.Lrn)
b1(1).BoxWidth = 0.6;
b1(1).BoxFaceColor = clrmp4(5,:);
b1(1).MarkerColor = clrmp4(4,:);
b1(1).MarkerSize = 4;
b1(2).BoxWidth = 0.6;
b1(2).BoxFaceColor = clrmp2(4,:);
b1(2).MarkerColor = clrmp2(3,:);
b1(2).MarkerSize = 4;

    xticks(1:4);
    xticklabels({'2010', '2030', '2050', '2070'});
    xlabel('Information Year', 'FontSize', 16);
    ylabel('KL Divergence Precip.', 'FontSize', 16);
    ylim([-0.1 6]);
    a1 = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a1, 'FontSize',13);
    a2 = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a2, 'FontSize',13);
    yticks(0:10);
    yticklabels(0:10);
    if j==1
        legend([b1(1) b1(2)], ...
            {'High Learning', 'Low Learning'}, 'Location', 'northwest');
        legend('boxoff');
    end
%end

t1 = title('Prediction Year: 2090, Prior Information Year: 1990', 'FontSize', 14, 'FontWeight', 'bold');

pos = get(h, 'Position') 
%posnew = pos; posnew(2) = posnew(2) + 0.02; set(h, 'Position', posnew)

%% ssd
% %% Updated draft with just high and low learning
% 
% j=1;
% figure('Position', [70 200 1340 600]);
% h=subplot(1,2,1); %subplot(3,1,[1 2])
% %for j=1:2
%     %h = subplot(10,2,j:2:18)
%     %b1 = boxplot(KLDiv_Precip(:,[4,7,9,10],1), 'width', 0.3, 'color', ...
%      %   clrmp1(5,:), 'position', 0.8:3.8, 'Symbol', 'k+', 'OutlierSize', 2);
%      b1 = boxchart([1,3,5,7], KLDiv_Precip(:,[4,7,9,10],1));
%     %b1 = violinplot(KLDivCombo_High);
%     %set(b1, 'LineWidth', 1.8); %b1(:,:,j)
%     hold on
%     %b2 = boxplot(KLDiv_Precip(:,[4,7,9,10],2), 'width', 0.25, 'color', ...
%     %    clrmp1(2,:), 'position', 1.2:4.2, 'Symbol', 'k+', 'OutlierSize', 2);
%     b2 = boxchart(KLDiv_Precip(:,[4,7,9,10],2));
%     %b2 = violinplot(KLDivCombo_Low);
%     %set(b2, 'LineWidth', 1.8);
% 
%     xticks(1:4);
%     xticklabels({'2010', '2030', '2050', '2070'});
%     xlabel('Information Year', 'FontSize', 16);
%     ylabel('KL Divergence Precip.', 'FontSize', 16);
%     ylim([-0.1 10]);
%     a1 = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a1, 'FontSize',14);
%     a2 = get(gca,'XTickLabel');
%     set(gca,'XTickLabel',a2, 'FontSize',14);
%     yticks(0:10);
%     yticklabels(0:10);
%     if j==1
%         legend([b1(1,1) b2(1,1)], ...
%             {'High Learning', 'Low Learning'}, 'Location', 'northwest');
%         legend('boxoff');
%     end
% %end
% 
% t1 = title('Prediction Year: 2090, Prior Information Year: 1990', 'FontSize', 18, 'FontWeight', 'bold');
% 
% pos = get(h, 'Position') 
% %posnew = pos; posnew(2) = posnew(2) + 0.02; set(h, 'Position', posnew)
%% KL divergence scatter plots
%cmap = cbrewer('div', 'RdBu', 11);
cmap = cbrewer('div', 'Spectral', 11);
learning_scen = {'High', 'Med', 'Low'};
climate_scen = {'Dry', 'Moderate', 'Wet'};
learning_scen_title = {'High', 'Low'};
limits = [8 8 5 5];
DR = 3;
cost = 'Quad';
w = 3;
count = 1;
for b=1:2 % high low
    for c=1:2:3 % dry, wet
        msg = strcat('b=', num2str(b), ', c=', num2str(c));
        disp(msg);
%         fileName = strcat('Simulation_', num2str(DR), 'DR_', cost, '_', learning_scen{b},...
%             '_Policy_', sim_scen{c+(b-1)*3}, '.mat');
%         load(fileName, 'T_Precip', 'T_Temp', 'runoff', 'shortageVol_Dom', ...
%             'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt', 'rndSamps', 'P_state');

        subplot(2,4,w)
        disp(num2str(w));
        scatter(KLDiv_Precip(ind{b,c},10,b), KLDiv_Yield(ind{b,c},10,b), 25,...
        P_state_all(ind{b,c},end-1,b), 'filled');
        hold on
        plot([0 10], [0 10], '-', 'color', 'k', 'LineWidth', 0.8);
        caxis([49 119]);
        if w==8
            cbh = colorbar;
            colormap(cmap)
            cbh.Ticks = 50:20:110;
            cbh.Label.String = '2070 Precip. State';
            cbh.Label.Position(1) = 4.5;
            cbh.Label.Rotation = 270;
            cbh.Label.FontSize = 13;
            caxis([49 119]);
            cbh.Position = cbh.Position + [0.05 0 0 0];
        end
         xlim([0 limits(count)]);
         ylim([0 limits(count)]);
%         xticks(0:2:6);
%         yticks(0:2:6);
        xlabel('KL Div. Precip.', 'FontSize', 13);
        ylabel('KL Div. Shortage', 'FontSize', 13);
        a1 = get(gca,'XTick');
        set(gca,'XTick',a1, 'FontSize',13);
        a2 = get(gca,'YTickLabel');
        set(gca,'YTickLabel',a2, 'FontSize',13);
        t1 = strcat(learning_scen_title{b}, ' Learning, ', {' '}, climate_scen{c},...
            ' Climate');
        title(t1, 'FontSize', 13, 'FontWeight', 'normal');
        if count == 1
            lbl = text(7, 6.6, '1:1', 'FontSize', 12);
        end
        w = w + c;
        count = count + 1;
    end
end
t2 = text(-5.5, 12.7, 'KL Divergence Correlations for 2070 Information', 'FontSize', 14, 'FontWeight', 'bold');

% labels
% labels for each subplot
labs = {'(a)', '(b)', '(c)', '(d)', '(e)'};
xx = [-21 -8 -1.2 -8 -1.2];
yy = [12.2 12.2 12.2 5.25 5.25];
for i=1:length(labs)
    lbl(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 16, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end

%% get autocorrelation for high, dry and low, dry

% high learning, dry
b = 1;
c = 1;
[rho_high, pval_high] = corr(KLDiv_Precip(ind{b,c},10,b), KLDiv_Yield(ind{b,c},10,b));
P_high = polyfit(KLDiv_Precip(ind{b,c},10,b), KLDiv_Yield(ind{b,c},10,b), 1);

% low learning, dry
b = 2;
[rho_low, pval_low] = corr(KLDiv_Precip(ind{b,c},10,b), KLDiv_Yield(ind{b,c},10,b));
P_low = polyfit(KLDiv_Precip(ind{b,c},10,b), KLDiv_Yield(ind{b,c},10,b), 1);
