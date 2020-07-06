close all
clear all


set(0,'DefaultTextFontName','Arial')
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultAxesFontName','Arial')


ind0 = [1 2 3;
        5 6 7];

fignames = {'N = 2500, contacts', 'N = 500, contacts'};

threshold = 10;

for k = 1:6
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_new', k,'c.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_S', k,'.mat');
    load(fnamel)
    
    j = 1;
        
    index1 = ind0(j,1);
    index2 = ind0(j,2);
    index3 = ind0(j,3);

    II=I;

    % check medians
    mct = SCC(index1,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=I(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT=sqrt(pooledsdhhT);
    pooledsdhhU=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU=sqrt(pooledsdhhU);
    pooledsdcomT=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT=sqrt(pooledsdcomT);
    pooledsdcomU=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU=sqrt(pooledsdcomU);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%
    index1 = index2;

    % check medians
    mct = SCC(index1,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=II(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT2=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT2=sqrt(pooledsdhhT2);
    pooledsdhhU2=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU2=sqrt(pooledsdhhU2);
    pooledsdcomT2=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT2=sqrt(pooledsdcomT2);
    pooledsdcomU2=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU2=sqrt(pooledsdcomU2);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT2 = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU2 = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT2 = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU2 = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%
    index1 = index3;

    % check medians
    mct = SCC(index3,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=II(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT3=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT3=sqrt(pooledsdhhT3);
    pooledsdhhU3=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU3=sqrt(pooledsdhhU3);
    pooledsdcomT3=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT3=sqrt(pooledsdcomT3);
    pooledsdcomU3=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU3=sqrt(pooledsdcomU3);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT3 = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU3 = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT3 = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU3 = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%%

    x = 1:12;
    y = [MoMhhT MoMhhT3 MoMhhT2 MoMhhU MoMhhU3 MoMhhU2...
        MoMcomT MoMcomT3 MoMcomT2 MoMcomU MoMcomU3 MoMcomU2];
    errp = [pooledsdhhT pooledsdhhT3 pooledsdhhT2 pooledsdhhU pooledsdhhU3 pooledsdhhU2...
        pooledsdcomT pooledsdcomT3 pooledsdcomT2 pooledsdcomU pooledsdcomU3 pooledsdcomU2];

    checkerrn = y-errp;
    a = find(checkerrn<0);
    errn = errp;
    errn(a) = y(a);

    figure(j)
    subplot(2,3,k)
    ind=[1 4 7 10];
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','r')
    hold on
    ind=[1 4 7 10]+1;
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','b')
    hold on
    ind=[1 4 7 10]+2;
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','k')

    ylabel('Number of contacts')
    axis([0 13 0 70])
    drawnow

end

for k = 1:6
    
    %fnamel = sprintf ( '%s%i%s', '../batch_events_new', k,'c.mat');
    fnamel = sprintf ( '%s%i%s', 'batch_S', k,'.mat');
    load(fnamel)
    
    j = 2;
        
    index1 = ind0(j,1);
    index2 = ind0(j,2);
    index3 = ind0(j,3);

    II=I;

    % check medians
    mct = SCC(index1,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=I(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT=sqrt(pooledsdhhT);
    pooledsdhhU=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU=sqrt(pooledsdhhU);
    pooledsdcomT=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT=sqrt(pooledsdcomT);
    pooledsdcomU=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU=sqrt(pooledsdcomU);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%
    index1 = index2;

    % check medians
    mct = SCC(index1,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=II(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT2=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT2=sqrt(pooledsdhhT2);
    pooledsdhhU2=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU2=sqrt(pooledsdhhU2);
    pooledsdcomT2=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT2=sqrt(pooledsdcomT2);
    pooledsdcomU2=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU2=sqrt(pooledsdcomU2);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT2 = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU2 = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT2 = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU2 = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%
    index1 = index3;

    % check medians
    mct = SCC(index3,:,1,3);
    mct=mct(mct>0);

    aSCHH=squeeze(SCHH(index1,mct>0,:,:));
    aSCC=squeeze(SCC(index1,mct>0,:,:));
    I=II(index1,mct>0);

    % Estimate sample standard deviations froms 95% CIs:
    sdhhT=squeeze(aSCHH(:,1,5)-aSCHH(:,1,1))/3.92;
    sdhhU=squeeze(aSCHH(:,2,5)-aSCHH(:,2,1))/3.92;
    sdcomT=squeeze(aSCC(:,1,5)-aSCC(:,1,1))/3.92;
    sdcomU=squeeze(aSCC(:,2,5)-aSCC(:,2,1))/3.92;

    sdhhT = sdhhT(I>threshold);
    sdhhU = sdhhU(I>threshold);
    sdcomT = sdcomT(I>threshold);
    sdcomU = sdcomU(I>threshold);

    I0 = I(I>threshold);
    I0hhT=I0;
    I0hhU=I0;
    I0comT=I0;
    I0comU=I0;

    % Calculate pooled standard deviations
    pooledsdhhT3=sum((I0hhT-1)'.*sdhhT.^2)./sum(I0hhT-1);
    pooledsdhhT3=sqrt(pooledsdhhT3);
    pooledsdhhU3=sum((I0hhU-1)'.*sdhhU.^2)./sum(I0hhU-1);
    pooledsdhhU3=sqrt(pooledsdhhU3);
    pooledsdcomT3=sum((I0comT-1)'.*sdcomT.^2)./sum(I0comT-1);
    pooledsdcomT3=sqrt(pooledsdcomT3);
    pooledsdcomU3=sum((I0comU-1)'.*sdcomU.^2)./sum(I0comU-1);
    pooledsdcomU3=sqrt(pooledsdcomU3);

    % Calculate mean of means
    a = aSCHH(:,1,6);
    MoMhhT3 = mean(a(I>threshold),1);
    a = aSCHH(:,2,6);
    MoMhhU3 = mean(a(I>threshold),1);
    a = aSCC(:,1,6);
    MoMcomT3 = mean(a(I>threshold),1);
    a = aSCC(:,2,6);
    MoMcomU3 = mean(a(I>threshold),1);

    %%%%%%%%%%%%%%%%%

    x = 1:12;
    y = [MoMhhT MoMhhT3 MoMhhT2 MoMhhU MoMhhU3 MoMhhU2...
        MoMcomT MoMcomT3 MoMcomT2 MoMcomU MoMcomU3 MoMcomU2];
    errp = [pooledsdhhT pooledsdhhT3 pooledsdhhT2 pooledsdhhU pooledsdhhU3 pooledsdhhU2...
        pooledsdcomT pooledsdcomT3 pooledsdcomT2 pooledsdcomU pooledsdcomU3 pooledsdcomU2];

    checkerrn = y-errp;
    a = find(checkerrn<0);
    errn = errp;
    errn(a) = y(a);

    figure(j)
    subplot(2,3,k)
    ind=[1 4 7 10];
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','r')
    hold on
    ind=[1 4 7 10]+1;
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','b')
    hold on
    ind=[1 4 7 10]+2;
    errorbar(x(ind),y(ind),errn(ind),errp(ind),'o','LineWidth',2,'MarkerSize',10,'CapSize',18,'Color','k')

    ylabel('Number of contacts')
    axis([0 13 0 70])
    drawnow

end

for j = 1:2
    figure(j)
    subplot(2,3,2)
    ftitle =  fignames{j};
    title(ftitle)
    drawnow
    filetitle = sprintf ( '%s%s', fignames{j}, '.fig');
    savefig(filetitle)
end

