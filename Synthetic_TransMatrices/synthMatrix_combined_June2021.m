%% test creating TMs for combined dry, mod, wet scenarios
clear all; close all;

avgChng = [-3 0 3];
%avgChng = -avgChng;

sigma = 1;
actualPrng = 66:97;

sz = length(actualPrng);
scen = length(avgChng);

in = zeros(sz, sz, scen);

% calculate the likelihood following a normal distribution for each
% scenario: dry, mod, wet
for j=1:scen
    for i=1:sz
        in(:,i,j) = normpdf(actualPrng, actualPrng(i)+avgChng(j), sigma);
    end  
end

% combine multiple scenarios into one distribution
for i=1:sz
    inSum(:,i) = sum(in(:,i,:), 3);
end


likeP = reshape(inSum, 1, []);

% calculate prior assuming uniform distribution
pP = reshape(repmat(1, sz), 1, []);

% calculate posterior
probP = pP .* likeP;
probP_scen(:,:) = reshape(probP, sz, sz);

% normalize each scenario
sumP = sum(probP_scen(:,:));
for i=1:sz
    probP_scen(:,i) = probP_scen(:,i)./sumP(i);
end

%% plot 1: dry, mod, wet
N=5;
addpath('/Users/jenniferskerker/Documents/GradSchool/Research/Project1/Code/Models/Fletcher_2019_Learning_Climate/Plots/plotting utilities/cbrewer/cbrewer/cbrewer');
[clrmp1]=cbrewer('seq', 'Reds', N);
[clrmp2]=cbrewer('seq', 'Blues', N);
[clrmp3]=cbrewer('seq', 'Greens', N);
[clrmp4]=cbrewer('seq', 'Purples', N);
cmap1 = cbrewer('qual', 'Set2', 8);
cmap2 = cbrewer('div', 'Spectral',11);
cmap = [cmap1(1,:); cmap1(4,:); cmap2(6:end,:)];
cmap = cbrewer('qual', 'Set3', 8);

figure;
subplot(2,1,1);
p1 = plot(in(:,12,1), 'LineWidth', 1.5, 'color', clrmp1(4,:));
hold on
p2 = plot(in(:,12,2), 'LineWidth', 1.5, 'color', clrmp3(4,:));
p3 = plot(in(:,12,3), 'LineWidth', 1.5, 'color', clrmp2(4,:));
xticks(0:5:35);
xticklabels(66:5:105);
xlabel('Time Period n+1 Precip State (mm/mo)');
ylabel('Probability');
legend([p1 p2 p3], {'Dry', 'Moderate', 'Wet'}, 'Location', 'northeast');
legend('boxoff');
sgtitle('PDFs of Precip State in Time n+1 at P=77 mm/mo');

%% Plot 2: continuation of plot 1 + combined distribution
p4 = plot(probP_scen(:,12), '--', 'LineWidth', 1.5, 'DisplayName', 'Combined');

%% Subplots 2-4: TMs for Dry, Mod, Wet
scenario = {'Dry', 'Moderate', 'Wet'};
for i=1:3
    subplot(2,4,4+i);
    imagesc(in(:,:,i));
    colorbar;
    %caxis([0 0.22]);
    xlabel('Precip State i')
    xticks([10:10:32]);
    yticks([10:10:32]);
    xticklabels([75:10:97]);
    yticklabels([75:10:97]);
    ylabel('Precip State i+1')
    %axis square
    set(gca, 'YDir', 'normal');
    title(scenario{i});
end

%% Subplot 5: TM for Combined

subplot(2, 4, 8);
imagesc(probP_scen(:,:));
colorbar;
%caxis([0 0.22]);
xlabel('Precip State i')
xticks([10:10:32]);
yticks([10:10:32]);
xticklabels([75:10:97]);
yticklabels([75:10:97]);
ylabel('Precip State i+1')
%axis square
set(gca, 'YDir', 'normal');
title('Combined');

%%

test2 = synthMatrix_stateSpace([-2 0 5], 7, .8, 66:97, 0);

figure
for i=1:5
    subplot(5,2,2*i-1);
    imagesc(test2(:,:,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    
    subplot(5,2,2*i);
    plot(test2(:,12,i), 'LineWidth', 1.5);
end

%% figure of 3 combined TMs

load('T_Temp_Precip_high');
T_Precip_high = T_Precip;

load('T_Temp_Precip_medium');
T_Precip_medium = T_Precip;

load('T_Temp_Precip_low');
T_Precip_low = T_Precip;

figure;
for i=1:5
    % high
    subplot(5, 3, 1+(i-1)*3);
    imagesc(T_Precip_high(:,:,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('high learning, N=1');
    end
    
    % medium
    subplot(5, 3, 2+(i-1)*3);
    imagesc(T_Precip_medium(:,:,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('medium learning, N=1');
    end
    
    % low
    subplot(5, 3, 3+(i-1)*3);
    imagesc(T_Precip_low(:,:,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('low learning, N=1');
    end
end

figure
for i=1:5
    % high
    subplot(5, 3, 1+(i-1)*3);
    plot(T_Precip_high(:,12,i));
    if i==1
        title('high learning, N=1');
    end
    
    % medium
    subplot(5, 3, 2+(i-1)*3);
    plot(T_Precip_medium(:,12,i));
    if i==1
        title('medium learning, N=1');
    end
    
    % low
    subplot(5, 3, 3+(i-1)*3);
    plot(T_Precip_low(:,12,i));
    if i==1
        title('low learning, N=1');
    end
end

%% test out values and actions for low, medium, high learning policies

load('OptimalPolicies_high');
figure;
for i=1:5
    subplot(5,3,1+(i-1)*3)
    imagesc(X(:,:,2,i));
    X_high = X;
    V_high = V;
    set(gca, 'YDir', 'normal');
    colorbar;
end

load('OptimalPolicies_medium');
for i=1:5
    subplot(5,3,2+(i-1)*3)
    imagesc(V(:,:,2,i));
    X_med = X;
    V_med = V;
    set(gca, 'YDir', 'normal');
    colorbar;
end

load('OptimalPolicies_low');
for i=1:5
    subplot(5,3,3+(i-1)*3)
    imagesc(V(:,:,2,i));
    X_low = X;
    V_low = V;
    set(gca, 'YDir', 'normal');
    colorbar;
end

%% Differences in policies
load('OptimalPolicies_high');
X_high = X;
V_high = V;

load('OptimalPolicies_medium');
X_med = X;
V_med = V;

load('OptimalPolicies_low');
X_low = X;
V_low = V;

figure;
for i=1:5
    % high - medium
    subplot(5,3,1+(i-1)*3)
    imagesc(X_high(:,:,2,i)-X_med(:,:,2,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('high - med');
    end
    
    % medium - low
    subplot(5,3,2+(i-1)*3)
    imagesc(X_med(:,:,2,i)-X_low(:,:,2,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('med - low');
    end
    
    % high - low
    subplot(5,3,3+(i-1)*3)
    imagesc(X_high(:,:,2,i)-X_low(:,:,2,i));
    set(gca, 'YDir', 'normal');
    colorbar;
    if i==1
        title('high - low');
    end
end


