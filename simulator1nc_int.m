
function [AgentCharacteristics, SummaryStatistics, parameters] = ...
    simulator1nc_int(AgentCharacteristics, parameters)

    % Pregenerate random numbers
    parameters = prn(parameters);

    % Initialise storage of summary statistics
    SummaryStatistics.Incidence = zeros(1, parameters.Ntimesteps);
    SummaryStatistics.AgeIncidence = zeros(parameters.AgeDeath, ceil(parameters.endtime));
    SummaryStatistics.YearlyAgeIncidencePerPerson = zeros(parameters.AgeDeath, ceil(parameters.endtime));
    SummaryStatistics.AgeDistributionOneYear = zeros(parameters.AgeDeath, parameters.Ntimesteps);
    SummaryStatistics.PopulationSizeTime = zeros(1,parameters.Ntimesteps);
    SummaryStatistics.PopSizeResidentsOnly = zeros(1,parameters.Ntimesteps);
    SummaryStatistics.NumberExposedTime = zeros(1,parameters.Ntimesteps);
    SummaryStatistics.NumberInfectiousTime = zeros(1,parameters.Ntimesteps);
    SummaryStatistics.NumberImmuneTime = zeros(1,parameters.Ntimesteps);
    SummaryStatistics.AgeDistributionPrevalence = zeros(length(parameters.ACDPrev)-1,parameters.Ntimesteps);
    SummaryStatistics = generate_summary_statistics(SummaryStatistics,1,parameters,AgentCharacteristics);
   
    % Time loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    AgentCharacteristics.InterventionStatus = zeros(parameters.PopSize,1);
    
    for i = 1 : parameters.Ntimesteps - 1 % for each time step

        CurrentYear = ceil(i/365); %this is nth year of the simulation
        
        % Sporting events occur once a week
        if rem(i,parameters.SportActivityFrequency) == 0
           SportingDay = 1;
        else
           SportingDay = 0;
        end

        KeepIndexAllAgents = 1 : length(AgentCharacteristics.ID); % this is the index of individuals

        % Store current agents' characteristics here
        CurrentExposed = AgentCharacteristics.Exposed;
        CurrentInfectious = AgentCharacteristics.Infectious;
        
        if sum(CurrentInfectious)==0
            break
        end
        
        CurrentImmune = AgentCharacteristics.Immune;
        CurrentHousehold = AgentCharacteristics.CurrentHousehold;
        CurrentIntStat = AgentCharacteristics.InterventionStatus;

        % E -> I
        [AgentCharacteristics,parameters] = progression(parameters,AgentCharacteristics,CurrentExposed);
        
        % Recovery from infection
        [AgentCharacteristics,parameters] = recovery(parameters,AgentCharacteristics,CurrentInfectious);

        % Transmission
        [AgentCharacteristics, parameters, SummaryStatistics] = ...
            transmission(parameters, AgentCharacteristics, CurrentExposed,... 
            CurrentInfectious, CurrentImmune, CurrentHousehold,...
            KeepIndexAllAgents, SummaryStatistics, CurrentYear,i,CurrentIntStat);

        % Household mobility
        [parameters, AgentCharacteristics] = hhmobility(parameters,AgentCharacteristics);

        % Aging
        [AgentCharacteristics, parameters, numberfunerals] = aging(parameters,AgentCharacteristics,i);

        % Migration into populations from outside (constant flow)
        [AgentCharacteristics, parameters] = migrationoutside(AgentCharacteristics, parameters);
        
       if parameters.Scenarios(4) == 1
           % Migration into populations from outside (due to funerals)  
           if numberfunerals > 0
               for k = 1 : numberfunerals
                   [AgentCharacteristics, parameters] = eventmigration(AgentCharacteristics, parameters, "funeral");
               end
           end

            % Migration into populations from outside (due to sporting match)
           if SportingDay == 1
               [AgentCharacteristics, parameters] = eventmigration(AgentCharacteristics, parameters, "sport");
           end

            % Leave population after event
           [AgentCharacteristics, parameters] = leaveafterevent(AgentCharacteristics, parameters);
       
       end
       
       % Calculate summary statistics
       SummaryStatistics = generate_summary_statistics(SummaryStatistics,i+1,parameters,AgentCharacteristics);

    end
    
    % Calculate incidence from age-incidence
    SummaryStatistics.Incidence = squeeze(sum(SummaryStatistics.AgeIncidence,1));

    % End time loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update agents due to progression to infection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics, parameters] = ...
        progression(parameters,AgentCharacteristics,CurrentExposed)

    % Find index of agents that are in latent phase 
    IAgentsExp =  find(CurrentExposed ==1);

    % Progression to infection occurs with probability PEtoI.
    % Remove index of agents from IAgentsImm that do not lose immunity.
    IAgentsExp(parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+length(IAgentsExp)-1) < (1 - parameters.PEtoI)) = [];

    % Update agents that progress to infection
    AgentCharacteristics.Exposed(IAgentsExp) = 0;
    AgentCharacteristics.Infectious(IAgentsExp) = 1;
    
    % Update intervention status for core household members
    CoreHouseholdInf = AgentCharacteristics.HouseholdList(IAgentsExp,1);
    CoreHouseholdInf = unique(CoreHouseholdInf);
    for l = 1:length(CoreHouseholdInf)
        chh = CoreHouseholdInf(l);
        AgentCharacteristics.InterventionStatus(squeeze(AgentCharacteristics.HouseholdList(:,1))==chh)=1;
    end

    % Update counter for pregenerated random numbers:
    parameters.countSCR = parameters.countSCR + length(IAgentsExp);
    if parameters.countSCR > 0.9*10^6
        parameters = updatecounter(parameters, "uniform");
    end

