close all
clear all


set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')

ind = [1 2;3 4;5 6;7 8];

fignames = {'Figures/N = 2500, no events','Figures/N = 2500, with events',...
            'Figures/N = 500, no events','Figures/N = 500, with events'};
        
fignames_LHS = {'Figures/LHS_mitigated','Figures/LHS_unmitigated'};        
        
fignames_new = {'Figures/N = 2500, no events, 100% effective','Figures/N = 2500, with events, 100% effective',...
    'Figures/N = 500, no events, 100% effective','Figures/N = 500, with events, 100% effective'};

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
LHSOutput1 = zeros(11,1000,48);
LHSOutput2 = zeros(11,1000,48);

for j = 1:4
    ftitle =  fignames{j};
    ftitle = sprintf ( '%s%s', ftitle,'.fig');
    open(ftitle)
end

for k = 1:6
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_int_new', k,'.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_int_S', k,'_100.mat');
    load(fnamel)
    
    fnamel2 = sprintf ( '%s%i%s', 'Initialisation_S', k,'.mat');
    load(fnamel2,'pmaster')
    
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
        
        % LHS param vs final size and vs outbreak duration
        threshold = -1;
        LHSOutput1(1:9,:,(k-1)*8+index1)=lhsparams1(:,Incidence>threshold);
        LHSOutput1(10,:,(k-1)*8+index1)=Incidence(Incidence>threshold);
        LHSOutput1(11,:,(k-1)*8+index1)=DurationOutbreak(Incidence>threshold);
        LHSOutput1(1:9,:,(k-1)*8+index2)=lhsparams2(:,Incidence2>threshold);
        LHSOutput1(10,:,(k-1)*8+index2)=Incidence2(Incidence2>threshold);
        LHSOutput1(11,:,(k-1)*8+index2)=DurationOutbreak2(Incidence2>threshold);

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

fignames_new2 = {'Figures/N = 2500, no events, 50% effective','Figures/N = 2500, with events, 50% effective',...
    'Figures/N = 500, no events, 50% effective','Figures/N = 500, with events, 50% effective'};

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
    
    fnamel2 = sprintf ( '%s%i%s', 'Initialisation_S', k,'.mat');
    load(fnamel2,'pmaster')
    
    
    for j = 1:4
        
        figure(j+4)
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
        
        threshold = -1;
        % LHS param vs final size and vs outbreak duration
        LHSOutput2(1:9,:,(k-1)*8+index1)=lhsparams1(:,Incidence>threshold);
        LHSOutput2(10,:,(k-1)*8+index1)=Incidence(Incidence>threshold);
        LHSOutput2(11,:,(k-1)*8+index1)=DurationOutbreak(Incidence>threshold);
        LHSOutput2(1:9,:,(k-1)*8+index2)=lhsparams2(:,Incidence2>threshold);
        LHSOutput2(10,:,(k-1)*8+index2)=Incidence2(Incidence2>threshold);
        LHSOutput2(11,:,(k-1)*8+index2)=DurationOutbreak2(Incidence2>threshold);

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

load('Output_files/Outputs_unmitigated.mat','Output')

ReductionMedianDuration100 = 100 - Output1(:,10)./Output(:,10)*100;
ReductionMedianDuration50 = 100 - Output2(:,10)./Output(:,10)*100;
ReductionMedianSize100 = 100 - Output1(:,15)./Output(:,15)*100;
ReductionMedianSize50 = 100 - Output2(:,15)./Output(:,15)*100;

Output1B = [Output1 ReductionMedianDuration100 ReductionMedianSize100];
Output2B = [Output2 ReductionMedianDuration50 ReductionMedianSize50];

A1 = array2table(Output1B,'VariableNames',Rownames);
filename = 'Output_files/Outputs_mitigated_100.xlsx';
writetable(A1,filename)
save('Output_files/Outputs_mitigated_100.mat','Output1B')

A2 = array2table(Output2B,'VariableNames',Rownames);
filename = 'Output_files/Outputs_mitigated_50.xlsx';
writetable(A2,filename)
save('Output_files/Outputs_mitigated_50.mat','Output2B')

%Create LHS figures for mitigated and unmitigated scenarios

th=10;
load('Output_files/LHSOutput.mat','LHSOutput')

