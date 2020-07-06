close all
clear all


set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')

ind = [1 2;3 4;5 6;7 8];

fignames = {'N = 2500, no events','N = 2500, with events','N = 500, no events','N = 500, with events'};

for k = 1:1
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_new', k,'.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_S', k,'.mat');
    load(fnamel)
    
    
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
        plot(x_axis, y1, '-r', 'linewidth', 2)
        hold on
        fill(x_plot, y_plot, 1,'facecolor', 'red', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        plot(x_axis2, y2, '--k', 'linewidth', 2)
        hold on
        fill(x_plot2, y_plot2, 1,'facecolor', 'black', 'edgecolor', 'none', 'facealpha', 0.2);
        hold on
        
        axis([0 120 0 14])
        %legend({'median, multi-hh model','50%CI, multi-hh model','median, single-hh model','50%CI, single-hh model'})
        xlabel('Time (days)')
        ylabel('Prevalence (%)')
        %drawnow
   
    end


end

for j = 1:4
    figure(j)
    subplot(2,3,2)
    ftitle =  fignames{j};
    title(ftitle)
    drawnow
    filetitle = sprintf ( '%s%s', fignames{j}, '.fig');
    savefig(filetitle)
end

