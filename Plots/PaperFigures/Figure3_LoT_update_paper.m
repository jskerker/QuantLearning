%% Updated Figure 3- LoT Plot for Paper
% look at precip paths, precip and water shortages as part of KL div figure for paper

numSamp = 25000;
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};
P0_abs = 77;
s_P_abs = 49:119;
T0_abs = 26.25;
s_T_abs = [26.2500, 26.7500, 27.2500, 27.9500, 28.8000];
N = 5;
rng(0)

addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);

learning_scen = {'High', 'Med', 'Low'};
climate_scen = {'Dry', 'Moderate', 'Wet'};
learning_scen_title = {'High', 'Medium', 'Low'};
sim_scen = {'High_Dry', 'High_Mod', 'High_Wet', 'Med_Dry', 'Med_Mod', ...
    'Med_Wet', 'Low_Dry', 'Low_Mod', 'Low_Wet'};
scenarios = {'High, Dry', 'High, Mod', 'High, Wet',...
    'Medium, Dry', 'Medium, Mod', 'Medium, Wet',...
    'Low, Dry', 'Low, Mod', 'Low, Wet'};
DR = 3;
cost = 'Quad';

rndSamps = randi(10000, [50 1]);
rndSampsHighlight = [1 3 26 49; 395 2 130 167; 122 686 46 51; 17 36 25 152];
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};
alpha = rand([50 1])/2+0.5;

fig = figure('Position', [260 70 1400 695]);

% subplot shortcuts
% ts = 1;
% w = 5;
% s = 9;
% fileName = {'OptimalPolicies_KLD_High07_Mar_2022.mat',...
%     'OptimalPolicies_KLD_Low07_Mar_2022.mat'};

fileName = {'OptimalPolicies_High_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat',...
    'OptimalPolicies_Low_0DR_RunoffNov_BayesTMs_V2_Flex100_Plan25_15e-7_01_Aug_2022.mat'};

c = 1;

