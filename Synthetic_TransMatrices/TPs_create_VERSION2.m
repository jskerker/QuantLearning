% TPs_create_testing_July2022
% Last updated: 7/29/2022
clear all; close all;
%% Create combined transition matrices- normal distribution

% Learning scenarios
scenarios = {'High', 'Low'};
label = 'July2022_Bayes';

% Input parameters for transition matrices
chngInit = 1;
stdStart = 5;
LrnAll = [2 50]; % high, low
diffAll = [1.15 -0.58]% 0.2]; %0.06 0.02 -0.02

% constants
N = 5;
s_P_abs = 49:119;
l = length(s_P_abs);
P0_abs = 77;
TM = zeros(l, l, N+1);

for j=1:length(LrnAll)
    %Chng = chngInit;
    sigma = stdStart;
    Lrn = LrnAll(j);
    diff = diffAll(j);
    
    for i=1:N+1
        sigma = sqrt((Lrn^2*stdStart^2)/((i-1)*stdStart^2+Lrn^2)); % 
        Chng = ((i-1)*diff*stdStart^2+Lrn^2)/((i-1)*stdStart^2+Lrn^2); % mean multiplicative factor
        TM(:,:,i) = createTMcombo(Chng, sigma, s_P_abs, P0_abs);
        msg = strcat('mean shift factor: ', {' '}, num2str(Chng), ', std: ', {' '}, num2str(sigma));
        disp(msg);

    end
    T_Precip = TM;
    T_Precip_all_norm(:,:,:,j) = T_Precip;
    filename = ['T_Temp_Precip_V2_', scenarios{j}, '_', label, '.mat'];
    save(filename, 'T_Precip');
end

%% Plot/check combined transition matrices

kk = 2; % plot high/low
T_Precip = T_Precip_all_norm(:,:,:,kk);
%T_Precip = T_Precip_all_logn(:,:,:,1);

start = find(s_P_abs == 77);
for j=1:1%length(LrnAll)
    figure
    for i=1:N+1
        subplot(N+1,2,1+(i-1)*2)
        imagesc(T_Precip(:,:,i));
        set(gca, 'YDir', 'normal');
        %line([start start], [0 l], 'LineWidth', 1.5, 'color', 'k');
        xticks(0:20:70);
        xticklabels(49:20:119);
        yticks(0:20:70);
        yticklabels(49:20:119);
        colorbar;
        title(['Trans Matrix for N = ', num2str(i-1)]);

        subplot(N+1,2,2+(i-1)*2)
        p1 = plot(T_Precip(:,start,i), 'LineWidth', 1.5, 'color', 'k');
         hold on
         p2 = plot(T_Precip(:,start+5,i), 'LineWidth', 1.5, 'color', 'b');
         p3 = plot(T_Precip(:,start-5,i), 'LineWidth', 1.5, 'color', 'r');
%         if i == 1
%             legend([p1 p2 p3], {'Starting State', 'Wetting', 'Drying'}, ...
%                 'FontSize', 7);
%             legend('boxoff');
%         end
        xticks(0:20:70);
        xticklabels(49:20:119);
        title('Dist. for T=77 mm/mo');
    end
    t1 = strcat('Synthetic TMs: ', {' '}, scenarios{kk}, ' Learning');
    sgtitle(t1);
end

%% Simulate precipitation instances
P_current = 77;
numSamp = 100000;

T_Precip_high = T_Precip_all_norm(:,:,:,1);
T_Precip_low = T_Precip_all_norm(:,:,:,2);

P_state_high = T2forwardSimTemp(T_Precip_high, s_P_abs, N+1, 1, P_current, numSamp, false);
P_state_low = T2forwardSimTemp(T_Precip_low, s_P_abs, N+1, 1, P_current, numSamp, false);

% Plot histograms together, bin width = 1 w/ KL divergence for high & low
periods = {'1990- Current distribution', '2001-2020', '2021-2040', '2041-2060', '2061-2080', '2081-2100'};
figure('Position', [68 210 1401 678]);
CalcMethod = 3;
const = 0.0001;
NumBins = 50;

for i=1:N+1
    % calc KL divergence between 2 distributions
    dist1 = P_state_high(:,i+1);
    dist2 = P_state_low(:,i+1);
    KLDiv = CalcDist2KLD(dist1, dist2, CalcMethod, const, NumBins);
    
    % plot distributions
    subplot(3,2,i)
    histogram(P_state_high(:,i+1), 'BinWidth', 1, 'Normalization', 'Probability');
    hold on
    %histogram(P_state_med(:,i), 'BinWidth', 1, 'Normalization', 'Probability');
    %hold on
    histogram(P_state_low(:,i+1), 'BinWidth', 1, 'Normalization', 'Probability');
    xlabel('\DeltaPrecip (mm/mo)');
    ylabel('Frequency');
    xlim([48 120]);
    xticks(50:10:120);
    xticklabels((50-77):10:(120-77));
    t1 = strcat(periods{i}, ': KL divergence = ', {' '}, num2str(KLDiv, 2));
    title(t1);
