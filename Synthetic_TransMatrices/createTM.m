% createTM: A function that calculates a single transition matrix
% Inputs:
%   avgChng: Average change in precip (or temp) from time period N to N+1
%   sigma: The standard deviation around the mean
%   actualPrng: The range of precip (or temp) values
% Outputs:
%   transMatrix: A transition matrix for precipitation (or temperature)
function [transMatrix] = createTM(avgChng, sigma, actualPrng)

sz = length(actualPrng);
scen = length(avgChng);

% calculate the likelihood following a normal distribution
in = zeros(sz, sz, scen);
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

transMatrix = probP_scen;