for b=1:2 % high, low
    load(fileName{b}, 'T_Precip', 'T_Temp', 'runoff', 'shortageVol_Dom', 'P_state');
    
    subplot(2,4,[b*2-1:b*2])
    % plot 50 random samples
    for i=1:50
        plot([repmat(77, [1 1]) P_state(rndSamps(i),:)]', 'LineWidth', 0.8, 'color', [alpha(i) alpha(i) alpha(i)]);
        %plot(P_state_high(rndSamps(i),:)', 'LineWidth', 0.8, 'color', [alpha(i) alpha(i) alpha(i)]);
        hold on
        
    end
    
    % plot a wet and dry sample
    rndDry = randi(200, 1)+1800;%2400;
    rndWet = randi(200, 1)+7400;%7400; % 7400
%     sortedP = sort(sum(P_state, 2));
%     indDry = find(sum(P_state,2) == sortedP(rndDry), 1); % 46
%     indWet = find(sum(P_state,2) == sortedP(rndWet), 1); % 49

    sortedP = sort(P_state(:,end));
    indDry = find(P_state(:,end) == sortedP(rndDry), 1);
    indWet = find(P_state(:,end) == sortedP(rndWet), 1);
    
    ln1 = plot([repmat(77, [1 1]) P_state(indDry,:)]', 'LineWidth', 3, 'color', clrmp1(4,:));
    ln2 = plot([repmat(77, [1 1]) P_state(indWet,:)]', 'LineWidth', 3, 'color', clrmp2(3,:));

    xticks(1:6);
    xticklabels(decades);
    ylim([50 110]);
    yticks(50:20:110);
    if b==1
        disp('hi')
        y1 = ylabel('Precip (mm/mo)');
    end
    a1 = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a1, 'FontSize',12);
    a2 = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a2, 'FontSize',12);
    [mnACF, medACF, acf_high] = calcAutoCorr(P_state, 1, false);
    t1 = strcat('Lag-One Autocorr: ', {' '}, num2str(mnACF, 2));
    %title(t1, 'FontSize', 12);
    disp(t1);
            
     for c=1:2 % dry, wet
        for i=1:5
            for j=1:71
                unmet_dom(i,j) = mean(shortageVol_Dom{i,j}(241:end,:), 'all')*12/1E6;
            end
        end

        % Set time series
        state_ind_P = zeros(1,N+1);
        state_ind_T = zeros(1,N); % state_ind_T = zeros(1,N+1)
        state_ind_P(1) =  find(P0_abs==s_P_abs);
        state_ind_T(1) = find(T0_abs==s_T_abs);
        randGen = true;

        MAR = cellfun(@(x) mean(mean(x)), runoff);
        p = randi(numSamp,N-1);
        P_over_time = cell(1,N);
        T_over_time = cell(1,N);
        MAR_over_time = cell(1,N);
%     
        for t = 1:N
            % Sample forward distribution given current state
            T_current = s_T_abs(state_ind_T(t));
            P_current = s_P_abs(state_ind_P(t));
            [T_over_time{t}] = T2forwardSimTemp(T_Temp, s_T_abs, N, t, T_current, numSamp, false);
            %[P_over_time{t}] = T2forwardSimPrecip(T_Precip, s_P_abs, N, t, P_current, numSamp, false);
            [P_over_time{t}] = T2forwardSimTemp(T_Precip, s_P_abs, N, t, P_current, numSamp, false);

            % Lookup MAR and yield for forward distribution
            T_ind = arrayfun(@(x) find(x == s_T_abs), T_over_time{t});
            P_ind = arrayfun(@(x) find(x == s_P_abs), P_over_time{t});
            [~,t_steps] = size(T_ind);
            MAR_over_time{t} = zeros(size(T_ind));
            yield_over_time{t} = zeros(size(T_ind));
            for i = 1:numSamp
                for j = 1:t_steps
                    MAR_over_time{t}(i,j) = MAR(T_ind(i,j), P_ind(i,j), 1);
                    yield_over_time{t}(i,j) = unmet_dom(T_ind(i,j), P_ind(i,j),1, 1) ; % flex unexpanded size (MCM)
                end
            end

        % Sample next time period
            if randGen
                state_ind_T(t+1) = find(T_over_time{t}(p(t),2)==s_T_abs);
                %state_ind_P(t+1) = find(P_over_time{t}(p(t),2)==s_P_abs);
            end
            if c == 1
                state_ind_P(2:end) = P_state(indDry,:)-s_P_abs(1)-1;
            elseif c==2
                state_ind_P(2:end) = P_state(indWet,:)-s_P_abs(1)-1;
            end
            %end
        end
    msg = strcat('b=', num2str(b), ', c=', num2str(c), ', p=', num2str(s_P_abs(state_ind_P)));
    disp(msg);
    
    for t =1:N
        x = t:N+1;
        X=[x,fliplr(x)];
        T_p01 = prctile(T_over_time{t},.01);
        T_p995 = prctile(T_over_time{t},99.9);
        P_p01 = prctile(P_over_time{t},.01);
        P_p995 = prctile(P_over_time{t},99.9);
        MAR_p01 = prctile(MAR_over_time{t},.01);
        MAR_p995 = prctile(MAR_over_time{t},99.9);
        yield_p01 = prctile(yield_over_time{t},.01);
        yield_p995 = prctile(yield_over_time{t},99.9);

        for row=3:4
            if row == 3
                subplot(4,4,(row-1)*4+(b-1)*2+c)
                Y=[P_p01,fliplr(P_p995)];
                hold on
                if c==1
                    p1 = fill(X,Y-P0_abs,clrmp1(t,:), 'LineWidth', 1);
                elseif c==2
                    p2 = fill(X,Y-P0_abs,clrmp2(t,:), 'LineWidth', 1);
                end
                scatter(t,s_P_abs(state_ind_P(t))-P0_abs, 'k', 'MarkerFaceColor', 'k')
                xticks(1:6)
                xticklabels(decades)
                if b==1 && c==1
                    y2 = ylabel('\DeltaPrecip (mm/mo)');
                end
                a1 = get(gca,'XTickLabel');
                set(gca,'XTickLabel',a1, 'FontSize',12);
                xticklabels(decades)
                ylim([-30 40])
                a2 = get(gca,'YTickLabel');
                set(gca,'YTickLabel',a2, 'FontSize',12);
            elseif row == 4
                subplot(4,4,(row-1)*4+(b-1)*2+c)

    %             if t ==1
    %                 yLabelHandle = get( gca ,'YLabel' );
    %                 pos  = get( yLabelHandle , 'position' )
    %                 pos1 = pos - [0.15 0 0];
    %                 set( yLabelHandle , 'position' , pos1 );
    %             end

                Y=[yield_p01,fliplr(yield_p995)];
                hold on
                if c==1
                    p1 = fill(X,Y,clrmp1(t,:), 'LineWidth', 1);
                elseif c==2
                    p2 = fill(X,Y,clrmp2(t,:), 'LineWidth', 1);
                end
                scatter(t,yield_over_time{t}(1,1), 'k', 'MarkerFaceColor', 'k') 
                xticks(1:6)
                xlim([1 6]);
                a1 = get(gca,'XTickLabel');
                set(gca,'XTickLabel',a1, 'FontSize',14);
                xticklabels(decades)
                if b==1 & c==1
                    y3 = ylabel('Shortage (MCM/y)');
                end
                ylim([0 10])
                a2 = get(gca,'YTickLabel');
                set(gca,'YTickLabel',a2, 'FontSize',12);
                %set(gca,'Units','normalized')
            end
        end
    end

     end
end

y1.FontSize = 14;
y2.FontSize = 14;
y3.FontSize = 14;
y1.Position = [0.74 80 -1];
y2.Position = [0.38 5 -1];
y3.Position = [0.38 5 -1];
% ann1 = text(-20.3, 36, 'Precip. Paths', 'FontSize', 16, 'FontWeight', 'bold');
% ann2 = text(-20.3, 14.5, 'Precipitation', 'FontSize', 16, 'FontWeight', 'bold');
% ann3 = text(-20.3, -1, 'Water Shortages', 'FontSize', 16, 'FontWeight', 'bold');
% set(ann1, 'Rotation', 90)
% set(ann2, 'Rotation', 90)
% set(ann3, 'Rotation', 90)

d1 = text(-16.5, 25.5, 'Dry', 'FontSize', 16, 'FontWeight', 'bold');
d2 = text(-3.5, 25.5, 'Dry', 'FontSize', 16, 'FontWeight', 'bold');
w1 = text(-10, 25.5, 'Wet', 'FontSize', 16, 'FontWeight', 'bold');
w2 = text(3, 25.5, 'Wet', 'FontSize', 16, 'FontWeight', 'bold');

h1 = text(-14.2, 53.5, 'High Learning', 'FontSize', 18, 'FontWeight', 'bold');
h2 = text(-1, 53.5, 'Low Learning', 'FontSize', 18, 'FontWeight', 'bold');
%set(h1, 'Rotation', 90)
%set(h2, 'Rotation', 90)
annotation('line', [0.51 0.51], [0.05 1.0],'color', 'k', 'LineWidth', 3);
l1 = legend([ln1(1) ln2(1)], {'Dry Climate', 'Wet Climate'})
l1.Position = [0.1000 0.8650 0.1438 0.0482];
l1.Box = 'off';
l1.FontSize = 12;

% labels for each subplot
labs = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)', '(j)'};
xx = [-20.5 -6.5 -20.5 -13.2 -6.5 0 -20.5 -13.2 -6.5 0];
yy = [55 55 26 26 26 26 11 11 11 11];
for i=1:length(labs)
    lbl(i) = text(xx(i), yy(i), labs{i}, 'FontSize', 18, 'FontName', 'Helvetica')%, 'FontWeight', 'bold');
