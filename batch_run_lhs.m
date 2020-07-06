rng(2)

p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(32); %insert max number of cores here
end
 

for k = 1:6
    
    % For each scenario set, load initialised population and LHS parameter 
    % values 
    fnamel = sprintf ( '%s%i%s', 'Initialisation_S', k,'.mat');
    load(fnamel)
    
    NumberScenarios = 8; % for each scenario set
    NumberLHSSamples = 1000;
    
    % Preallocate memory to store data for each scenario set:
    I = zeros(NumberScenarios,NumberLHSSamples); %Incidence
    P = cell(NumberScenarios,NumberLHSSamples); %Prevalence
    DO = zeros(NumberScenarios,NumberLHSSamples); %Duration of outbreak
    SCHH = zeros(NumberScenarios,NumberLHSSamples,2,6); %Contacts within dwellings (unique and total)
    SCC = zeros(NumberScenarios,NumberLHSSamples,2,6); %Contacts outside dwellings (unique and total)
    
    % Preallocate memory to store data within parfor loop
    Incidence = zeros(NumberLHSSamples,1);
    DurationOutbreak = Incidence;
    Prev = cell(NumberLHSSamples,1);
    StatsContactsHH = zeros(NumberLHSSamples,2,6);
    StatsContactsCom = zeros(NumberLHSSamples,2,6);

    for i = 1: NumberScenarios
        
        % For each LHS parameter sample
        parfor j = 1:NumberLHSSamples
            [k,i,j]
            
            % Load paramters and agent characteristics
            parameters = pmaster{i,j};
            AgentCharacteristics = ACmaster{i,j};
            
            % Simulate outbreak
            [~, SummaryStatistics, parameters] = ...
                simulator1nc(AgentCharacteristics, parameters);
            
            % Store outbreak data
            Incidence(j)=SummaryStatistics.Incidence(1);
            Prev{j}=SummaryStatistics.NumberInfectiousTime(SummaryStatistics.NumberInfectiousTime>0) ./ ...
                SummaryStatistics.PopulationSizeTime(SummaryStatistics.NumberInfectiousTime>0);
            DurationOutbreak(j)= length(Prev{j});
            StatsContactsHH(j,:,:) = SummaryStatistics.HHContactStats;
            StatsContactsCom(j,:,:) = SummaryStatistics.ComContactStats;

        end

        I(i,:) = Incidence';
        P{i} = Prev;
        DO(i,:) = DurationOutbreak;
        SCHH(i,:,:,:) = StatsContactsHH;
        SCC(i,:,:,:) = StatsContactsCom;
        
        % Save outbreak data for each scenario set separately 
        fnames = sprintf ( '%s%i', 'batch_S', k);
        save(fnames,'I','P','DO','SCHH','SCC');
        

    end

   
    
end