end

% Update agents due to infection recovery
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics,parameters] = ...
        recovery(parameters,AgentCharacteristics,CurrentInfectious)

    % Find index of agents that are infected
    IAgentsInf = find(CurrentInfectious > 0);

    % Recovery from a strain occurs with probability Precovery.
    % Remove index of agents from IAgentsInf that do not recover.
    IAgentsInf(parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+length(IAgentsInf)-1) < (1 - parameters.Precovery)) = [];

    % Update infection and immune status
    AgentCharacteristics.Infectious(IAgentsInf) = 0;
    AgentCharacteristics.Immune(IAgentsInf) = 1;

    % Update counter for pregenerated random numbers:
    parameters.countSCR = parameters.countSCR + length(IAgentsInf);
    if parameters.countSCR > 0.9*10^6
        parameters = updatecounter(parameters, "uniform");
    end
    

end

% Update agents due to transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics, parameters, SummaryStatistics] = ...
        transmission(parameters, AgentCharacteristics, CurrentExposed,...
        CurrentInfectious, CurrentImmune,CurrentHousehold, ...
        KeepIndexAllAgents, SummaryStatistics,CurrentYear,timestep,CurrentIntStat)

    % Find row indices of agents that are infected. And store in RowIndexInfected.
    % Start off with all agents and remove those which are not infected
    RowIndexInfected = KeepIndexAllAgents'; % all agents
    G = CurrentInfectious;
    RowIndexInfected(G==0)=[];
    InfectedAgentsThisTimeStep = [];

    AgeGroupAllAgents = calculate_age_groups(AgentCharacteristics.Age,parameters.AgeClassDividersContacts);

    if ~isempty(RowIndexInfected)
        % Determine susceptibility of each agent:
        % InfectionProbability stores the probability that each agent
        % will contract an infection following a contact
        
        % Agents who are exposed, infected, or immune have zero probability
        % of contracting infection.  Probability also reduced for agents
        % with CurrentIntStat = 1;

        InfectionProbability = parameters.Ptransmission .* ...
            (1 - CurrentInfectious) .* (1 - CurrentExposed) .* ...
            (1 - CurrentImmune) .* (1 - CurrentIntStat .* parameters.effectiveness_int);
     
        AgeGroupInfected = AgeGroupAllAgents(RowIndexInfected);

        % For each agent that is infected
        for j = 1 : length(RowIndexInfected)

            ACH = CurrentHousehold(RowIndexInfected(j));

            % Here are the indices of other agents in the same household:
            HouseholdContacts = KeepIndexAllAgents(CurrentHousehold==ACH);

            % Here are the indices of agents outside hh:
            NonHouseholdMembers = KeepIndexAllAgents(CurrentHousehold~=ACH);

            % Remove infected agent from HH contact list
            HouseholdContacts(HouseholdContacts==RowIndexInfected(j))=[];

            AgeGroupsNonHouseholdMembers = AgeGroupAllAgents(NonHouseholdMembers);

            % Determine number of contacts with other agents in
            % each age group
            X = parameters.ContactsNumberRand(AgeGroupInfected(j),:,parameters.countCNR);

            % Update counter for pregenerated random numbers:
            parameters.countCNR = parameters.countCNR + 1;
            if parameters.countCNR > 0.9*10^6
                parameters = updatecounter(parameters, "contacts");
            end

            % This is where we will store row indices of contacts:
            IndexOfContacts = HouseholdContacts;
            %AIDj = AgentCharacteristics.ID(RowIndexInfected(j));
            
            %SummaryStatistics.Contacts{AIDj,timestep,1} = AgentCharacteristics.ID(IndexOfContacts(:));
            
            IndCommContacts = [];
            % For each age group in community
            for m = 1 : length(X)

                % If the agent makes contact with other agents, find the
                % indices of these agents, add to list of contacts
                if X(m) > 0

                    % Find all contactable agents in this age group.
                    IndexContactableAgents = NonHouseholdMembers(AgeGroupsNonHouseholdMembers==m);
                    % Sample with replacement X(m) contacts
                    % from this list using pregenerated random
                    % numbers
                    IndexOfContactsTemp = ceil(length(IndexContactableAgents) * ...
                        parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+X(m)-1,1));
                    % Transform indices to original indices and
                    % include in the list of indices of
                    % contacts
                    try
                      tempca = IndexContactableAgents(IndexOfContactsTemp);
                    catch
                      tempca = [];
                    end
                    
                    IndCommContacts = [IndCommContacts(:); tempca(:)];
                    
                    % Update counter for pregenerated random numbers
                    parameters.countSCR = parameters.countSCR + X(m);
                    if parameters.countSCR > 0.9*10^6
                        parameters = updatecounter(parameters, "uniform");
                    end

                end
                
                IndexOfContacts = [IndexOfContacts IndCommContacts'];
                
                %SummaryStatistics.Contacts{AIDj,timestep,2} = AgentCharacteristics.ID(IndCommContacts);
                
                % Determine whether transmission occurs to
                % any of these susceptible contacts. 
                % Transmission Rule: More than
                % one transmission event can occur in the time step, but
                % susceptible hosts may only acquire one infection per time
                % step
                
                if ~isempty(IndexOfContacts)
                    
                    % Modify infection probability so there is increased risk from HH contacts
                    SSC=InfectionProbability;
                    SSC(HouseholdContacts) = parameters.HHtransmissionfactor*SSC(HouseholdContacts);

                    % Determine susceptibility of contacts
                    SusceptibilityStatusContacts =  SSC(IndexOfContacts);

                    % Determine which transmissions are successful.
                    % NewInfections = 1 if successful, 0 unsuccessful
                    % for each contact event
                    NewInfections = parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+length(IndexOfContacts)-1,1)<SusceptibilityStatusContacts;

                    % Update counter for pregenerated random numbers:
                    parameters.countSCR = parameters.countSCR + length(IndexOfContacts);
                    if parameters.countSCR > 0.9*10^6
                        parameters = updatecounter(parameters, "uniform");
                    end

                    if any(NewInfections)

                        % Need to check transmission rules.  Does anyone
                        % acquire more than one infection?
                        % Find new infections:
                        IndexOfContacts = IndexOfContacts(NewInfections == 1);

                        % If one contact is infected more than once, remove
                        % extra successful transmissions.  Do this by
                        % finding duplicate contact indices and
                        % removing extras from IndexOfContacts and InfectingStrains
                        % % SLOW:
                        % [IndexOfContacts, ~] = unique(IndexOfContacts);
                        % FAST:
                        [IndexOfContacts, ~] = sort(IndexOfContacts);
                        IndexOfContacts=IndexOfContacts([true;diff(IndexOfContacts(:))>0]);

                        % Now update infection status:
                        AgentCharacteristics.Exposed(IndexOfContacts) = 1;
                        
                        InfectedAgentsThisTimeStep = [InfectedAgentsThisTimeStep;IndexOfContacts'];
                        
                        % Make infected susceptibles not susceptible for next
                        % infected agent of interest:
                        InfectionProbability(IndexOfContacts) = 0;

                    end

                end
            end
        end
    end
    
    if length(InfectedAgentsThisTimeStep) ~= length(unique(InfectedAgentsThisTimeStep))
        msg = 'More than 1 infection of agent during timestep';
        error(msg)
    end
    
    % Update AgeIncidence
    AgesInfecteds = ceil(AgentCharacteristics.Age(InfectedAgentsThisTimeStep));
    NumInfectedEachAgeGroup = histcounts(AgesInfecteds,0:(parameters.AgeDeath));
    SummaryStatistics.AgeIncidence(:,CurrentYear) = ...
        SummaryStatistics.AgeIncidence(:,CurrentYear) + NumInfectedEachAgeGroup(:);

        
end

% Update agents due to aging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics, parameters, numberfunerals] = aging(parameters,AgentCharacteristics,timestep)

    AgentCharacteristics.Age = parameters.dt_years + ...
                    AgentCharacteristics.Age;

    % Death and Birth: remove agents that are older than
    % AgeDeath or that die during time step.  Creat new agents
    % according to the birth rate. Assign newborn to same random set of
    % households
    
    D=[];

    for j = 1: parameters.NumberAgeClassesDeath
        Dt = find(AgentCharacteristics.Age < parameters.AgeClassDividersDeath(j+1));
        Dt = Dt .* (rand(length(Dt),1)<parameters.ProbabilityDeathAll(j));
        Dt(Dt==0)=[];
        D = [D; Dt];
    end
    
    % Funerals are for agents that are permanent residents only (and only 
    % agents that die  with Age < AgeDeath, otherwise can get too many 
    % funerals in a time step)
    ResidencyOfFuneral = AgentCharacteristics.Residency(D);
    numberfunerals = length(ResidencyOfFuneral(ResidencyOfFuneral==0));
    
    D = [D; find(AgentCharacteristics.Age > parameters.AgeDeath)];
    
    % Remove agents that die
    AgentCharacteristics.Exposed(D) = [];
    AgentCharacteristics.Infectious(D) = [];
    AgentCharacteristics.Immune(D) = [];
    AgentCharacteristics.Age(D) = [];
    AgentCharacteristics.HouseholdList(D,:) = [];
    AgentCharacteristics.CurrentHousehold(D) = [];
    AgentCharacteristics.ID(D) = [];
    AgentCharacteristics.Residency(D) = [];
    AgentCharacteristics.InterventionStatus(D) = [];

   % Include agents that are born
    NumberBirths = length(D);

    if NumberBirths > 0

        % Random numbers for household selection
        rns = parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+5-1,1);
        % Update counter for random numbers
        parameters.countSCR = parameters.countSCR + 5;
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end

        newHouseholdList = zeros(NumberBirths,3);
        newCurrentHousehold = zeros(NumberBirths,1);
        newIDs = zeros(NumberBirths,1);
        rncount = 1;

        for j = 1: NumberBirths

            newIDs(j) = parameters.countID + j;           
            newhh = ceil(rns(rncount)*parameters.NumberHouses);
            newCurrentHousehold(j) = newhh;
            % Randomly select household list
            hhl = ceil(rns(rncount+1:rncount+3)*parameters.NumberHouses);
            newHouseholdList(j,:) = parameters.HHIDs(hhl)';
            parameters.nahh = histcounts(AgentCharacteristics.CurrentHousehold,parameters.NumberHouses);
        end
        
        AgentCharacteristics.Exposed = [AgentCharacteristics.Exposed; zeros(NumberBirths,1)];
        AgentCharacteristics.Infectious = [AgentCharacteristics.Infectious; zeros(NumberBirths,1)];
        AgentCharacteristics.Immune = [AgentCharacteristics.Immune; zeros(NumberBirths,1)];
        AgentCharacteristics.Age = [AgentCharacteristics.Age; 0.001 * ones(NumberBirths,1)];
        AgentCharacteristics.HouseholdList = [AgentCharacteristics.HouseholdList; newHouseholdList];
        AgentCharacteristics.CurrentHousehold = [AgentCharacteristics.CurrentHousehold; newCurrentHousehold];
        AgentCharacteristics.ID = [AgentCharacteristics.ID; newIDs];
        AgentCharacteristics.Residency = [AgentCharacteristics.Residency; zeros(NumberBirths,1)];
        AgentCharacteristics.InterventionStatus = [AgentCharacteristics.InterventionStatus; zeros(NumberBirths,1)];
        parameters.countID = max(AgentCharacteristics.ID);
        parameters.PopSize = length(AgentCharacteristics.ID);
        parameters.PopSizeResidentsOnly = length(AgentCharacteristics.Residency(AgentCharacteristics.Residency==0));

    end