ThresholdLHSOutputFSu = squeeze(LHSOutput(10,:,:));
ThresholdLHSOutputODu = squeeze(LHSOutput(11,:,:));
ThresholdLHSOutputFSm100 = squeeze(LHSOutput1(10,:,:));
ThresholdLHSOutputODm100 = squeeze(LHSOutput1(11,:,:));
ThresholdLHSOutputFSm50 = squeeze(LHSOutput2(10,:,:));
ThresholdLHSOutputODm50 = squeeze(LHSOutput2(11,:,:));
ThresholdLHS = LHSOutput(1:9,:,:);
temp = ThresholdLHSOutputFSu;

RFS100 = cell(48,5);
RFS50 = cell(48,5);
ROD100 = cell(48,5);
ROD50 = cell(48,5);
FS = cell(48,5);
OD = cell(48,5);

paramind = [1 8 9 6 7]; %qhat,q,alpha,1/sigma,1/gamma

for k = 1:6
    
    for j = 1:4
        
        index1 = ind(j,1);
        index2 = ind(j,2);
        
        for r = 1:5  

            a = [];
            b = [];
            c = [];
            
            for i = 1:1000
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index1)>th
                    
                    b = [b; [LHSOutput(paramind(r),i,(k-1)*8+index1),...
                        LHSOutput(10,i,(k-1)*8+index1)]];
                    c = [c; [LHSOutput(paramind(r),i,(k-1)*8+index1),...
                        LHSOutput(11,i,(k-1)*8+index1)]];
                
                end
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index1)>ThresholdLHSOutputFSm100(i,(k-1)*8+index1)
                    
                    ReductionFinalSize100 = 100 - ThresholdLHSOutputFSm100(i,(k-1)*8+index1)./ThresholdLHSOutputFSu(i,(k-1)*8+index1)*100;
                    a = [a; [LHSOutput1(paramind(r),i,(k-1)*8+index1),...
                        ReductionFinalSize100]];
                
                end
            end
            
            RFS100{(k-1)*8+index1,r} = a;
            FS{(k-1)*8+index1,r} = b;
            OD{(k-1)*8+index1,r} = c;
            
            a = [];
            b = [];
            c = [];
            
            for i = 1:1000
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index2)>th
                    
                    b = [b; [LHSOutput(paramind(r),i,(k-1)*8+index2),...
                        LHSOutput(10,i,(k-1)*8+index1)]];
                    c = [c; [LHSOutput(paramind(r),i,(k-1)*8+index2),...
                        LHSOutput(11,i,(k-1)*8+index2)]];
                
                end
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index2)>ThresholdLHSOutputFSm100(i,(k-1)*8+index2)
                    
                    ReductionFinalSize100 = 100 - ThresholdLHSOutputFSm100(i,(k-1)*8+index2)./ThresholdLHSOutputFSu(i,(k-1)*8+index2)*100;
                    a = [a; [LHSOutput1(paramind(r),i,(k-1)*8+index2),...
                        ReductionFinalSize100]];

                end

            end
            
            RFS100{(k-1)*8+index2,r} = a;
            FS{(k-1)*8+index2,r} = b;
            OD{(k-1)*8+index2,r} = c;
            
            a = [];
            
            for i = 1:1000
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index1)>ThresholdLHSOutputFSm50(i,(k-1)*8+index1)
                    
                    ReductionFinalSize50 = 100 - ThresholdLHSOutputFSm50(i,(k-1)*8+index1)./ThresholdLHSOutputFSu(i,(k-1)*8+index1)*100;
                    a = [a; [LHSOutput2(paramind(r),i,(k-1)*8+index1),...
                        ReductionFinalSize50]];

                end
                
            end
            
            RFS50{(k-1)*8+index1,r} = a;
            
            a = [];
            
            for i = 1:1000
                
                if ThresholdLHSOutputFSu(i,(k-1)*8+index2)>ThresholdLHSOutputFSm50(i,(k-1)*8+index2)
                    
                    ReductionFinalSize50 = 100 - ThresholdLHSOutputFSm50(i,(k-1)*8+index2)./ThresholdLHSOutputFSu(i,(k-1)*8+index2)*100;
                    a = [a; [LHSOutput2(paramind(r),i,(k-1)*8+index2),...
                        ReductionFinalSize50]];

                end
                
            end
            
            RFS50{(k-1)*8+index2,r} = a;

        end
        
    end
    
end

% Reduction final size 100% intervention
% Combine LHS samples
qhat_fluid = [RFS100{1,1};RFS100{9,1}];
qhat_stable = [RFS100{2,1};RFS100{10,1}];
q_fluid = [RFS100{1,2};RFS100{25,2}];
q_stable = [RFS100{2,2};RFS100{26,2}];

