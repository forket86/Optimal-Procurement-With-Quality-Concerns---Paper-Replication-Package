%% OPWQC (Lopomo Persico Villa): Border LP
%% reset + hello
if 1 % reset, initialize paths
    close all; clc; clear all;
    if 1 % Paths:ampl and cplex
        addpath('./BorderLP/');
        amplPath = 'C:\AMPL\';
        if 1 % Ale
            cplexPath = 'C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\bin\x64_win64\';
            desktopFolder = 'C:\Users\forke\OneDrive\Desktop\MatlabWorkOPW\';
        end
        if 0 % Pino
            cplexPath = 'C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\bin\x64_win64\';
            desktopFolder = 'C:\Users\glopomo\Desktop\MatlabWorkOPW\';
        end
    end
end

%% CPLEX world starts here
load('LoblafromDataT100S7.mat');


FontSize=16;
LineWidth=1.5;

cplexPath = 'C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\bin\x64_win64\';
desktopFolder = 'C:\Users\forke\OneDrive\Desktop\MatlabWorkOPW';

D=1;

kappa=2000;
const=1.0775e+06;

xi_grd = 0:0.01:1;
for xi_iter = 1 : length(xi_grd)
    xi = xi_grd(xi_iter); % weight on concentration
    
    TotMassDelay=integral(@(t) pdf(Delay_f,t),min(Delay_ratio),max(Delay_ratio));
    Edelta=integral(@(t) t.*pdf(Delay_f,t),min(Delay_ratio),max(Delay_ratio))/TotMassDelay;
    TotMassOverrun=integral(@(t) pdf(Overrun_f,t),min(Overrun_ratio),max(Overrun_ratio));
    Eomega=integral(@(t) t.*pdf(Overrun_f,t),min(Overrun_ratio),max(Overrun_ratio))/TotMassOverrun;
    
    vHat=const-(1-xi)*kappa*(Edelta+Eomega)-kappa*xi*(deltaSampled+omegaSampled);
    vHatStore(:,xi_iter) = vHat;
    
    for i=1:length(c)
        f(i)=pdf(Costs_f,c(i));
    end
    f=f./sum(f);
    
    F=cumsum(f);
    
    w = nan(1,length(c));
    for i=1:length(c)
        if i==1
            w(i)=vHat(i)-c(i);
        else
            w(i)=vHat(i)-c(i)-(c(i)-c(i-1))*F(i-1)/f(i);
        end
    end
    
    
    % call LP.maxBuyerSurplus
    aaOPWQC_LP_Border
    
    if 1 % find p threshold
        fprintf('\nfrom Cplex: ')
        thresholdCost = c(T);
        thresholdType = T;
        for t = T-1 : -1 : 1
            if Q(t)-Q(t+1)>1e-8
                thresholdCost = c(t);
                thresholdType = t;
            end
        end
        fprintf('\n  thresholdCost = %g, thresholdType = %g (T = %g)\n', ...
            thresholdCost, thresholdType, T)
    end
    if 1 % build Q_theory, compare w/ Q_from_CPLEX
        Q_theory_p = 0;
        for j = 0 : S-1
            Q_theory_p = Q_theory_p ...
                + (1/(j+1))*nchoosek(S-1,j) *F(thresholdType)^j * (1-F(thresholdType))^(S-1-j);
        end
        
        Q_theory = zeros(T,1);
        for t = 1 : thresholdType
            Q_theory(t) = Q_theory_p;
        end
        for t = thresholdType + 1 : T
            for j = 0 : S-1
                Q_theory(t) = Q_theory(t) ...
                    + (1/(j+1))*nchoosek(S-1,j) *f(t)^j * (1-F(t))^(S-1-j);
            end
        end
        Q_theory = D*Q_theory;
        
        fprintf('\nmax(abs(QfromCPLEX - Q_theory)) = %g',max(abs(Q - Q_theory)))
        
        if max(abs(Q - Q_theory)) < 1e-6
            fprintf('\n   Q_fromCPLEX and  Q_theory are the same.')
        else
            warning('Q_fromCPLEX and  Q_theory are NOT the same!')
        end
        
    end
    
    if 1 %call LP.maxGainsFromTrade
        Weight=(vHat-c).*f;
        aaOPWQC_LP_SecondBest
    end
    
    if 1 % find p threshold for Second Best
        fprintf('\nfrom Cplex: ')
        thresholdCostSB = c(T);
        thresholdTypeSB = T;
        for t = T-1 : -1 : 1
            if Q_SB(t)-Q_SB(t+1)>1e-8
                thresholdCostSB = c(t);
                thresholdTypeSB = t;
            end
        end
        fprintf('\n  thresholdCostSB = %g, thresholdTypeSB = %g (T = %g)\n', ...
            thresholdCostSB, thresholdTypeSB, T)
    end
    
    %%
    c_Grid_size=length(c);
    v=vHat;
    for pL_iter=1:c_Grid_size
        
        %% Q Lola: (1-(1-F(p)).^S)./(N*F(p)).*(c<p) + (1-F(c)).^(S-1).*(p<c);
        Q_theory_p = 0;
        for j = 0 : S-1
            Q_theory_p = Q_theory_p ...
                + (1/(j+1))*nchoosek(S-1,j) *F(pL_iter)^j * (1-F(pL_iter))^(S-1-j);
        end
        Q_theoryLOLA = zeros(c_Grid_size,1);
        Q_theoryLOLA(1 : pL_iter) = Q_theory_p;
        c_end=c_Grid_size;
        if min(w)<0 && max(w)>0
            warning('w goes negative. Do you need a reserve price?')
        end
        for t = pL_iter + 1 : c_end
            for j = 0 : S-1
                Q_theoryLOLA(t) = Q_theoryLOLA(t) ...
                    + (1/(j+1))*nchoosek(S-1,j) *f(t)^j * (1-F(t))^(S-1-j);
            end
        end
        
        %% Q FPA
        Q_theoryFPA=zeros(c_Grid_size,1);
        for t =1 : c_end
            for j = 0 : S-1
                Q_theoryFPA(t) = Q_theoryFPA(t) ...
                    + (1/(j+1))*nchoosek(S-1,j) *f(t)^j * (1-F(t))^(S-1-j);
            end
        end
        
        %% Final Output
        BS_FPA_in(pL_iter)=(w.*f)*Q_theoryFPA;
        BS_Lola_in(pL_iter)=(w.*f)*Q_theoryLOLA;
        
        SS_FPA_in(pL_iter)=((v-c).*f)*Q_theoryFPA;
        SS_Lola_in(pL_iter)=((v-c).*f)*Q_theoryLOLA;
        
        Pi_FPA_in(pL_iter)=SS_FPA_in(pL_iter)-BS_FPA_in(pL_iter);
        Pi_Lola_in(pL_iter)=SS_Lola_in(pL_iter)-BS_Lola_in(pL_iter);
        
    end
    
    %------------------------------------------------
    Q_theoryFPA=zeros(T,1);
    for t =1 : T
        for j = 0 : S-1
            Q_theoryFPA(t) = Q_theoryFPA(t) ...
                + (1/(j+1))*nchoosek(S-1,j) *f(t)^j * (1-F(t))^(S-1-j);
        end
    end
    Q_theoryFPA = D*Q_theoryFPA;
    
    BS_FPA(xi_iter)=(w.*f)*Q_theoryFPA;
    BS_BO(xi_iter)=BSopt_LP_IICIIRQM;
    BS_BO_PERC(xi_iter)=100*(BS_BO(xi_iter)-BS_FPA(xi_iter))/BS_FPA(xi_iter);
    
    Pi_FPA(xi_iter)=((vHat-c).*f)*Q_theoryFPA-(w.*f)*Q_theoryFPA;
    Pi_BO(xi_iter)=((vHat-c).*f)*Q-BSopt_LP_IICIIRQM;
    Pi_BO_PERC(xi_iter)=100*(Pi_BO(xi_iter)-Pi_FPA(xi_iter))/Pi_FPA(xi_iter);
    
    SS_FPA(xi_iter)=((vHat-c).*f)*Q_theoryFPA;
    SS_BO(xi_iter)=((vHat-c).*f)*Q;
    SS_BO_PERC(xi_iter)=100*(SS_BO(xi_iter)-SS_FPA(xi_iter))/SS_FPA(xi_iter);
    
end

figure
subplot(3,1,1)
plot(xi_grd,BS_BO_PERC,'linewidth',1.5);
xlabel('$\xi$','FontSize',FontSize,'interpreter','latex')
title(['Buyer Surplus [% improvement over FPA]'], 'FontSize',FontSize,'interpreter','latex');

subplot(3,1,2)
plot(xi_grd,Pi_BO_PERC,'linewidth',1.5);
xlabel('$\xi$','FontSize',FontSize,'interpreter','latex')
title(['Suppliers Profit [% improvement over FPA]'], 'FontSize',FontSize,'interpreter','latex');

subplot(3,1,3)
plot(xi_grd,SS_BO_PERC,'linewidth',1.5);
xlabel('$\xi$','FontSize',FontSize,'interpreter','latex')
title(['Social Surplus [% improvement over FPA]'], 'FontSize',FontSize,'interpreter','latex');

fprintf('\n\nAll done.\n')