end

% Update population change due to mobility between dwellings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [parameters, AgentCharacteristics] = hhmobility(parameters,AgentCharacteristics)

    IAgentsAll = (1:1:length(AgentCharacteristics.ID))';
    NewCurrentHH = AgentCharacteristics.CurrentHousehold;

    % Agents that are temporary residents (Residency ~= 0) do not
    % move houses, therefore do nothing

    % For permanent residents  determine new household
    RelevantAgents = IAgentsAll(AgentCharacteristics.Residency==0);
    NumberRelevantAgents = length(RelevantAgents);

    % Random numbers for mobility decisions
    rns = parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+NumberRelevantAgents-1,1);

    % Update counters for pregenerated random numbers
    parameters.countSCR = parameters.countSCR + NumberRelevantAgents;
    if parameters.countSCR > 0.9*10^6
        parameters = updatecounter(parameters, "uniform");
    end

    % For each agent, use random number to determine whether they
    % stay in core household, regular, on/off or a
    % random household.
    IAgentsCore = RelevantAgents(rns<parameters.HHMobilityPD(1));
    IagentsReg = RelevantAgents(~ismember(RelevantAgents,IAgentsCore) & rns<parameters.HHMobilityPD(2));
    IagentsSpor = RelevantAgents(rns>parameters.HHMobilityPD(3));
    IagentsOnoff = RelevantAgents(~ismember(RelevantAgents,[IAgentsCore; IagentsReg; IagentsSpor]));

    NewCurrentHH(IAgentsCore,1) = AgentCharacteristics.HouseholdList(IAgentsCore,1);
    NewCurrentHH(IagentsReg,1) = AgentCharacteristics.HouseholdList(IagentsReg,2);
    NewCurrentHH(IagentsOnoff,1) = AgentCharacteristics.HouseholdList(IagentsOnoff,3);

    SporadicHouses = ceil(parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+length(IagentsSpor)-1,1)*parameters.NumberHouses);
    NewCurrentHH(IagentsSpor,1) = parameters.HHIDs(SporadicHouses);

    % Update counter for random numbers
    parameters.countSCR = parameters.countSCR + length(IagentsSpor);
    if parameters.countSCR > 0.9*10^6
        parameters = updatecounter(parameters, "uniform");
    end

    % Update current household
    AgentCharacteristics.CurrentHousehold = NewCurrentHH;

