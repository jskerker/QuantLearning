% createTMcombo: A function that calculates a single combination transition 
% matrix
% Inputs:
%   Chng: The avg change in wettness or dryness in mm/mo/mm
%   sigma: The standard deviation around the mean
%   actualPrng: The range of precip (or temp) values
%   zeroVal: The value in the distribution to center the shifting around
% Outputs:
%   transMatrix: A transition matrix for precipitation (or temperature)
function [transMatrix] = createTMcombo(Chng, sigma, actualPrng, zeroVal)

sz = length(actualPrng);
scen = length(Chng);
center = find(actualPrng == zeroVal);

% calculate the likelihood following a normal distribution
in = zeros(sz, sz, scen);
for j=1:scen
    for i=1:sz
        % calculate the shift/amount of change for each value w/ startVal shift = 0
        shift(i) = Chng(j)*(i-center);
        in(:,i,j) = normpdf(actualPrng-zeroVal, shift(i), sigma); %normpdf
        % in(:,i,j) = normpdf(actualPrng, actualPrng(i)+shift(i), sigma); %normpdf
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