function [AgentCharacteristics, parameters] = initialise_demographicsnc(parameters)

    HouseholdList = [];

    % Specify core houses of each agent
    RelevantHHIDs = parameters.HHIDs;
    CoreHH = datasample(1:parameters.NumberHouses,parameters.PopSize);
    CoreHH = RelevantHHIDs(CoreHH);
    figure(100)
    hc = histogram(CoreHH,parameters.NumberHouses);
    drawnow
    vc = hc.Values;
    % Make sure no houses are without core residents.  If there are,
    % add additional members to the population to populate
    if isempty(vc(vc==0))==0
        NumberNewPeople = length(vc(vc==0));
        x = find(vc==0);
        CoreHH = [CoreHH; x(:)];
        parameters.PopSize = parameters.PopSize + NumberNewPeople;
        parameters.PopSize = sum(parameters.PopSize);
    end
    % Specify regular and OnOff houses of each agent
    RegularHH = datasample(1:parameters.NumberHouses,parameters.PopSize);%,'Weights',parameters.MaxPopSizeEachHH{i});
    RegularHH = RelevantHHIDs(RegularHH);
    OnOffHH = datasample(1:parameters.NumberHouses,parameters.PopSize);%,'Weights',parameters.MaxPopSizeEachHH{i});
    OnOffHH = RelevantHHIDs(OnOffHH);
    HouseholdList = [HouseholdList; CoreHH(:) RegularHH(:) OnOffHH(:)];

    Infections = zeros(parameters.PopSize, 1);

    load('data/age_distribution.mat','B')
    Age = datasample(0:1:89,parameters.PopSize,'Weights',B);
    Age(Age>=parameters.AgeDeath)=0;
    CurrentHousehold = HouseholdList(:,1);
    % Number of agents in each household
    parameters.nahh = histcounts(CurrentHousehold,parameters.NumberHouses);

    ID=(1:1:parameters.PopSize)';
    parameters.countID = max(ID);

    % AgentCharacteristics.XXX(i,j): is the XXX status of agent i. 
    % Specifically,
    % AgentCharacteristics.Exposed(i,1): 0 = not exposed, 
    % 1 = exposed.
    % AgentCharacteristics.Infectious(i,1): 0 = not infectious, 
    % 1 = infectious.  
    % AgentCharacteristics.Immune(i,1): 0 = not immune, 
    % 1 = immune.
    % AgentCharacteristics.Age(i): is the age of agent i
    % and is sampled from a uniform distribtion   
    % AgentCharacteristics.Residency(i): status of host i with respect to 
    % community residency: 0, they are permanent resident of community, 
    % 2 temporary resideny for a sporting match, 3 for a funeral

    AgentCharacteristics.Exposed = Infections;
    AgentCharacteristics.Infectious = Infections;
    AgentCharacteristics.Immune = Infections;
    AgentCharacteristics.Age = Age';
    AgentCharacteristics.HouseholdList = HouseholdList;
    AgentCharacteristics.CurrentHousehold = CurrentHousehold;
    AgentCharacteristics.ID = ID;   
    AgentCharacteristics.Residency = zeros(parameters.PopSize,1);


end
