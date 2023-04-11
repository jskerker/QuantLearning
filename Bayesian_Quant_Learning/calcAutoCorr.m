function [mean_acf, median_acf, rho_All] = calcAutoCorr(data, lag, plotHist)

% function that takes in time series data (20-year averages) and a lag and calculates the 
% autocorrelation for every sample
% Outputs:
%   mean_acf: the mean of the x-lag correlation
%   median_acf: the median of the x-lag correlation
%   acf: the lag values for x-lag for every sample time series

count = 1;

for i=1:length(data)
    [rho pval] = corr(data(i,1+lag:end)', data(i,1:end-lag)');
    if isnan(rho)
        msg = strcat('acf is nan: ', num2str(i));
        disp(msg)
    else
        rho_All(count) = rho;
        count = count + 1;
    end
end

mean_acf = mean(rho_All);
median_acf = median(rho_All);

if plotHist
    figure
    histogram(rho_All, 'Normalization', 'Probability');
    xlab = strcat(num2str(lag), '-lag ACF value');
    xlabel(xlab);
    ylabel('PDF');
    t1 = strcat('Mean and Median ACF Value: ', {' '}, num2str(mean_acf), ...
    ', ', {' '}, num2str(median_acf));
    title(t1);
end
    
end