% Plot
figure
subplot(2,4,1)
scatter(qhat_fluid(:,1),qhat_fluid(:,2),'filled')
subplot(2,4,2)
scatter(qhat_stable(:,1),qhat_stable(:,2),'filled')
subplot(2,4,3)
scatter(q_fluid(:,1),q_fluid(:,2),'filled')
subplot(2,4,4)
scatter(q_stable(:,1),q_stable(:,2),'filled')

% Reduction final size 50% intervention
% Combine LHS samples
qhat_fluid = [RFS50{1,1};RFS50{9,1}];
qhat_stable = [RFS50{2,1};RFS50{10,1}];
q_fluid = [RFS50{1,2};RFS50{25,2}];
q_stable = [RFS50{2,2};RFS50{26,2}];

% Plot
subplot(2,4,5)
scatter(qhat_fluid(:,1),qhat_fluid(:,2),'filled')
subplot(2,4,6)
scatter(qhat_stable(:,1),qhat_stable(:,2),'filled')
subplot(2,4,7)
scatter(q_fluid(:,1),q_fluid(:,2),'filled')
subplot(2,4,8)
scatter(q_stable(:,1),q_stable(:,2),'filled')

% Link axes across subplots
ax1=[];
ax2=[];
ax3=[];
for i=1:8
    ax1 =[ax1, subplot(2, 4, i)];
    if i == 1 || i == 2 || i == 5 || i == 6
        ax2 =[ax2, subplot(2, 4, i)];
    else
        ax3 =[ax3, subplot(2, 4, i)];
    end
    if i == 5 || i == 6
        %xlabel('Relative contact intensity in houses')
    elseif i == 7 || i == 8
        %xlabel('Transmissibility')
    end
end
linkaxes(ax1, 'y');
linkaxes(ax2, 'x');
linkaxes(ax3, 'x');

% Save figure
filetitle = sprintf ( '%s%s', fignames_LHS{1}, '.fig');
savefig(filetitle)

% Final size, unmitigated 
% Combine LHS samples
qhat_fluid = [FS{1,1};FS{9,1}];
qhat_stable = [FS{2,1};FS{10,1}];
q_fluid = [FS{1,2};FS{25,2}];
q_stable = [FS{2,2};FS{26,2}];

% Plot
figure
subplot(2,4,1)
scatter(qhat_fluid(:,1),qhat_fluid(:,2),'filled')
subplot(2,4,2)
scatter(qhat_stable(:,1),qhat_stable(:,2),'filled')
subplot(2,4,3)
scatter(q_fluid(:,1),q_fluid(:,2),'filled')
subplot(2,4,4)
scatter(q_stable(:,1),q_stable(:,2),'filled')

% Outbreak duration, unmitigated 
% Combine LHS samples
qhat_fluid = [OD{1,1};OD{9,1}];
qhat_stable = [OD{2,1};OD{10,1}];
q_fluid = [OD{1,2};OD{25,2}];
q_stable = [OD{2,2};OD{26,2}];

% Plot
subplot(2,4,5)
scatter(qhat_fluid(:,1),qhat_fluid(:,2),'filled')
subplot(2,4,6)
scatter(qhat_stable(:,1),qhat_stable(:,2),'filled')
subplot(2,4,7)
scatter(q_fluid(:,1),q_fluid(:,2),'filled')
subplot(2,4,8)
scatter(q_stable(:,1),q_stable(:,2),'filled')

% Link axes across subplots
ax =[];
ax1=[];
ax2=[];
ax3=[];
for i=1:8
    if i<5
        ax1 =[ax1, subplot(2, 4, i)];
    else
        ax =[ax, subplot(2, 4, i)];
    end
    if i == 1 || i == 2 || i == 5 || i == 6
        ax2 =[ax2, subplot(2, 4, i)];
    else
        ax3 =[ax3, subplot(2, 4, i)];
    end
    if i == 5 || i == 6
        %xlabel('Relative contact intensity in houses')
    elseif i == 7 || i == 8
        %xlabel('Transmissibility')
    end
end
linkaxes(ax, 'y');
linkaxes(ax1, 'y');
linkaxes(ax2, 'x');
linkaxes(ax3, 'x');

% Save figure
filetitle = sprintf ( '%s%s', fignames_LHS{2}, '.fig');
savefig(filetitle)