end


% Update population change due to migration out of and into population (constant flow)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics, parameters] = migrationoutside(AgentCharacteristics, parameters)

    % Determine number of immigrants from pregenerated random numbers:
    NumMig = poissrnd(parameters.ImmigrationRatePerCapita * length(AgentCharacteristics.ID(AgentCharacteristics.Residency==0)));
    
    if NumMig > 0
        
        % Determine infection status of immigrants:
        Infected_migrants = (parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+NumMig-1,1) < parameters.prevalence_in_migrants);

        % Update counter for random numbers
        parameters.countSCR = parameters.countSCR + NumMig;
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end

        % Indices of agents leaving resident population:
        D = ceil(parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+NumMig-1,1) * length(AgentCharacteristics.ID(AgentCharacteristics.Residency==0)));
        RelevantIDs = AgentCharacteristics.ID(AgentCharacteristics.Residency==0);
        RelevantIDs = RelevantIDs(D); %IDs of agents being replaced
        %[~,D] = histc(RelevantIDs,AgentCharacteristics.ID); % only works
        %if AC.ID is sorted (which is not, so need to sort first:)       
        [As,s_idx] = sort(AgentCharacteristics.ID);
        [~,tmp] = histc(RelevantIDs,As);
        D = s_idx(tmp);
        
        % Update counter for random numbers
        parameters.countSCR = parameters.countSCR + NumMig;
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end

        % Create new IDs for agents
        AgentCharacteristics.ID(D) = (1:1:length(D))'+ parameters.countID;
        parameters.countID = max(AgentCharacteristics.ID);

        % Update infection, immune, age, hh, community status of the population:
        % For each agent leaving population replace with immigrant

        for h = 1 : NumMig

            % Immigrants are not infected:
            AgentCharacteristics.Exposed(D(h),:) = 0;
            AgentCharacteristics.Infectious(D(h),:) = 0;

            rns = parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+6-1,1);
            % Update counter for random numbers
            parameters.countSCR = parameters.countSCR + 6;
            if parameters.countSCR > 0.9*10^6
                parameters = updatecounter(parameters, "uniform");
            end

            randagent1 = ceil(rns(1) * length(AgentCharacteristics.ID));

            % immigrants have no immunity:
            AgentCharacteristics.Immune(D(h),:) = 0;
            AgentCharacteristics.InterventionStatus(D(h),:) = 0;

            % immigrants have same age and education status as that of an agent randomly selected from the population:
            AgentCharacteristics.Age(D(h)) = AgentCharacteristics.Age(randagent1);
            
            % immigrants are permanent residents
            AgentCharacteristics.Residency(D(h)) = 0;

            % immigrants enter household chosen at random       
            newhh = ceil(rns(3) * parameters.NumberHouses);
            AgentCharacteristics.CurrentHousehold(D(h)) = newhh;

            % Randomly select household list for migrant and update community staus
            hhl = ceil(rns(4:6)*parameters.NumberHouses);
            AgentCharacteristics.HouseholdList(D(h),:) = hhl';
            parameters.nahh = histcounts(AgentCharacteristics.CurrentHousehold,parameters.NumberHouses);

        end

        parameters.PopSize = length(AgentCharacteristics.ID);
        parameters.PopSizeResidentsOnly = length(AgentCharacteristics.Residency(AgentCharacteristics.Residency==0));
    
    end

