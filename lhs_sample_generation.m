function [ParameterSamples, parameternames] = lhs_sample_generation(NumberLHSSamples,tr,rtr)

% NumberLHSSamples is the number of samples from parameter distribution.
% This will equal the number of simulations you have to run for each
% scenario

% ParameterSamples is matrix where row i corresponds to the ith LHS sample
% parameter combination, and column j corresponds to value for parameter j  
% (where name of parameter j is jth entry in parameternames)

parameternames = {'IncreasedRiskTransmissionInHouseholds';  'MeanSportSize'; 'MeanFuneralSize';
'MeanDurationSport'; 'MeanDurationFuneral'; 'LatencyDuration';
'InfectiousDuration'; 'beta'; 'migration'};

% Lower bounds LHS distributions
if rtr == 0
    IncreasedRiskTransmissionInHouseholds(1) = 1; 
else
    IncreasedRiskTransmissionInHouseholds(1) = 3;
end
MeanSportSize(1) = 50;
MeanFuneralSize(1) = 10;
MeanDurationSport(1) = 1;
MeanDurationFuneral(1) = 1;
LatencyDuration(1) = 1;
InfectiousDuration(1) = 1;
if tr==0
    beta(1) = 0.002;
else
    beta(1) = 0.004;
end
migration(1) = 0.002;

% Upper bounds LHS distributions
if rtr==0
    IncreasedRiskTransmissionInHouseholds(2) = 3;
else
    IncreasedRiskTransmissionInHouseholds(2) = 5;
end
MeanSportSize(2) = 100;
MeanFuneralSize(2) = 50;
MeanDurationSport(2) = 2;
MeanDurationFuneral(2) = 7;
LatencyDuration(2) = 3;
InfectiousDuration(2) = 3;
if tr==0
    beta(2) = 0.004;
else
    beta(2) = 0.006;
end
migration(2) = 0.004;

% Distribution bounds LHS distributions
DistributionBounds = [
    IncreasedRiskTransmissionInHouseholds;...
MeanSportSize;...
MeanFuneralSize;...
MeanDurationSport;...
MeanDurationFuneral;...
LatencyDuration;
InfectiousDuration;
beta;
migration];

LowerBounds = squeeze(DistributionBounds(:,1))';
UpperBounds = squeeze(DistributionBounds(:,2))';

NumberLHSParameters = length(UpperBounds);

% Creat LHS samples, assuming all uniform distribution 
ParameterSamples = lhsdesign(NumberLHSSamples,NumberLHSParameters);
ParameterSamples = bsxfun(@plus,LowerBounds,bsxfun(@times,...
    ParameterSamples,(UpperBounds-LowerBounds)));

