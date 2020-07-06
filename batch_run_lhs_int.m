rng(2)

Effectiveness_intervention = 0.5;

p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool(32); %insert max number of cores here
end

for k = 1:6
    
    fnamel = sprintf ( '%s%i%s', 'Initialisation_S', k,'.mat');
    load(fnamel)
    
    NumberScenarios = 8;
    NumberLHSSamples = 1000;

    I = zeros(NumberScenarios,NumberLHSSamples);
    P = cell(NumberScenarios,NumberLHSSamples);
    DO = zeros(NumberScenarios,NumberLHSSamples);
    LHSsample = zeros(NumberScenarios,NumberLHSSamples,17);

    Incidence = zeros(NumberLHSSamples,1);
    DurationOutbreak = Incidence;
    Prev = cell(NumberLHSSamples,1);
    LHSparams = zeros(NumberLHSSamples,17);

    for i = 1: NumberScenarios
        
        parfor j = 1:NumberLHSSamples
            [k,i,j]
            parameters = pmaster{i,j};
            AgentCharacteristics = ACmaster{i,j};
            
            parameters.effectiveness_int = Effectiveness_intervention;

            [~, SummaryStatistics, parameters] = ...
                simulator1nc_int(AgentCharacteristics, parameters);

            Incidence(j)=SummaryStatistics.Incidence(1);
            Prev{j}=SummaryStatistics.NumberInfectiousTime(SummaryStatistics.NumberInfectiousTime>0) ./ ...
                SummaryStatistics.PopulationSizeTime(SummaryStatistics.NumberInfectiousTime>0);
            DurationOutbreak(j)= length(Prev{j});
            LHSparams(j,:) = parameters.lhsinput;

        end

        I(i,:) = Incidence';
        P{i} = Prev;
        DO(i,:) = DurationOutbreak;
        LHSsample(i,:,:) = LHSparams; 
        
        fnames = sprintf ( '%s%i%s%d', 'batch_int_S', k, '_', Effectiveness_intervention*100 );
        save(fnames,'I','P','DO');

    end
 
end