end

% Update population change due to migration out of and into all populations (events)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [AgentCharacteristics, parameters] = eventmigration(AgentCharacteristics, parameters, type)

    if type == "sport"
        SizeE = parameters.SportRand(1,parameters.countASR);
        parameters.countASR = parameters.countASR + 1;
        if parameters.countASR > 0.9*10^6
            parameters = updatecounter(parameters, "sportsize");
        end
        Residency = 2*ones(SizeE,1);
    end

    if type == "funeral"
        SizeE = parameters.FuneralRand(1,parameters.countMFuR);
        parameters.countMFuR = parameters.countMFuR + 1;
        if parameters.countMFuR > 0.9*10^6
            parameters = updatecounter(parameters, "funeralsize");
        end
        Residency = 3*ones(SizeE,1);
    end
    
    if SizeE > 0

        % Calculate new entries in AgentCharacteristics for agents
        TempFiller1 = zeros(SizeE,1);

        %% IDs
        temp = (1:1:SizeE)';
        NewIDs = temp + parameters.countID;

        %% Infection status
        % Determine exposed status of immigrants:
        NewExposed = (parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+SizeE-1,1) < parameters.prevalence_in_migrants);
        % Update counter for random numbers
        parameters.countSCR = parameters.countSCR + SizeE;
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end
       
        %% Random numbers needed to characterise new agents
        rns = parameters.SamplingContactsRand(parameters.countSCR:parameters.countSCR+SizeE*5-1,1);
        % Update counter for random numbers
        parameters.countSCR = parameters.countSCR + SizeE*5;
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end

        randagents1 = ceil(rns(1*SizeE+1:2*SizeE) * length(AgentCharacteristics.ID));
        randhouses = ceil(rns(3*SizeE+1:4*SizeE) * parameters.NumberHouses);

        %% Immunity and intervention status
        % Immigrants have no short term immunity and none infectious
        NewImmunity = TempFiller1;
        NewInfectious = TempFiller1;

        %% Age
        % Immigrants have same age and intervention status as that of an agent
        % randomly selected from the population:
        NewAge = AgentCharacteristics.Age(randagents1);
        NewResidency = Residency;

        %% Household of new agents
        % immigrants enter household chosen at random
        NewHH = randhouses;
        NumNewAgentsEachHouse = hist(NewHH,parameters.HHIDs);
        
        % New health hardware status of current household
