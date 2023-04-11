
% CALIBRATION RESULTS

postProcess = true;
if postProcess 
    
    global PRECIP_0 OBS NYRS PET % DATA INPUT
    global precip_day % CALCULTED VALUES
    global ku kp kl sat lm inter over % MODEL PARAMETERS
    
    usePton = false;
    MTHavgCalib = 0; % 1 monthly mean, 0 individual points
    
    load('InputData/Mwache_hydro_data')
    x = X_results;
    bas = 1;
    
    days = [31 28 31 30 31 30 31 31 30 31 30 31];% CRU -JAN- DEC ;
    WATYEAR = 6;   % Which year of the month start on
    days_adj = [days(WATYEAR:end) days(1:WATYEAR-1)];
    NYRS = 14;
    months = NYRS*12;
    makePet = false;
    PET = PET_date_lin'; % mm/day
    PRECIP_0 = P0_date_lin' ./ repmat(days_adj,1,NYRS); % Convert from mm/m to mm/day
    OBS = runoff_mwache; % mm/day
    flowNames = {'Mwache river'};

    % added by JS for testing
    NYRS = NYRS * 4;
    months = months * 4;
    PET = repmat(PET, 1, 4);
    PRECIP_0 = repmat(PRECIP_0, 1, 4);
    %precip_day = repmat(precip_day, 1, 4);

    if usePton
       load('InputData/Mwache_hydro_pton') 
       PET = E_pton; % mm/day
       PET(118) = (PET(119) + PET(120)) /2;
       PRECIP_0 = P_pton; % mm/day
       OBS = runoff_pton; % mm/day
       OBS(118) = (OBS(119) + OBS(120)) /2;
       PRECIP_0(118) = (PRECIP_0(119) + PRECIP_0(120)) /2;
    end
end


%set globals for ode45 of 'flowul01nile'
%model parameters from OPTIMIZATION CODER
%layer thickness
sat= x(1);
lm = x(2);
% flux parameters
ku= x(3);
kp = x(4);
kl= x(5);
% coef
inter = x(6);
over = x(7);
%set precip data
    
precip_day = inter.*PRECIP_0;

months = NYRS*12;

Tspan= (0:months)';
%Tspan = [0:months-1 months-.1]';

options = odeset('NonNegative',[1 2]);
[Tvec,xsol]=ode45('soil_model_II',Tspan,[5,.1,0.0,0.0], options);%JMS-mod
    
    % Conforming raw data from ODE
    z = xsol(2:end,1:2);
    wb = runoff_II(z);
    wb = wb';
    
    if MTHavgCalib==2
        xout = zeros(12,2);
        xout(:,1) = mean( reshape( wb(:,4)', 12, []), 2)';
    else xout = zeros(length(wb)/4,2);
    % ODE SOVLERS OUTPUT TIME O - STRIPPING OFF TIME ZERO 1 to 12 * years
    % wb = [rss1; dr1; rs1; RunOff];
    xout(:,1) = wb(505:672,4)'; % RunOff - total runoff
    end
    
    xout(:,2) = OBS;
    
    
    % Calculate MAR and yield
    area = 2250 * 1E6; %m2
    inflow_obs_mcmpy = xout(:,2)/1E3 * area * 365 / 1E6;
    inflow_mdl_mcmpy = xout(:,1)/1E3 * area * 365 / 1E6;
    mar_obs = mean(inflow_obs_mcmpy)
    mar_mdl = mean(inflow_mdl_mcmpy)
    storage = 120;
    yield_mdl = strmflw2frmyld(inflow_mdl_mcmpy, storage)
    yield_obs = strmflw2frmyld(inflow_obs_mcmpy, storage)

    % ESTABLISH THE OBJECTIVE FUNCTION
    
    %To find month difference model v. observed
    err  = xout(:,2) - xout(:,1);
    sq_err = err.^2;
    mean_sq_err = mean(sq_err);
    rmse_pt = sqrt(mean_sq_err);
    
    disp('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-')
    disp(['rmse (point): ',num2str(rmse_pt)])
    disp('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-')
    
        %to plot..TOTAL runoff v. Observes         %JMS
   figure('Position', [560 450 750 500]);
   subplot(2,1,1)
   plot(xout(:,1:2), 'LineWidth', 2);
   a = get(gca,'XTickLabel');  
   set(gca,'XTickLabel',a,'fontsize',16)
   set(gca,'XTickLabelMode','auto')
   legend({'Model','Observed'}, 'Location', 'northwest', 'FontSize', 18); %JMS
   xlabel('Month', 'FontSize', 16);
   ylabel('Runoff (mm/d)', 'FontSize', 16);
   legend('boxoff')
   ylim([0 1.5])

%    title([strcat('Mean Annual Runoff:', {' '}, num2str(mar_mdl, 3), ', Yield:', {' '}, num2str(yield_mdl, 2),...
%         ', RMSE Point:', {' '}, num2str(rmse_pt, 2),{' '}, ', RMSE Mean:', {' '}, num2str(rmse_mn, 2))], ...
%         'FontSize', 11);
   
   % Do same error analysis with monthly means instead of individual points
   xout1_mean = mean( reshape( xout(:,1),12,[]) , 2 )';%Make monthly mean Model
   xout2_mean = mean( reshape( xout(:,2),12,[]) , 2 )';% 12 monthlty mean obs
   
   err  = xout2_mean - xout1_mean;
    sq_err = err.^2;
    mean_sq_err = mean(sq_err);
    rmse_mn = sqrt(mean_sq_err);
    
    disp('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-')
    disp(['rmse (mean): ',num2str(rmse_mn)])
    disp('~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-')
    
    subplot(2,1,2)
    b = bar(1:12, [xout1_mean; xout2_mean]');  
    legend('boxoff')
    a = get(gca,'XTickLabel');  
    set(gca,'XTickLabel',a,'fontsize',16)
    set(gca,'XTickLabelMode','auto')
    xlabel('Month', 'FontSize', 16);
    ylabel('Runoff (mm/d)', 'FontSize', 16);
    legend({'Model Monthly Mean','Obs. Monthly Mean'},'Location', 'northwest', 'FontSize', 18); %JM
    xticklabels({'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'});
    ylim([0 0.4])
    title('Monthly Averages', 'FontSize', 18);
    %sgtitle('Calibration Results');
    sgtitle(strcat('RMSE Point:', {' '}, num2str(rmse_pt, 2),{' '}, ', RMSE Mean:', {' '}, num2str(rmse_mn, 2)),...
        'FontSize', 18);
    
    
    % add line to save data
%     datetime
%     save(['CLIRUN/OutputData/data/Calibration_',flowNames{bas}, '_', num2str(datetime),'.mat'],'x','xout',...
%         'rmse_pt', 'rmse_mn', 'err', 'xout1_mean', 'xout2_mean', 'mar_mdl', 'yield_mdl');
    
    if ~postProcess
    saveas(1,['OutputData/plots/calib_','_basin',num2str(bas),'_',flowNames{bas},'.jpg'])
    
    RESULTS = ones(1,3);
    RESULTS(1) = obj;
    RESULTS(2) = error;  
    RESULTS(3) = r2;
    
    
    
    save(['OutputData/data/Calibration_','_',flowNames{bas},'.mat'],'RESULTS','x','xout')

    X_results(bas,:)=x;
    resultsMAT(bas,:)=RESULTS;
    %xoutMAT(bas,1:months,:)=xout;
    xoutMAT(bas,:,:)=xout;
    end
    
  