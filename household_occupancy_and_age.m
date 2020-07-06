% Before running this script, open up simulator1nc.m and uncomment lines
% 22-25, and 747-749 , and comment line 52.  When finished, revert these 
% changes to run any of the other scripts in the repository. 

close all

set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')

parameters.lhsinput = [1.9081   76.2688 14.5932...
                        1.0120  6.0253 1.8458...
                        2.8309   0.0130 0.0025];
endtime = 5;

fignames = {'No_event_migration_occupancy','No_event_migration_age',...
            'With_event_migration_occupancy','With_event_migration_age'}; 
        
for i = 0:1
    
    rng(2)

    parameters.Scenarios = [759 176 6 i];
    parameters.T = endtime * 52.14; % Duration of simulation (weeks)
    parameters.endtime = endtime; % Duration of simulation (years)

    % Load population parameters
    parameters = parameters_basenc(parameters);

    % Initialise age structure and household structure
    [AgentCharacteristics, parameters] = ...
        initialise_demographicsnc(parameters);

    close fig 100

    % Initialise infection and immunity status
    [AgentCharacteristics, parameters] = ...
        initialise_agents(AgentCharacteristics,parameters);

    % Load infection-related parameters
    parameters = parameters_infection(parameters);

    [~, SummaryStatistics, parameters] = ...
                simulator1nc(AgentCharacteristics, parameters);

    timeyears = (parameters.time) / 52.14;
    idx = find(timeyears>0);

    Houses = [153 154 156:160 165:169];

    time1 = 3*365;
    Timesteps = time1:time1+220;
    for i = 1:length(Houses)
        house = Houses(i);
        Allpeopleinhouse = [];
        for k = 1: 221
            timestep = Timesteps(k);
            Allpeopleinhouse = [Allpeopleinhouse; SummaryStatistics.HHMembers{house,timestep}];
        end
        [C,ia,ic] = unique(Allpeopleinhouse);
        day_counts = accumarray(ic,1);
        day_counts = sort(day_counts,'descend');
        HH03{i}=day_counts;
    end


    NumberCoreResidents = histcounts(AgentCharacteristics.HouseholdList(:,1),parameters.NumberHouses);
    NumberRegResidents = histcounts(AgentCharacteristics.HouseholdList(:,2),parameters.NumberHouses);
    NumberOOResidents = histcounts(AgentCharacteristics.HouseholdList(:,3),parameters.NumberHouses);


    figure
    for i = 1:length(Houses)
        temp = HH03{i};
        NCR = NumberCoreResidents(Houses(i));
        NRR = NumberRegResidents(Houses(i));
        NOR = NumberOOResidents(Houses(i));
        temp=temp(temp>0);
        subplot(3,4,i)
        bar(temp,'FaceColor',[0.5 .5 .5]);
        title(['\{',num2str(NCR),', ',num2str(NRR),', ',num2str(NOR),'\}'])

    end
    drawnow

    figure
    subplot(1,4,1)
    histogram(AgentCharacteristics.Age,84)
    xlabel('Age')
    ylabel('Number of people')
    axis([0 85 0 25])
    subplot(1,4,2)
    histogram(NumberCoreResidents)
    xlabel('Number of core residents')
    ylabel('Number of houses')
    axis([0 15 0 45])
    subplot(1,4,3)
    histogram(NumberRegResidents)
    xlabel('Number of regular residents')
    ylabel('Number of houses')
    axis([0 15 0 45])
    subplot(1,4,4)
    histogram(NumberOOResidents)
    xlabel('Number of on/off residents')
    ylabel('Number of houses')
    axis([0 15 0 45])
    drawnow
    
end

for j = 1:4
    if j == 1
        figure(j)
        drawnow
        filetitle = sprintf ( '%s%s', fignames{1}, '.fig');
        savefig(filetitle)
    elseif j == 2
        figure(j)
        drawnow
        filetitle = sprintf ( '%s%s', fignames{2}, '.fig');
        savefig(filetitle)
    elseif j == 3
        figure(j)
        drawnow
        filetitle = sprintf ( '%s%s', fignames{3}, '.fig');
        savefig(filetitle)
    else
        figure(j)
        drawnow
        filetitle = sprintf ( '%s%s', fignames{4}, '.fig');
        savefig(filetitle)
    end
end