end
%%
% %% KL divergence scatter plots
% %cmap = cbrewer('div', 'RdBu', 11);
% cmap = cbrewer('div', 'Spectral', 11);
% learning_scen = {'High', 'Med', 'Low'};
% climate_scen = {'Dry', 'Moderate', 'Wet'};
% learning_scen_title = {'High', 'Medium', 'Low'};
% sim_scen = {'High_Dry', 'High_Mod', 'High_Wet', 'Med_Dry', 'Med_Mod', ...
%     'Med_Wet', 'Low_Dry', 'Low_Mod', 'Low_Wet'};
% scenarios = {'High, Dry', 'High, Mod', 'High, Wet',...
%     'Medium, Dry', 'Medium, Mod', 'Medium, Wet',...
%     'Low, Dry', 'Low, Mod', 'Low, Wet'};
% Mod = 72; %72
% Wet = 81; % 81
% fileName = {'OptimalPolicies_High24_May_2022.mat',...
%     'OptimalPolicies_Low24_May_2022.mat'};
% 
% w = 1;
% for b=1:2 % high, low
%     load(fileName{b}, 'T_Precip', 'T_Temp', 'runoff', 'shortageVol_Dom', ...
%         'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt', 'rndSamps', 'P_state');
% 
%     indDry = find(P_state(:,5) < Mod);
%     indMod = find(P_state(:,5) >= Mod & P_state(:,5) < Wet);
%     indWet = find(P_state(:,5) >= Wet);
% 
% %     indDry = find(mean(P_state,2) < Mod);
% %     indWet = find(mean(P_state,2) >= Wet);
%     
%     [valDry, posDry] = intersect(rndSamps, indDry);
%     [valWet, posWet] = intersect(rndSamps, indWet);
%     
%     for c=1:2
%         subplot(4,4,w+12)
%         disp(num2str(w));
%         if c==1
%             ind = posDry;
%         elseif c==2
%             ind = posWet;
%         end
%         scatter(KLDiv_Precip_Simple(ind,10), KLDiv_Yield_Log_Opt(ind,10), 25,...
%             P_state(rndSamps(ind),end-1), 'filled');
%         hold on
%        plot([0 6], [0 6], 'color', 'k', 'LineWidth', 1)
%         if w==4
%             cbh = colorbar;
%             colormap(cmap)
%             cbh.Ticks = 50:20:110;
%             cbh.Label.String = '2070 Precip. State';
%             cbh.Label.Position(1) = 4;
%             cbh.Label.Rotation = 270;
%             cbh.Label.FontSize = 15;
%             cbh.Position = cbh.Position + [0.05 0 0 0];
%         end
%         caxis([49 119]);
%         xlim([0 6]);
%         ylim([0 6]);
%         xticks(0:2:6);
%         yticks(0:2:6);
%         xlabel('KL Div. Precip.', 'FontSize', 12);
%         if w==1
%             y4 = ylabel('KL Div. Shortage', 'FontSize', 12);
%         end
%         a1 = get(gca,'XTick');
%         set(gca,'XTick',a1, 'FontSize',14);
%         a2 = get(gca,'YTickLabel');
%         set(gca,'YTickLabel',a2, 'FontSize',14);
%         %         if b==1 & c==1
%         %            t1 = strcat(learning_scen_title{b}, ' Learning, ', {' '}, climate_scen{c},...
%         %              ' Climate');
%         %             title(t1, 'FontSize', 15, 'FontWeight', 'normal');
%         %         else
%         %            t1 = strcat(learning_scen_title{b}, ' Learning, ', {' '}, climate_scen{c},...
%         %              ' Climate');
%         %             title(t1, 'FontSize', 15, 'FontWeight', 'normal');
%         %         end
%         w = w + 1;
%     end
% end
% ann4 = text(-25.4, 0.7, 'KL Divergence', 'FontSize', 16, 'FontWeight', 'bold');
% set(ann4, 'Rotation', 90)
% %t2 = text(-6.8, 15.3, 'KL Divergence Correlations for 2070 Information', 'FontSize', 18, 'FontWeight', 'bold');
% 
% %% KL divergence scatter plots - v2- no separation by wet/dry
% %cmap = cbrewer('div', 'RdBu', 11);
% cmap = cbrewer('div', 'Spectral', 11);
% learning_scen = {'High', 'Med', 'Low'};
% climate_scen = {'Dry', 'Moderate', 'Wet'};
% learning_scen_title = {'High', 'Medium', 'Low'};
% sim_scen = {'High_Dry', 'High_Mod', 'High_Wet', 'Med_Dry', 'Med_Mod', ...
%     'Med_Wet', 'Low_Dry', 'Low_Mod', 'Low_Wet'};
% scenarios = {'High, Dry', 'High, Mod', 'High, Wet',...
%     'Medium, Dry', 'Medium, Mod', 'Medium, Wet',...
%     'Low, Dry', 'Low, Mod', 'Low, Wet'};
% Mod = 72; %72
% Wet = 81; % 81
% fileName = {'OptimalPolicies_High24_May_2022.mat',...
%     'OptimalPolicies_Low24_May_2022.mat'};
% 
% w = 1;
% for b=1:2 % high, low
%     load(fileName{b}, 'T_Precip', 'T_Temp', 'runoff', 'shortageVol_Dom', ...
%         'KLDiv_Precip_Simple', 'KLDiv_Yield_Log_Opt', 'rndSamps', 'P_state');
% 
%     indDry = find(P_state(:,5) < Mod);
%     indMod = find(P_state(:,5) >= Mod & P_state(:,5) < Wet);
%     indWet = find(P_state(:,5) >= Wet);
% 
% %     indDry = find(mean(P_state,2) < Mod);
% %     indWet = find(mean(P_state,2) >= Wet);
%     
%     [valDry, posDry] = intersect(rndSamps, indDry);
%     [valWet, posWet] = intersect(rndSamps, indWet);
%     
%     subplot(4,4,b*2-1+12:b*2+12)
%     disp(num2str(w));
%     scatter(KLDiv_Precip_Simple(:,10), KLDiv_Yield_Log_Opt(:,10), 25,...
%         P_state(rndSamps,end-1), 'filled');
%     hold on
%     plot([0 6], [0 6], 'color', 'k', 'LineWidth', 1)
%     if w==2
%         cbh = colorbar;
%         colormap(cmap)
%         cbh.Ticks = 50:20:110;
%         cbh.Label.String = '2070 Precip. State';
%         cbh.Label.Position(1) = 4;
%         cbh.Label.Rotation = 270;
%         cbh.Label.FontSize = 15;
%         cbh.Position = cbh.Position + [0.04 0 0 0];
%     end
%     caxis([49 119]);
%     xlim([0 6]);
%     ylim([0 6]);
%     xticks(0:2:6);
%     yticks(0:2:6);
%     x4 = xlabel('KL Div. Precip.', 'FontSize', 12);
%     if w==1
%         y4 = ylabel('KL Div. Shortage', 'FontSize', 12);
%         x41 = xlabel('KL Div. Precip.', 'FontSize', 12);
%     else
%         x42 = xlabel('KL Div. Precip.', 'FontSize', 12);
%     end
% 
%     a1 = get(gca,'XTick');
%     set(gca,'XTick',a1, 'FontSize',14);
%     a2 = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a2, 'FontSize',14);
%     %         if b==1 & c==1
%     %            t1 = strcat(learning_scen_title{b}, ' Learning, ', {' '}, climate_scen{c},...
%     %              ' Climate');
%     %             title(t1, 'FontSize', 15, 'FontWeight', 'normal');
%     %         else
%     %            t1 = strcat(learning_scen_title{b}, ' Learning, ', {' '}, climate_scen{c},...
%     %              ' Climate');
%     %             title(t1, 'FontSize', 15, 'FontWeight', 'normal');
%     %         end
%     w = w + 1;
% end
% x41.FontSize = 13.2;
% x41.FontSize = 13.2;
% y4.FontSize = 13.2;
% y4.Position = [-0.3 3 -1];
% ann4 = text(-7.5, 0.4, 'KL Divergence', 'FontSize', 16, 'FontWeight', 'bold');
% set(ann4, 'Rotation', 90)
% %t2 = text(-6.8, 15.3, 'KL Divergence Correlations for 2070 Information', 'FontSize', 18, 'FontWeight', 'bold');