%        newCHH = (parameters.HealthHardwareStatus(NewHH))';

        % Update AgentCharacteristics with temporary residents
        AgentCharacteristics.ID = [AgentCharacteristics.ID; NewIDs];
        AgentCharacteristics.Exposed = [AgentCharacteristics.Exposed; NewExposed];
        AgentCharacteristics.Infectious = [AgentCharacteristics.Infectious; NewInfectious];
        AgentCharacteristics.Immune = [AgentCharacteristics.Immune; NewImmunity];
        AgentCharacteristics.Age = [AgentCharacteristics.Age; NewAge];
        AgentCharacteristics.Residency = [AgentCharacteristics.Residency; NewResidency];
        AgentCharacteristics.CurrentHousehold = [AgentCharacteristics.CurrentHousehold; NewHH];
        AgentCharacteristics.HouseholdList = [AgentCharacteristics.HouseholdList; repmat(NewHH,1,3)]; %household list is current house
        AgentCharacteristics.InterventionStatus = [AgentCharacteristics.InterventionStatus; TempFiller1];
        
        % Update Household stats
        parameters.nahh =  parameters.nahh + NumNewAgentsEachHouse;  
        parameters.countID = max(AgentCharacteristics.ID);
    end
    parameters.PopSize = length(AgentCharacteristics.Residency);
    parameters.PopSizeResidentsOnly = length(AgentCharacteristics.Residency(AgentCharacteristics.Residency==0));
