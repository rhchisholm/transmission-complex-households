function parameters = parameters_basenc(parameters)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define all population parameters for baseline simluation here %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters.lhsinput  = 
%{'IncreasedRiskTransmissionInHouseholds'; 'MeanSportSize'; 'MeanFuneralSize';
%'MeanDurationSport'; 'MeanDurationFuneral'; 'LatencyDuration';
%'InfectiousDuration'; 'beta'; 'migration'};

% Model setup parameters
parameters.dt = 1/7; % Time step duration (weeks)
parameters.dt_years = parameters.dt / 52.14; % Time step duration (years)
parameters.time = 0 : parameters.dt : parameters.T; % vector of time steps
parameters.Ntimesteps = length(parameters.time); % Number of time steps

% Population parameters
parameters.NI0 = 1; % Initial number of infections of each strain in each population
parameters.NR0 = 0; % Initial number of agents immune to each strain in each population
parameters.PopSize = parameters.Scenarios(1);%% %2500, 1200, 500 (Galuwinku, Ramingining, Gunganara (scaled up) ABS Storybook Census data)
parameters.PopSizeResidentsOnly = parameters.PopSize;
parameters.NumberHouses = parameters.Scenarios(2); %358,140,80 (Galuwinku, Ramingining, Gunganara (scaled up) ABS Storybook Census data)
parameters.HHIDs = (1:1:parameters.NumberHouses)';

% Probability agents stay in [Core, Regular, On/Off, Sporadic] residence
% each night. Core, Regular, On/Off are specified,
% sporadic is a random house in community
if parameters.Scenarios(3) == 6
    parameters.HHMobilityPD = [0.66 0.23 0.09 0.02];
else
    parameters.HHMobilityPD = [1 0 0 0];
end
parameters.HHMobilityPD = cumsum(parameters.HHMobilityPD);

% Probabilty of death per year for each age group from ABS lifetable
DeathRatesAll = [0.01297;
0.00241;
0.00088;
0.00175;
0.00492;
0.00686;
0.01099;
0.01514;
0.02187;
0.03203;
0.04512;
0.06775;
0.08508;
0.11601;
0.15436;
0.20988;
0.31036;
0.37899];

% Convert probability of death per year into avg deaths per year, then avg
% deaths per day, then convert this rate back to probability
DeathRatesAll = -log(1-DeathRatesAll)/365/100; 
parameters.ProbabilityDeathAll = (1 - exp(-DeathRatesAll));

% Age structure in the model
parameters.AgeDeath = 84; % Max age of agent;
parameters.AgeClassDividersContacts = [0 1 5 15 19 50 parameters.AgeDeath];
parameters.NumberAgeClassesContacts = length(parameters.AgeClassDividersContacts) - 1;
parameters.AgeClassDividersDeath = [0 1 4:5:84];
parameters.NumberAgeClassesDeath = length(parameters.AgeClassDividersDeath) - 1;
parameters.AgeClassDividersAll = unique([parameters.AgeClassDividersContacts parameters.AgeClassDividersDeath]);
parameters.NumberAgeClassesAll = length(parameters.AgeClassDividersAll) - 1;
parameters.ACD = [0:5:80 parameters.AgeDeath]; %for demography comparison

% Contact rate matrix
% Data from https://doi.org/10.1371/journal.pone.0104786
% Daily number of age dependent contacts outsides households
parameters.ContactMatrix = [0.151162791	1.348837209	2.686046512	0.837209302	2.186046512	0.593023256;
0.311827957	3.301075269	3.451612903	0.935483871	2.365591398	0.688172043;
0.387755102	2.479591837	6.836734694	1.867346939	2.12244898	0.551020408;
0.373626374	1.417582418	4.164835165	4.714285714	3.846153846	0.714285714;
0.460431655	1.438848921	1.971223022	1.647482014	7.143884892	2.079136691;
0.262295082	0.885245902	1.68852459	0.983606557	5.049180328	1.918032787];

parameters.Ncontacts = parameters.ContactMatrix;

% Migration parameters
parameters.ImmigrationRatePerCapita = parameters.lhsinput(9) * parameters.dt; % per day, into and out of whole system
parameters.prevalence_in_migrants = 0;% prevalence of infection in immigrants

% Event migration parameters (assuming poisson distribution for size of events)
% Sporting event occur once a week on the same day, have a mean size, agents remain in
% community for a mean duration
parameters.SportActivitySize = parameters.lhsinput(2); % mean size
parameters.SportActivityFrequency = 7; % e.g., occurs every 7 days (units days)
parameters.SportActivityDuration = parameters.lhsinput(4) / 7; % mean duration (weeks) e.g., 1 day
parameters.LeaveSportActivityProbability = 1 - exp(-parameters.dt / parameters.SportActivityDuration); % probability per day host leaves community

% Funerals occur when there is a death in the community, have a mean size, agents remain in
% community for a mean duration
parameters.FuneralSize = parameters.lhsinput(3); % mean size
parameters.FuneralDuration = parameters.lhsinput(5) / 7; % mean duration (weeks) 
parameters.LeaveFuneralProbability = 1 - exp(-parameters.dt / parameters.FuneralDuration); % probability per day host leaves community

