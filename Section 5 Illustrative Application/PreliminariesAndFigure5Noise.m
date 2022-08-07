%% OPWQC (Lopomo Persico Villa): Border LP
%% reset + hello

close all; clc; clear all;


TurinRenegotiations=readtable('TurinRenegotiationsNoise.csv');
Costs_Sample=readtable('Costs_Sample_Noise.csv');

Costs=table2array(Costs_Sample(:,2));

Delay=table2array(TurinRenegotiations(:,2));
for iter=1:length(Delay)
    if strcmp(Delay(iter),'NA')==0
        Delay_ratio(iter)=Delay(iter);
    end
end

Overrun=table2array(TurinRenegotiations(:,3));
for iter=1:length(Delay)
    if strcmp(Overrun(iter),'NA')==0
        Overrun_ratio(iter)=Overrun(iter);
    end
end

Pass=0.5;

Costs_f = fitdist(Costs,'Kernel','Kernel','epanechnikov','BandWidth',11000);
TotMass=integral(@(t) pdf(Costs_f,t),min(Costs),max(Costs));
Costs_F=@(x) integral(@(t) pdf(Costs_f,t),min(Costs),x)/TotMass;
x = min(Costs):Pass:max(Costs);
Costs_pdf = pdf(Costs_f,x);

Delay_f = fitdist(Delay_ratio','Kernel','Kernel','epanechnikov','BandWidth',18.15);
TotMass=integral(@(t) pdf(Delay_f,t),min(Delay_ratio),max(Delay_ratio));
Delay_F=@(x) integral(@(t) pdf(Delay_f,t),min(Delay_ratio),x)/TotMass;
x = min(Delay_ratio):Pass:max(Delay_ratio);
Delay_pdf = pdf(Delay_f,x);

Overrun_f = fitdist(Overrun_ratio','Kernel','Kernel','epanechnikov','BandWidth',3.0071);
TotMass=integral(@(t) pdf(Overrun_f,t),min(Overrun_ratio),max(Overrun_ratio));
Overrun_F=@(x) integral(@(t) pdf(Overrun_f,t),min(Overrun_ratio),x)/TotMass;
x = min(Overrun_ratio):Pass:max(Overrun_ratio);
Overrun_pdf = pdf(Overrun_f,x);

S=7;

delta0=(min(Delay_ratio) + max(Delay_ratio))/2;
delta=@(c) fzero(@(x) Delay_F(x)-(1-Costs_F(c)).^S,delta0);

omega0=(min(Overrun_ratio)+max(Overrun_ratio))/2;
omega=@(c) fzero(@(x) Overrun_F(x)-(1-Costs_F(c)).^S,omega0);


T=100;

c=linspace(min(Costs),max(Costs),T);
deltaSampled=arrayfun(delta,c);
omegaSampled=arrayfun(omega,c);

%% Figure 5 Plot
FontSize=16;
LineWidth=1.5;

figure
subplot(1,3,1)
x = min(Costs):Pass:max(Costs);
plot(x,Costs_pdf/sum(Costs_pdf(:)),'LineWidth',LineWidth)
xlabel('Supplier Cost $c$','interpreter','latex')
title('$\hat{f}$','interpreter','latex');
set(gca,'FontSize',FontSize)
subplot(1,3,2)
x = min(Delay_ratio):Pass:max(Delay_ratio);
plot(x,Delay_pdf/sum(Delay_pdf(:)),'LineWidth',LineWidth)
xlabel('Delay Ratio $D$','interpreter','latex')
title('$g_D$','interpreter','latex');
set(gca,'FontSize',FontSize)
subplot(1,3,3)
x = min(Overrun_ratio):Pass:max(Overrun_ratio);
plot(x,Overrun_pdf/sum(Overrun_pdf(:)),'LineWidth',LineWidth)
xlabel('Overrun Ratio $O$','interpreter','latex')
title('$g_O$','interpreter','latex');
set(gca,'FontSize',FontSize)

fprintf('\n\nAll done.\n')