end

% Update population once people leave after event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [AgentCharacteristics, parameters] = leaveafterevent(AgentCharacteristics, parameters)
    % AgentCharacteristics.Residency(i): status of host i with respect to community
    % residency: 0, they are permanent resident of community, 1 they are
    % temporary visitor for a festival, 2 for a sporting match, 3 for a funeral
    allagents = (1:1:length(AgentCharacteristics.ID))';

    % Those in community for sport:
    TemporaryResidentsSport = allagents(AgentCharacteristics.Residency==2);
    if isempty(TemporaryResidentsSport)==0
        % Remove agents from this list who do not return home
        TemporaryResidentsSport(parameters.SamplingContactsRand(...
            parameters.countSCR:parameters.countSCR+length(TemporaryResidentsSport)-1,1)<...
            1-parameters.LeaveSportActivityProbability)=[];
        parameters.countSCR = parameters.countSCR + length(TemporaryResidentsSport);
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end
    end
    
    % Those in community for funeral:
    TemporaryResidentsFuneral = allagents(AgentCharacteristics.Residency==3);
    if isempty(TemporaryResidentsFuneral)==0
        % Remove agents from this list who do not return home
        TemporaryResidentsFuneral(parameters.SamplingContactsRand(...
            parameters.countSCR:parameters.countSCR+length(TemporaryResidentsFuneral)-1,1)<...
            1-parameters.LeaveFuneralProbability)=[];
        parameters.countSCR = parameters.countSCR + length(TemporaryResidentsFuneral);
        if parameters.countSCR > 0.9*10^6
            parameters = updatecounter(parameters, "uniform");
        end
    end
    
    % Construct returning agents list
    D = [TemporaryResidentsSport(:); TemporaryResidentsFuneral(:)];

    % Remove agents that leave from agent characteristics
    AgentCharacteristics.Exposed(D) = [];
    AgentCharacteristics.Infectious(D) = [];
    AgentCharacteristics.Immune(D) = [];
    AgentCharacteristics.Age(D) = [];
    AgentCharacteristics.HouseholdList(D,:) = [];
    AgentCharacteristics.CurrentHousehold(D) = [];
    AgentCharacteristics.ID(D) = [];
    AgentCharacteristics.Residency(D) = [];
    AgentCharacteristics.InterventionStatus(D) = [];

    parameters.nahh = histcounts(AgentCharacteristics.CurrentHousehold,parameters.NumberHouses);
    parameters.PopSize = length(AgentCharacteristics.ID);
    parameters.PopSizeResidentsOnly = length(AgentCharacteristics.Residency(AgentCharacteristics.Residency==0));

