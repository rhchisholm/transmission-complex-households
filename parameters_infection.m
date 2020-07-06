function parameters = parameters_infection(parameters)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define all pathogen parameters for baseline simluation here %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters.ACDPrev = [0,5,12,18,40,65,parameters.AgeDeath]; %for age dist prevalence

% Within-host parameters
parameters.Ptransmission = parameters.lhsinput(8); % Modify this to get the right prevalence
parameters.HHtransmissionfactor = parameters.lhsinput(1); % Relative risk of infections from HH contact compared to community contact.  Perhaps estimate this from genomic analysis of McDondald data
parameters.DurationExposed = parameters.lhsinput(6)/7; % Duration of latent period (weeks)
parameters.DurationInfectious = parameters.lhsinput(7)/7; % Duration of infectious period (weeks)

% Parameters governing rates and probabilities of events
parameters.REtoI = 1 / parameters.DurationExposed; % base rate E -> I per week
parameters.PEtoI = 1 - exp(- parameters.dt * parameters.REtoI); % base probability E -> I per time step
parameters.Rrecovery = 1 / parameters.DurationInfectious; % base recovery rate per week
parameters.Precovery = 1 - exp(- parameters.dt * parameters.Rrecovery); % base recovery probability per time step
