% Initiaise simulation scenarios for each LHS parameter sample.

% Six transmisison scenarios, each repeated for N in {2500,500}, with and 
% without fluid dwelling occupancy, and with and without event-based 
% migration.
% Total number of transmisison scenarios = 6 * (2*2*2) = 48.

% Transmission scenarios considered:
% 1: Base case
% 2: Lower qhat
% 3: Less crowding
% 4: Higher q
% 5: Lower qhat and less crowding
% 6: Higher q and less crowding

clear all

rng(1)

p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(32); %insert max number of cores here
end

NumberLHSSamples = 1000;
NumberScenarioSets = 6;
NumberScenariosPerSet = 8;
Scenarios = zeros(NumberScenariosPerSet,4,NumberScenarioSets);

% Sx = [N H occupancy_model events_setting]
% occupancy_model = 6: fluid occupancy
% occupancy_model = 1: stable occupancy
% events_setting = 0: no event-based migration
% events_setting = 1: with event-based migration

% Overcrowded scenarios:
S1 = [2500 358 6 0;
    2500 358 1 0;
    2500 358 6 1;
    2500 358 1 1;
    500 80 6 0;
    500 80 1 0;
    500 80 6 1;
    500 80 1 1];

% Less crowded scenarios:
S2 = [2500 833 6 0;
    2500 833 1 0;
    2500 833 6 1;
    2500 833 1 1;
    500 160 6 0;
    500 160 1 0;
    500 160 6 1;
    500 160 1 1];
                
Scenarios(:,:,1) = S1;
Scenarios(:,:,2) = S1;
Scenarios(:,:,3) = S2;
Scenarios(:,:,4) = S1;
Scenarios(:,:,5) = S2;
Scenarios(:,:,6) = S2;

% Generate LHS samples:
% Base case
[P1, ~] = lhs_sample_generation(NumberLHSSamples,0,1);
% Lower qhat 
[P2, ~] = lhs_sample_generation(NumberLHSSamples,0,0);
% Higher q
[P3, ~] = lhs_sample_generation(NumberLHSSamples,1,1);

ParameterSamples(:,:,1) = P1;
ParameterSamples(:,:,2) = P2;
ParameterSamples(:,:,3) = P1;
ParameterSamples(:,:,4) = P3;
ParameterSamples(:,:,5) = P1;
ParameterSamples(:,:,6) = P3;

endtime = 5; % Maximum duration of each simulation in years

% This is where we will store the initialised agent characteristics and 
% parameters to run each simulation:
ACmaster = cell(NumberScenariosPerSet,NumberLHSSamples);
pmaster = cell(NumberScenariosPerSet,NumberLHSSamples);

for k = 1: NumberScenarioSets
    for i = 1: NumberScenariosPerSet
        S = Scenarios(i,:,k);

        parfor j = 1:NumberLHSSamples
            [k,i,j]
            parameters=[];

            parameters.lhsinput = ParameterSamples(j,:,k);
            parameters.Scenarios = S;
            parameters.T = endtime * 52.14; % Duration of simulation (weeks)
            parameters.endtime = endtime; % Duration of simulation (years)

            % Load population parameters
            parameters = parameters_basenc(parameters);

            % Initialise age structure and household structure
            [AgentCharacteristics, parameters] = ...
                initialise_demographicsnc(parameters);

            % Initialise infection and immunity status
            [AgentCharacteristics, parameters] = ...
                initialise_agents(AgentCharacteristics,parameters);

            % Load infection-related parameters
            parameters = parameters_infection(parameters);

            ACmaster{i,j} = AgentCharacteristics;
            pmaster{i,j} = parameters;

        end
    end
    
    fnames = sprintf ( '%s%i', 'Initialisation_S', k);
    save(fnames,'ACmaster','pmaster');
        
end