end


% Calculate summary statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SummaryStatistics = generate_summary_statistics(SummaryStatistics,timestep,parameters,AgentCharacteristics)
    
    SummaryStatistics.NumberExposedTime(1,timestep) = sum(AgentCharacteristics.Exposed);
    SummaryStatistics.NumberInfectiousTime(1,timestep) = sum(AgentCharacteristics.Infectious);
    SummaryStatistics.NumberImmuneTime(1,timestep) = sum(AgentCharacteristics.Immune);
    SummaryStatistics.AgeDistributionPrevalence(:,timestep) = ...
        calculate_age_dist_prev(AgentCharacteristics.Infectious,AgentCharacteristics.Age,parameters.ACDPrev);
    SummaryStatistics.PopulationSizeTime(1,timestep) = length(AgentCharacteristics.ID);
    SummaryStatistics.PopSizeResidentsOnly(1,timestep) = length(AgentCharacteristics.ID(AgentCharacteristics.Residency==0));
    SummaryStatistics.AgeDistribution(timestep,:) = histcounts(AgentCharacteristics.Age, parameters.ACD);
    SummaryStatistics.AgeDistributionOneYear(:,timestep) = histcounts(AgentCharacteristics.Age, 0:parameters.AgeDeath);
end


% Calcuate prevalence in each age group in population
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AgeDistPrev = calculate_age_dist_prev(ACI,Age,AgeCat)
    ACI = sum(ACI); %sums number of infection of each agent
    ACI(ACI>0) = 1; %assigns value of 1 to each agent if infected
    agePrev = Age.*ACI; %stores ages of infected agents, 0 otherwise
    agePrev(agePrev==0) = []; % removes uninfected agents
    AgeDist = histcounts(Age,AgeCat); % counts number agents in each age cat
    AgeDistPrev = histcounts(agePrev,AgeCat); % counts infected agents in each age cat
    AgeDistPrev = AgeDistPrev(:) ./ AgeDist(:); % calculates prevalence in each age cat
end

% Pregenerate random numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parameters = prn(parameters)

    parameters.SportRand = poissrnd(parameters.SportActivitySize,1,1e6);
    parameters.countASR = 1;
    parameters.FuneralRand = poissrnd(parameters.FuneralSize,1,1e6);
    parameters.countMFuR = 1;

    % Generate random numbers for sampling contacts, recovery and
    % mobility
    parameters.SamplingContactsRand = rand(1e6,1);
    parameters.countSCR = 1;

    % Generate random numbers for number of contacts
    parameters.ContactsNumberRand = zeros(parameters.NumberAgeClassesContacts,parameters.NumberAgeClassesContacts,1e6);
    for ii = 1: parameters.NumberAgeClassesContacts
        for jj = 1: parameters.NumberAgeClassesContacts
            parameters.ContactsNumberRand(ii,jj,:)=poissrnd(parameters.Ncontacts(ii,jj),[1e6,1]);
        end
    end
    parameters.countCNR = 1;

end

function parameters = updatecounter(parameters, type)

    if type == "uniform"

        parameters.SamplingContactsRand = rand(1e6,1);
        parameters.countSCR = 1;

    end

    if type == "sportsize"

        parameters.SportRand = poissrnd(parameters.SportActivitySize,1,1e6);
        parameters.countASR = 1;

    end

    if type == "funeralsize"

        parameters.FuneralRand = poissrnd(parameters.FuneralSize,1,1e6);
        parameters.countMFuR = 1;

    end

    if type == "contacts"

        for ii = 1: parameters.NumberAgeClassesContacts
            for jj = 1: parameters.NumberAgeClassesContacts
                parameters.ContactsNumberRand(ii,jj,:)=poissrnd(parameters.Ncontacts(ii,jj),[1e6,1]);
            end
        end
        parameters.countCNR = 1;

    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AgeGroup = calculate_age_groups(Ages,ACD)
    AgeGroup = zeros(size(Ages));
    for pp = 1: length(ACD)-1
        AgeGroup(Ages >= ACD(pp) & Ages < ACD(pp+1)) = pp;
    end
end

%%
