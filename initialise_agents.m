function [AgentCharacteristics, parameters] = initialise_agents(AgentCharacteristics,parameters)
    
    % Randomly select NI0 agents to be exposed and infected in 
    % population, and randomly select RI0 to have  
    % immunity in population.
    
    % Assign an index to each agent
    AgentIndexInf = (1 : 1 : parameters.PopSize)';
    AgentIndexImm = AgentIndexInf;

    % Choose agents to be infected
    InfectiousAgents = randperm(length(AgentIndexInf),parameters.NI0);
    ImmuneAgents = randperm(length(AgentIndexImm),parameters.NR0);

    % Update agent's characteristics 
    AgentCharacteristics.Infectious(AgentIndexInf(InfectiousAgents)) = 1;         
    AgentCharacteristics.Immune(AgentIndexImm(ImmuneAgents)) = 1;


end
