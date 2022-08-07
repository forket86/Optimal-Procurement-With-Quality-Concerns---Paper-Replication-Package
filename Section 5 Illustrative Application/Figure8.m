%% OPWQC (Lopomo Persico Villa): Border LP
close all; clc; clear all;


%% CPLEX world starts here
load('LoblafromDataT100S7.mat');


FontSize=16;
LineWidth=1.5;

f_epa=Costs_pdf/sum(Costs_pdf(:));
% sum (x-mu(x))^2*f
x = min(Costs):Pass:max(Costs);
sigma_f=sqrt(sum([(x-mean(x)).^2].*f_epa));
F_epa=cumsum(f_epa);
figure
x = min(Costs):Pass:max(Costs);
plot(x,log(F_epa),'LineWidth',LineWidth)
xlabel('Supplier Cost $c$','interpreter','latex')
title('$\log \hat{F}$','interpreter','latex');
set(gca,'FontSize',FontSize)

fprintf('\n\nAll done.\n')



