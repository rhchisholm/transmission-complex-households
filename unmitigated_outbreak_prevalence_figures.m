close all
clear all


set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')

ind = [1 2;3 4;5 6;7 8];



fignames = {'Figures/N = 2500, no events','Figures/N = 2500, with events','Figures/N = 500, no events','Figures/N = 500, with events'};

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

Output = zeros(48,17);
LHSOutput = zeros(11,1000,48);

for k = 1:6
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_new', k,'.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_S', k,'.mat');
    load(fnamel)
    
    fnamel2 = sprintf ( '%s%i%s', 'Initialisation_S', k,'.mat');
    load(fnamel2,'pmaster')
    
    if k ==  1 || k == 2 || k == 4
        S = S1;
    else
        S = S2;
    end
        
    for j = 1:4
        
        
        index1 = ind(j,1);
        index2 = ind(j,2);
        
        Prev = P{index1};
        Incidence = I(index1,:);
        DurationOutbreak = DO(index1,:);
        lhsparams1=zeros(9,1000);
        for l = 1:1000
            params1 = pmaster{index1,l};      
            lhsparams1(:,l) = params1.lhsinput;
        end
        
        Prev2 = P{index2};
        Incidence2 = I(index2,:);
        DurationOutbreak2 = DO(index2,:);
        lhsparams2=zeros(9,1000);
        for l = 1:1000
            params2 = pmaster{index2,l};      
            lhsparams2(:,l) = params2.lhsinput;
        end
        
        threshold=10;
        QDO = quantile(DurationOutbreak(Incidence>threshold),[0.025 0.25 0.50 0.75 0.975]);
        QTS = quantile(Incidence(Incidence>threshold),[0.025 0.25 0.50 0.75 0.975]);
        QDO2 = quantile(DurationOutbreak2(Incidence2>threshold),[0.025 0.25 0.50 0.75 0.975]);
        QTS2 = quantile(Incidence2(Incidence2>threshold),[0.025 0.25 0.50 0.75 0.975]);
        OTO = length(DurationOutbreak(Incidence>threshold));
        OTO2 = length(DurationOutbreak2(Incidence2>threshold));
        
        Rows = (k-1)*8 + ((2*j-1):2*j);
        
        Scen = [k;k];
        SPs = S(((2*j-1):2*j),:);
        FS = [OTO; OTO2];
        All = [QDO QTS; QDO2 QTS2];
        
        Output(Rows,:) = [Scen SPs FS FS/1000*100 All];

        PP = zeros(100,1000);
        PP2 = PP;
        count= 1;
        for i =1:1000
            if Incidence(i)>threshold
                PP(1:length(Prev{i}),count) = Prev{i};
                count=count+1;
            end

        end

        count2= 1;
        for i =1:1000
            if Incidence2(i)>threshold
                PP2(1:length(Prev2{i}),count2) = Prev2{i};
                count2=count2+1;
            end

        end
        
        threshold = -1;
        paramind = [1 8 9 6 7]; %qhat,q,alpha,1/sigma,1/gamma
        % Figures: LHS param vs final size
        for r = 1:5           
            figure(99+r)
            subplot(6,8,(k-1)*8+index1)
            plot(lhsparams1(paramind(r),Incidence>threshold),Incidence(Incidence>threshold),'.b')
            subplot(6,8,(k-1)*8+index2)
            plot(lhsparams2(paramind(r),Incidence2>threshold),Incidence2(Incidence2>threshold),'.b')
            drawnow
        end
        % Figures: LHS param vs duration outbreak
        for r = 1:5           
            figure(199+r)
            subplot(6,8,(k-1)*8+index1)
            plot(lhsparams1(paramind(r),Incidence>threshold),DurationOutbreak(Incidence>threshold),'.b')
            subplot(6,8,(k-1)*8+index2)
            plot(lhsparams2(paramind(r),Incidence2>threshold),DurationOutbreak2(Incidence2>threshold),'.b')
            drawnow
        end
        LHSOutput(1:9,:,(k-1)*8+index1)=lhsparams1(:,Incidence>threshold);
        LHSOutput(10,:,(k-1)*8+index1)=Incidence(Incidence>threshold);
        LHSOutput(11,:,(k-1)*8+index1)=DurationOutbreak(Incidence>threshold);
        LHSOutput(1:9,:,(k-1)*8+index2)=lhsparams2(:,Incidence2>threshold);
        LHSOutput(10,:,(k-1)*8+index2)=Incidence2(Incidence2>threshold);
        LHSOutput(11,:,(k-1)*8+index2)=DurationOutbreak2(Incidence2>threshold);
        
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
        
        figure(j)
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
        drawnow
   
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

LHSfignames = {'qhat','q','alpha','sigma_inv','gamma_inv'};

for j=0:4
    figure(100+j)
    ax1=[];
    ax2=[];
    for i=1:48
        z=floor((i-1)/4);
        if mod(z,2)==0
            ax1 =[ax1, subplot(6, 8, i)];
        else
            ax2 =[ax2, subplot(6, 8, i)];
        end
    end
    linkaxes(ax1, 'y');
    linkaxes(ax2, 'y');
    filetitle = sprintf ( '%s%s%s', 'Figures/LHS_',LHSfignames{j+1}, '.vs_Final_Size.fig');
    savefig(filetitle)
end

for j=0:4
    figure(200+j)
    ax1=[];
    ax2=[];
    for i=1:48
        z=floor((i-1)/4);
        if mod(z,2)==0
            ax1 =[ax1, subplot(6, 8, i)];
        else
            ax2 =[ax2, subplot(6, 8, i)];
        end
    end
    linkaxes(ax1, 'y');
    linkaxes(ax2, 'y');
    filetitle = sprintf ( '%s%s%s', 'Figures/LHS_',LHSfignames{j+1}, '.vs_Duration_Outbreak.fig');
    savefig(filetitle)
end

Rownames = {'ScenarioSet','N','H','Fluid','Events',...
    'NumOutbreaks','PercentOutbreaks',...
    'DurOB2p5PC','DurOB25PC','DurOB50PC','DurOB75PC','DurOB97p5PC',...
    'SizeOB2p5PC','SizeOB25PC','SizeOB50PC','SizeOB75PC','SizeOB97p5PC'};

A = array2table(Output,'VariableNames',Rownames);
filename = 'Output_files/Outputs_unmitigated.xlsx';
writetable(A,filename)

save('Output_files/Outputs_unmitigated.mat','Output')
save('Output_files/LHSOutput.mat','LHSOutput')