end
%sgtitle('High and Low');
pd_High = fitdist(dist1,'Normal')
pd_Low = fitdist(dist2, 'Normal')
y_high = normpdf(s_P_abs, 77, 10.58);
plot(s_P_abs, y_high, '--', 'LineWidth', 2, 'color', 'k');
legend('High', 'Low', 'Defined params');
%% Plot sample precip paths
N = 5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
rndSamps = randi(10000, [50 1]);
rndSampsHighlight = randi(10000, [5 1]);
decades = { '1990', '2010', '2030', '2050', '2070', '2090'};
alpha = rand([50 1])/2+0.5;

figure('Position', [265 200 1100 600]);

%rndSampsHighlight = [8 11 23 27 28];
subplot(2,1,1);
for i=1:50
    plot(P_state_high(rndSamps(i),:)', 'LineWidth', 0.8, 'color', [alpha(i) alpha(i) alpha(i)]);
    hold on
    
end
%plot([repmat(77, [5 1]) P_state_high(rndSampsHighlight,:)]', 'LineWidth', 1.5, 'color', clrmp2(5,:));
for i=1:4
    plot(P_state_high(rndSampsHighlight(i),:)', 'LineWidth', 2, 'color', clrmp2(i+1,:));
end
xticks(1:6);
xticklabels(decades);
ylim([49 120]);
yticks(50:20:120);
ylabel('Precip (mm/mo)', 'FontSize', 16);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
%title('High Learning', 'FontSize', 18);
[mnACF, medACF, acf_high] = calcAutoCorr(P_state_high, 1, false);
t1 = strcat('High Learning: Lag-One Autocorr: ', {' '}, num2str(mnACF, 2));
title(t1);

%rndSampsHighlight = [25 28 39 47 61];
rndSampsHighlight = [25 75 28 39 61]; %47
subplot(2,1,2);
for i=1:50
    plot(P_state_low(rndSamps(i),:)', 'LineWidth', 0.8, 'color', [alpha(i) alpha(i) alpha(i)]);
    hold on
end
%plot([repmat(77, [5 1]) P_state_low(rndSampsHighlight,:)]', 'LineWidth', 1.5, 'color', clrmp1(5,:));
for i=1:4
    plot(P_state_low(rndSampsHighlight(i),:)', 'LineWidth', 2, 'color', clrmp1(i+1,:));
end
xticks(1:6);
xticklabels(decades);
ylim([49 120]);
yticks(50:20:120);
ylabel('Precip (mm/mo)', 'FontSize', 16);
a1 = get(gca,'YTickLabel');
set(gca,'YTickLabel',a1, 'FontSize',14);
a2 = get(gca,'XTickLabel');
set(gca,'XTickLabel',a2, 'FontSize',14);
[mnACF, medACF, acf_high] = calcAutoCorr(P_state_low, 1, false);
t1 = strcat('Low Learning: Lag-One Autocorr: ', {' '}, num2str(mnACF, 2));
title(t1);

%% Test fitting linear trend using mse
t = 1:5;
t = t';
%X = [t ones(T,1)];
lrn = 1;
if lrn == 1
    Pdata = P_state_high;
    scen = 'High';
elseif lrn == 3
    Pdata = P_state_low;
    scen = 'Low';
end
figure;
for i=1:10000
    T = length(Pdata(i,:));
    y = Pdata(i,:);
    [b, s] = polyfit(t, y, 1);
    %th = X.*b;
    [y_fit, delta] = polyval(b,t,s);
    mse(i) = (1/6)*sum(delta.^2);
    
    if i < 10
        subplot(3,3,i)
        plot(t, y_fit, '--', 'LineWidth', 1.5)
        hold on
        plot(t, y, 'x', 'LineWidth', 2)
        t1 = strcat('MSE: ', {' '}, num2str(mse(i)));
        title(t1);
        t2 = strcat(scen, ' Learning');
        sgtitle(t2);
    end
    
end

figure
histogram(mse, 'Normalization', 'Probability');
xlabel('MSE Value');
ylabel('PDF');
mean_mse = mean(mse)
median_mse = median(mse)
t1 = strcat(scen, ' Learning: Mean Square Error Values between Lin Reg. and Actual Precip Path');
t2 = strcat('Mean MSE=', {' '}, num2str(mean_mse), ', Median MSE=',...
    {' '}, num2str(median_mse));
title([t1, t2]);

%% Test linear trend using autocorrelation
% t = 1:5;
% t = t';
%X = [t ones(T,1)];
lrn = 1;
if lrn == 1
    Pdata = P_state_high;
    scen = 'High';
elseif lrn == 3
    Pdata = P_state_low;
    scen = 'Low';
end
%data = [76 77 79 81 84];
figure;
count = 1;
for i=1:10000
    data = Pdata(i,:);
    [acfs, lags] = autocorr(data);
    if isnan(acfs(2))
        msg = strcat('acf is nan: ', num2str(i));
        disp(msg)
    else
        acf(count) = acfs(2);
        count = count + 1;
    end
    
    if i < 10
        subplot(3,3,i)
        autocorr(data);
        t1 = strcat('Precip: ', {' '}, num2str(data), ', Lag one: ', {' '}, num2str(acf(i)));
        title(t1);
        t2 = strcat(scen, ' Learning');
        sgtitle(t2);
    end
    
end

figure
histogram(acf, 'Normalization', 'Probability');
xlabel('ACF Lag One Value');
ylabel('PDF');
mean_acf = mean(acf)
median_acf = median(acf)
t1 = strcat(scen, ' Learning: Lag-One Autocorrelation');
t2 = strcat('Mean ACF=', {' '}, num2str(mean_acf), ', Median ACF=',...
    {' '}, num2str(median_acf));
title([t1, t2]);

%%
figure
histogram(acf_high, 'Normalization', 'Probability');
hold on
histogram(acf_low, 'Normalization', 'Probability');
xlabel('One-Lag ACF Value');
ylabel('PDF');
legend('High', 'Low')
mean_high = mean(acf_high);
median_high = median(acf_high);
mean_low = mean(acf_low);
median_low = median(acf_low);
t1 = strcat('High and Low Mean ACF Values: ', {' '}, num2str(mean_high), ...
    ', ', {' '}, num2str(mean_low));
t2 = strcat('High and Low Median ACF Values: ', {' '}, num2str(median_high), ...
    ', ', {' '}, num2str(median_low));
title([t1, t2]);
%% Test correlation using Mann-Kendall Test
%% Create simulation scenarios

s_P_abs = 49:119;

T_Precip_syn{4} = synthMatrix_stateSpace(0, 4, 0.8, s_P_abs, 0); % mod, std = 1
T_Precip_syn{5} = synthMatrix_stateSpace(0, 4, 0.95, s_P_abs, 0); % mod, std = 2
T_Precip_syn{6} = synthMatrix_stateSpace(0, 4, 1.1, s_P_abs, 0); % mod, std = 4

T_Precip_syn{7} = synthMatrix_stateSpace(2, 4, 0.8, s_P_abs, 0); % wet, std = 1
T_Precip_syn{8} = synthMatrix_stateSpace(2, 4, 0.95, s_P_abs, 0); % wet, std = 2
T_Precip_syn{9} = synthMatrix_stateSpace(2, 4, 1.1, s_P_abs, 0); % wet, std = 4
 
T_Precip_syn{1} = synthMatrix_stateSpace(-2, 4, 0.8, s_P_abs, 0); % dry, std = 1
T_Precip_syn{2} = synthMatrix_stateSpace(-2, 4, 0.95, s_P_abs, 0); % dry, std = 2
T_Precip_syn{3} = synthMatrix_stateSpace(-2, 4, 1.1, s_P_abs, 0); % dry, std = 4

climate = {'Dry', 'Mod', 'Wet'};

for i=1:length(climate)
    for j=1:length(scenarios)
        scen = (i-1)*3+j;
        stateMsg = strcat(scenarios{j}, ',', {' '}, climate{i}, ',', {' '},...
            num2str(scen));
        disp(stateMsg);
        
        filename = ['T_Temp_Precip_', scenarios{j},'_', climate{i} '.mat']
        T_Precip = T_Precip_syn{scen};
        save(filename, 'T_Precip');
    end
end


%% Plot/check combined simulation transition matrices

start = find(s_P_abs == 77);
for i=1:length(climate)
    for j=1:length(scenarios)
        filename = ['T_Temp_Precip_', scenarios{j},'_', climate{i} '.mat']
        load(filename);
        
        figure('Position', [345 96 693 776]);
        for k=1:5
            subplot(5,2,1+(k-1)*2)
            imagesc(T_Precip(:,:,k));
            set(gca, 'YDir', 'normal');
            %line([start start], [0 l], 'LineWidth', 1.5, 'color', 'k');
            xticks(0:20:70);
            xticklabels(49:20:119);
            yticks(0:20:70);
            yticklabels(49:20:119);
            colorbar;
            title(['Trans Matrix for N = ', num2str(k)]);

            subplot(5,2,2+(k-1)*2)
            p1 = plot(T_Precip(:,start,k), 'LineWidth', 1.5, 'color', 'k');
            hold on
            p2 = plot([start start], [0 0.1], '--', 'Color', [0.5 0.5 0.5]);
    %         p2 = plot(T_Precip(:,start+2,i), 'LineWidth', 1.5, 'color', 'b');
    %         p3 = plot(T_Precip(:,start-2,i), 'LineWidth', 1.5, 'color', 'r');
    %         if i == 1
    %             legend([p1 p2 p3], {'Starting State', 'Wetting', 'Drying'}, ...
    %                 'FontSize', 7);
    %             legend('boxoff');
    %         end
            xticks(0:20:70);
            xticklabels(49:20:119);
            title('Dist. for T=77 mm/mo');
        end
        t1 = strcat('Synthetic TMs: ', {' '}, scenarios{j}, ' Learning',...
            ', Climate: ', {' '}, climate{i});
        sgtitle(t1);
    end
end
