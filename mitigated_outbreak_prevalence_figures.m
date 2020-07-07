close all
clear all


set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')

ind = [1 2;3 4;5 6;7 8];

fignames = {'N = 2500, no events','N = 2500, with events',...
            'N = 500, no events','N = 500, with events'};
        
fignames_new = {'N = 2500, no events, 100% effective','N = 2500, with events, 100% effective',...
    'N = 500, no events, 100% effective','N = 500, with events, 100% effective'};

% Overcrowded scenarios:
S1 = [2500 358 1 0;
    2500 358 0 0;
    2500 358 1 1;
    2500 358 0 1;
    500 80 1 0;
    500 80 0 0;
    500 80 1 1;
    500 80 0 1];

% Less crowded scenarios:
S2 = [2500 833 1 0;
    2500 833 0 0;
    2500 833 1 1;
    2500 833 0 1;
    500 160 1 0;
    500 160 0 0;
    500 160 1 1;
    500 160 0 1];

Output1 = zeros(48,17);
Output2 = zeros(48,17);

for j = 1:4
    ftitle =  fignames{j};
    ftitle = sprintf ( '%s%s', ftitle,'.fig');
    open(ftitle)
end

for k = 1:6
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_int_new', k,'.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_int_S', k,'_100.mat');
    load(fnamel)
    
    if k ==  1 || k == 2 || k == 4
        S = S1;
    else
        S = S2;
    end
    
    
    for j = 1:4
        
        figure(j)
        index1 = ind(j,1);
        index2 = ind(j,2);
        
        Prev = P{index1};
        Incidence = I(index1,:);
        DurationOutbreak = DO(index1,:);
        Prev2 = P{index2};
        Incidence2 = I(index2,:);
        DurationOutbreak2 = DO(index2,:);

        QDO = quantile(DurationOutbreak(Incidence>10),[0.025 0.25 0.50 0.75 0.975]);
        QTS = quantile(Incidence(Incidence>10),[0.025 0.25 0.50 0.75 0.975]);
        QDO2 = quantile(DurationOutbreak2(Incidence2>10),[0.025 0.25 0.50 0.75 0.975]);
        QTS2 = quantile(Incidence2(Incidence2>10),[0.025 0.25 0.50 0.75 0.975]);
        OTO = length(DurationOutbreak(Incidence>10));
        OTO2 = length(DurationOutbreak2(Incidence2>10));

        FS = [OTO; OTO2];
        All = [QDO QTS; QDO2 QTS2];
        
        Rows = (k-1)*8 + ((2*j-1):2*j);
        
        Scen = [k;k];
        SPs = S(((2*j-1):2*j),:);
        
        Output1(Rows,:) = [Scen SPs FS FS/1000*100 All];

        PP = zeros(100,1000);
        PP2 = PP;
        count= 1;
        for i =1:1000
            if Incidence(i)>10
                PP(1:length(Prev{i}),count) = Prev{i};
                count=count+1;
            end

        end

        count2= 1;
        for i =1:1000
            if Incidence2(i)>10
                PP2(1:length(Prev2{i}),count2) = Prev2{i};
                count2=count2+1;
            end

        end

        QPP = quantile(PP(:,1:count-1)',[0.025 0.25 0.50 0.75 0.975]);
        QPP2 = quantile(PP2(:,1:count2-1)',[0.025 0.25 0.50 0.75 0.975]);
        y1 = QPP(3,:)*100;
        y2 = QPP2(3,:)*100;

        x1 = 1:1:size(QPP,2);
        x2 = 1:1:size(QPP2,2);
        x_axis = x1;
        x_plot =[x_axis, fliplr(x_axis)];
        x_axis2 = x2;
        x_plot2 =[x_axis2, fliplr(x_axis2)];
        y_plot=[QPP(2,:), flipud(QPP(4,:)')']*100;
        y_plot2=[QPP2(2,:), flipud(QPP2(4,:)')']*100;
        
        subplot(2,3,k)
        plot(x_axis, y1, '-.m', 'linewidth', 2)
        hold on
        fill(x_plot, y_plot, 1,'facecolor', 'magenta', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        plot(x_axis2, y2, '.b', 'linewidth', 2)
        hold on
        fill(x_plot2, y_plot2, 1,'facecolor', 'blue', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        
        axis([0 120 0 14])
        %legend({'median, multi-hh model','50%CI, multi-hh model','median, single-hh model','50%CI, single-hh model'})
        xlabel('Time (days)')
        ylabel('Prevalence (%)')
        drawnow
        
           
    end
    
end


for j = 1:4
    figure(j)
    subplot(2,3,2)
    ftitle =  fignames_new{j};
    title(ftitle)
    drawnow
    filetitle = sprintf ( '%s%s', fignames_new{j}, '.fig');
    savefig(filetitle)
end

fignames_new2 = {'N = 2500, no events, 50% effective','N = 2500, with events, 50% effective',...
    'N = 500, no events, 50% effective','N = 500, with events, 50% effective'};

for j = 1:4
    ftitle =  fignames{j};
    ftitle = sprintf ( '%s%s', ftitle,'.fig');
    open(ftitle)
end

for k = 1:6
    
    if k ==  1 || k == 2 || k == 4
        S = S1;
    else
        S = S2;
    end
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_int_new', k,'_50.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_int_S', k,'_50.mat');
    load(fnamel)
    
    
    for j = 1:4
        
        figure(j+4)
        index1 = ind(j,1);
        index2 = ind(j,2);
        
        Prev = P{index1};
        Incidence = I(index1,:);
        DurationOutbreak = DO(index1,:);
        Prev2 = P{index2};
        Incidence2 = I(index2,:);
        DurationOutbreak2 = DO(index2,:);

        QDO = quantile(DurationOutbreak(Incidence>10),[0.025 0.25 0.50 0.75 0.975]);
        QTS = quantile(Incidence(Incidence>10),[0.025 0.25 0.50 0.75 0.975]);
        QDO2 = quantile(DurationOutbreak2(Incidence2>10),[0.025 0.25 0.50 0.75 0.975]);
        QTS2 = quantile(Incidence2(Incidence2>10),[0.025 0.25 0.50 0.75 0.975]);
        OTO = length(DurationOutbreak(Incidence>10));
        OTO2 = length(DurationOutbreak2(Incidence2>10));

        FS = [OTO; OTO2];
        All = [QDO QTS; QDO2 QTS2];
        
        Rows = (k-1)*8 + ((2*j-1):2*j);
        
        Scen = [k;k];
        SPs = S(((2*j-1):2*j),:);
        
        Output2(Rows,:) = [Scen SPs FS FS/1000*100 All];

        PP = zeros(100,1000);
        PP2 = PP;
        count= 1;
        for i =1:1000
            if Incidence(i)>10
                PP(1:length(Prev{i}),count) = Prev{i};
                count=count+1;
            end

        end

        count2= 1;
        for i =1:1000
            if Incidence2(i)>10
                PP2(1:length(Prev2{i}),count2) = Prev2{i};
                count2=count2+1;
            end

        end

        QPP = quantile(PP(:,1:count-1)',[0.025 0.25 0.50 0.75 0.975]);
        QPP2 = quantile(PP2(:,1:count2-1)',[0.025 0.25 0.50 0.75 0.975]);
        y1 = QPP(3,:)*100;
        y2 = QPP2(3,:)*100;

        x1 = 1:1:size(QPP,2);
        x2 = 1:1:size(QPP2,2);
        x_axis = x1;
        x_plot =[x_axis, fliplr(x_axis)];
        x_axis2 = x2;
        x_plot2 =[x_axis2, fliplr(x_axis2)];
        y_plot=[QPP(2,:), flipud(QPP(4,:)')']*100;
        y_plot2=[QPP2(2,:), flipud(QPP2(4,:)')']*100;
        
        subplot(2,3,k)
        plot(x_axis, y1, '-.m', 'linewidth', 2)
        hold on
        fill(x_plot, y_plot, 1,'facecolor', 'magenta', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        plot(x_axis2, y2, '.b', 'linewidth', 2)
        hold on
        fill(x_plot2, y_plot2, 1,'facecolor', 'blue', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        
        axis([0 120 0 14])
        %legend({'median, multi-hh model','50%CI, multi-hh model','median, single-hh model','50%CI, single-hh model'})
        xlabel('Time (days)')
        ylabel('Prevalence (%)')
        drawnow
        
           
    end
    
    
end

for j = 1:4
    figure(j+4)
    subplot(2,3,2)
    ftitle =  fignames_new2{j};
    title(ftitle)
    drawnow
    filetitle = sprintf ( '%s%s', fignames_new2{j}, '.fig');
    savefig(filetitle)
end

Rownames = {'ScenarioSet','N','H','Fluid','Events',...
    'NumOutbreaks','PercentOutbreaks',...
    'DurOB2p5PC','DurOB25PC','DurOB50PC','DurOB75PC','DurOB97p5PC',...
    'SizeOB2p5PC','SizeOB25PC','SizeOB50PC','SizeOB75PC','SizeOB97p5PC',...
    'MedianPCReductionOBDur','MedianPCReductionOBSize'};

load('Outputs_unmitigated.mat','Output')

ReductionMedianDuration100 = 100 - Output1(:,10)./Output(:,10)*100;
ReductionMedianDuration50 = 100 - Output2(:,10)./Output(:,10)*100;
ReductionMedianSize100 = 100 - Output1(:,15)./Output(:,15)*100;
ReductionMedianSize50 = 100 - Output2(:,15)./Output(:,15)*100;

Output1B = [Output1 ReductionMedianDuration100 ReductionMedianSize100];
Output2B = [Output2 ReductionMedianDuration50 ReductionMedianSize50];

A1 = array2table(Output1B,'VariableNames',Rownames);
filename = 'Outputs_mitigated_100.xlsx';
writetable(A1,filename)
save('Outputs_mitigated_100.mat','Output1B')

A2 = array2table(Output2B,'VariableNames',Rownames);
filename = 'Outputs_mitigated_50.xlsx';
writetable(A2,filename)
save('Outputs_mitigated_50.mat','Output2B')




