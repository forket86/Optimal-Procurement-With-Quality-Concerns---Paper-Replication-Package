%% IOQC.Border.2021.02.12
if 1 % reset & folders
    close all; clc; clear all;
    [pathstr, thisFileName, ext] = fileparts(mfilename('fullpath'));
    fprintf('This script  ''%s'' ',thisFileName)
    fprintf(' (today: %s)\n',datetime)
    beep off
end
if 1 % SANDBOX
    fprintf('\nSandbox ...\n')


    fprintf('\n end sandbox ...\n')
    return
end

%% select user  <==
user = 'Pino'; %user = 'Chenxi';
LP_name = 'OPWQC.Border';
if 1 % paths
    if strcmp(user, 'Pino')
        baseScriptFolder = pwd;
        MAC_folder = 'C:\Users\Student\Dropbox\_pino_shared_folders\__Pino - Chenxi\aaaaMAC';
        amplPath = 'C:\Users\Student\Dropbox\All_My_Files\5_Software\AMPL\zInstallationFiles\ampl.mswin32.20110531\';
        cplexPath = 'C:\Program Files\IBM\ILOG\CPLEX_Studio201\cplex\bin\x64_win64\';
        outputFolder = 'C:\Users\Student\Dropbox\_pino_shared_folders\__Pino - Chenxi\aaaaMAC_output';
        userSpecificVariables = { ...
            user, ...             % string
            amplPath, ...         % string
            cplexPath, ...        % string
            outputFolder...       % string
            };
        addpath(MAC_folder,outputFolder);
    end
    if strcmp(user, 'Chenxi') % Chenxi
        if 1 % Chenxi's PC
            % MAC_folder = 'C:\Users\cxxu9\Dropbox\Pino - Chenxi\aaaaMAC';
            baseScriptFolder = pwd;
            addpath('C:\Users\cxxu9\Dropbox\Matlab Functions\aaaaMAC')
            amplPath = 'C:\AMPL\';
            cplexPath = 'C:\Program Files\IBM\ILOG\CPLEX_Studio1210\cplex\bin\x64_win64\';
            outputFolder = 'C:\Users\cxxu9\Dropbox\Matlab Output\';
            userSpecificVariables = { ...
                user, ...             % string
                amplPath, ...         % string
                cplexPath, ...        % string
                outputFolder...       % string
                };
        end
        if 0 % Chenxi's MAC
            addpath(genpath('/Users/chenxixu/Dropbox/Matlab Functions'))
            amplPath = '/Users/chenxixu/Dropbox/AMPL';
            cplexPath = '/Applications/CPLEX_Studio1210/cplex/bin/x86-64_osx';
            outputFolder = '/Users/chenxixu/Dropbox/Matlab Output';
        end
    end
end

if 1 % primitive parameters
    if 1 % symbolic parameters (and variables)
        syms c_L c_H v_0 xi beta N
        syms c p y
    end
    if 1 % numeric primitive parameters
        c_L = 1; c_H = 5; v_0 = 6; beta = 1; xi = 12; N = 2; % v_0 = 12
    end

    
end
if 1 % f(c) and F(c)
    f = 1/(c_H - c_L);
    F = (c-c_L)/(c_H - c_L);
    F_minOthers = 1 -(1-F)^(N-1);
    f_minOthers = diff(F_minOthers,c);
end

if 1 % v(c)
    v = v_0 + xi *(-1/3 + (c-c_L)/(c_H - c_L) - .5*(c-c_L)^2/(c_H - c_L)^2);
    v_at_c_L = simplify(subs(v,c,c_L),10);
    v_at_c_H = simplify(subs(v,c, c_H),10);
end
if 1 % w(c)
    w = simplify(v - c - beta*(c-c_L),10);
    w = collect(w,c);
    w_at_c_L = simplify(subs(w,c,c_L),10);
end

if 1 % p_L
    w_c = diff(w,c);
    LHS4_p_L = simplify(int(w_c * (c-c_L)/(c_H-c_L), c, c_L, p),10);
    piece1 = collect(LHS4_p_L/(p-c_L)^2,p);
    [LHS1,~] = numden(piece1);
    p_L = simplify(solve(LHS1 == 0, p),10);
end
if 1 % p_H
    p_H_TwoRoots = simplify(solve(w == 0, c),10);
    p_H = double(p_H_TwoRoots(2));
    if p_H > c_H
        p_H = c_H;
    end
    %latex(sol)
end
if 1 % F_p_L
    F_at_p_L = double(simplify(subs(F,c,p_L),10));
    F_at_p_H = double(simplify(subs(F,c,p_H),10));
end
if 1 % barQ
    barQ = (1-(1 - F_at_p_L)^N)/(N*F_at_p_L);
end

if 1 % beta
    integr_at_c = int(c*f_minOthers);
    integr_at_p_H = double(subs(integr_at_c,c,p_H));
    defIntegr =  simplifyFraction(integr_at_p_H - integr_at_c);
    F_minOthers_at_p_H = subs(F_minOthers, c, p_H);

    beta = simplifyFraction((p_H *(1-F_minOthers_at_p_H) + defIntegr)/(1-F_minOthers));
    expand(beta)
    beta_MyForm = c^2/(2*(c - 5)) - 12.3440/(c - 5);

    simplify(beta_MyForm-beta)
    beta_at_p_L = double(subs(beta, c, p_L));
end

if 1 % b_L
    b_L = double(((barQ - (1-F_at_p_L)^(N-1))* p_L + (1-F_at_p_L)^(N-1)*beta_at_p_L)/barQ);
end

if 1

    figure
    c_L = double(c_L);
    p_L = double(p_L);
    p_H = double(p_H);
    c_H = double(c_H);

    hold on

    fplot(beta,[p_L, p_H],'r','LineWidth',2); legItem1 = sprintf('$\\beta(c_i;p_H)$');
    plot([c_L, p_L], [b_L, b_L],'r','LineWidth',2); %legItem2 = sprintf('$b_L$');

    plot([p_L, p_L], [c_L, p_L], 'k:');  plot([c_L, p_L], [p_L, p_L], 'k:');
    plot([p_H, p_H], [c_L, p_H], 'k:');  plot([c_L, p_H], [p_H, p_H], 'k:');

    plot([c_L, c_H], [c_L, c_H], 'k:')

    xlim([double(c_L), double(c_H)])
    ylim([double(c_L), double(c_H)])
    xlabel('$c_i$')


    titleStr = sprintf('Equilibrium bidding function in the  first price LoLA');
    title(titleStr)

    textContent = ' $\begin{array}{l}';
    textContent = [textContent 'N = '  num2str(N) ' \\[5pt]' ];
    textContent = [textContent 'f(c_1) = \frac{1}{' num2str(c_H-c_L) '} \\[5pt]' ];
    textContent = [textContent 'c_H = ' num2str(c_H) ' \\[5pt]'];
    textContent = [textContent 'p_H = ' num2str(round(p_H,1)) ' \\[5pt]' ];
    textContent = [textContent 'p_L = ' num2str(p_L) ' \\[5pt]' ];
    textContent = [textContent 'c_L = ' num2str(c_L) ' \\[5pt]' ];
    textContent = [textContent '\end{array}$' ];

    text(.15*c_L + .85*c_H, .6*c_L + .4*c_H, textContent)

    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')

    %saveas(gcf,'MyFigure.pdf')

end

if 1
    % bL = (barQ - (1-F_at_p_L)^(N-1))/barQ * p_L + ;
end
return
if 1 % w_sampled
    w_fn = matlabFunction(w)
    T = 20;
    cGrid = linspace(c_L,c_H,T);
    w_sampled = NaN(T,1);
    for t = 1 : T
        w_sampled(t) = w_fn(cGrid(t));
    end

end
if 1 % figure

    figure('units','normalized','outerposition',[.1 .1 .9 .9])
    hold on

    w_at_p_L = subs(w, c, p_L);

    fplot(v, [c_L  c_H])
    legItem1 = sprintf('$v(c;\\xi) = %s$', latex(v));

    fplot(w, [c_L  c_H])
    legItem2 = sprintf('$w(c;\\xi) = %s$', latex(w));

    plot([p_L  p_L], [0 w_at_p_L], 'k')
    legItem3 = sprintf('$p_L^* = %g$', p_L);

    plot([p_H  p_H], [-.1 .1], 'k')
    legItem4 = sprintf('$p_H^* = %g$', p_H);

    plot([c_L p_L], [w_at_p_L w_at_p_L], 'k')
    plot([c_L  c_H], [0 0], 'k')

    stem(cGrid,w_sampled)

    legend(legItem1, legItem2, legItem3, legItem4, 'Location', 'Best')

    titleText = sprintf('$\\left[c_L, c_H, v_0, \\xi, \\beta\\right] = \\left[%g, %g, %g, %g, %g\\right]$ \\quad',...
        c_L,  c_H,  v_0, xi, beta);

    titleText = [titleText ' $F$ is uniform, $v$ and $w$ quadratic'];

    title(titleText)

    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')

end

return
% if  % 5. create PDf report
%     if 1 % set filename
%         shellFileName = [shellFileNameTopic '-' problemName];
%         contentFileName = [shellFileName '.content.tex'];
%
%         if exist([shellFileName '.pdf'], 'file')
%             delete([shellFileName '.pdf'])
%         end
%         if exist(contentFileName, 'file')
%             delete(contentFileName)
%         end
%     end
%     if 1 % 5.1 write contentFile (diary)
%         diary(contentFileName)
%         fprintf('\\textbf{Example}' )
%         fprintf('\n$$')
%         fprintf('\n\\setlength{\\tabcolsep}{15pt}')
%         fprintf('\n\\renewcommand{\\arraystretch}{2}')
%         fprintf('\n\\begin{tabular}{r||c|c|c||}')
%         fprintf('\n\\hline \\hline')
%         fprintf('\ntype & probability & seller''s cost &  buyer''s value \\\\ \\hline \\hline')
%         fprintf('\n 2   & %g  & %g    & %g \\\\ \\hline',lambda_num, c2_num, v2_num)
%         fprintf('\n 1   & %g  & %g    & %g \\\\ \\hline',1-lambda_num, c1_num, v1_num)
%         fprintf('\n\\end{tabular}')
%         fprintf('\n$$')
%         fprintf('\n\n\\vspace*{10pt}')
%
%         fprintf('\n\\begin{itemize}[topsep=0pt,itemsep=0pt]')
%         fprintf('\n\\item if $p = %g$, ', c1_num)
%         fprintf('\n then $U_B(%g) = %g \\cdot \\left(%g - %g \\right) = %g$', ...
%             c1_num, lambda_num, v1_num, c1_num, U_B_L_num)
%         fprintf('\n\\item if $p = %g$, ', c2_num)
%         fprintf('\n then $U_B(%g) = %g \\cdot %g + %g \\cdot %g - %g = %g$', ...
%             c2_num, lambda_num, v1_num, 1-lambda_num, v2_num, c2_num, U_B_H_num)
%         fprintf('\n\\end{itemize}')
%         if U_B_L_num > U_B_H_num
%             fprintf('\n\n\\vspace*{10pt}')
%             fprintf('\nIn this case, the optimal offer for the buyer is $p = %g$', c1_num)
%         elseif U_B_L_num < U_B_H_num
%             fprintf('\n\n\\vspace*{10pt}')
%             fprintf('\nIn this case, the optimal offer for the buyer is $p = %g$', c2_num)
%         end
%
%         diary off
%     end
%     if 1 % 5.2 listAllContentFilenames
%         contentFileNames= {...
%             '_Akerlof_Theory.tex';
%             '_MMPD-Theory.solutionAlgorithm.tex';
%             contentFileName};
%     end
%     if 1 % 5.3 call fn createPDF3()
%         fn_createPDF3(shellFileName,contentFileNames)
%     end
% end
% winopen([shellFileName '.tex'])

if 1 % goodbye
    fprintf('\n\nAll done.\n')
    return
end




%%
fprintf('\n\nAll done.\n')
winopen(outputSubfolder)
cd(baseScriptFolder)
return
%% Extra code
if 0
    if 1 % find p threshold
        fprintf('\nfrom Cplex: ')
        thresholdCost = cGrid(T_num);
        thresholdType = T_num;
        for t = T_num-1 : -1 : 1
            if Q(t) > Q(t+1)
                thresholdCost = cGrid(t);
                thresholdType = t;
            end
        end
        fprintf(' thresholdCost = %g, thresholdType = %g (T = %g)\n', ...
            thresholdCost, thresholdType, T_num)
    end
    if 1 % build Q_theory
        Q_theory_p = 0;
        for j = 0 : N-1
            Q_theory_p = Q_theory_p ...
                + (1/(j+1))*nchoosek(N-1,j) *F_num(thresholdType)^j * (1-F_num(thresholdType))^(N-1-j);
        end

        Q_theory = zeros(T_num,1);
        for t = 1 : thresholdType
            Q_theory(t) = Q_theory_p;
        end
        for t = thresholdType + 1 : T_num
            for j = 0 : N-1
                Q_theory(t) = Q_theory(t) ...
                    + (1/(j+1))*nchoosek(N-1,j) *f_num(t)^j * (1-F_num(t))^(N-1-j);
            end
        end
        Q_theory = D_num*Q_theory;
    end
    fprintf('max(abs(QfromCPLEX - Q_theory)) = %g',max(abs(Q - Q_theory)))

    if 1 % count positive dual variables and slacks
        fprintf('\n\nfrom CPLEX: ');
        tol=1e-10;

        numOfBorderConstrsWithPositiveSlacks = sum(abs(BorderDemandConstraintSlacks)>tol);
        numOfPositiveBetas = sum(abs(BorderDemandConstraintDuals)>tol);
        %fprintf('\n   num Of Positive BorderDemandSlacks = %g',numOfBorderConstrsWithPositiveSlacks);
        fprintf('\n   num Of Positive Betas = %g',numOfPositiveBetas);

        numOfQmonConstrsWithPositiveSlacks = sum(abs(QMonSlacks)>tol);
        numOfPositiveMus = sum(abs(QMonDuals)>tol) + sum(abs(QNonNegTDuals)>tol);
        %fprintf('\n   num Of Positive QmonSlacks = %g',numOfQmonConstrsWithPositiveSlacks);
        fprintf('\n   num Of Positive Mus = %g',numOfPositiveMus);

        numOfQNonnegConstrsWithPositiveSlacks = sum(abs(QNonNegTSlacks)>tol);
        numOfPositiveNus = sum(abs(QNonNegTDuals)>tol);
        %fprintf('\n   num Of Positive QnonNegSlacks = %g',numOfQNonnegConstrsWithPositiveSlacks);
        fprintf('\n   num Of Positive Nus = %g',numOfPositiveNus);

        totalcountSlacks = numOfBorderConstrsWithPositiveSlacks + numOfQmonConstrsWithPositiveSlacks + numOfQNonnegConstrsWithPositiveSlacks;
        totalcountDuals = numOfPositiveBetas + numOfPositiveMus + numOfPositiveNus;

        %fprintf('\n   num Of Slack Constraints = %g', totalcountSlacks);
        fprintf('\n   num Of positive Dual Variables = %g', totalcountDuals);
    end
    if 1 % 2x2 plot [Q, w; slacks, dual vars]
        QMonSlacksComplete = [QMonSlacks; QNonNegTSlacks];
        QMonDualsComplete = [QMonDuals; QNonNegTDuals];

        h1 = figure;
        if 1 % subplot(2,2,1); plot(c,Q,'-o');
            subplot(2,2,1)
            plot(cGrid,Q,'-o')
            xlabel('c'); ylabel('');
            ylim([0 1.1*max(Q)])
            title('Q  from CPLEX')
        end
        if 1 % subplot(2,2,2);  plot(c,W)
            subplot(2,2,2)
            plot(cGrid,w_num)
            ylim([.9*min(w_num) 1.1*max(w_num)])
            hold on
            plot([thresholdCost,thresholdCost], [0,w_num(thresholdType)], ':');

            plot([cGrid(1),thresholdCost], [w_num(thresholdType),w_num(thresholdType)], '--');
            legend('w','p','w(p)','Location','southwest')
            xlabel('c'); ylabel('');
            title('w')
        end
        if 1 % subplot(2,2,3); BorderSlacks + QMonSlacks
            subplot(2,2,3)
            stem(cGrid,BorderDemandConstraintSlacks)
            hold on
            stem(cGrid,QMonSlacksComplete)

            legend('BorderDemand Slacks','Qmon Slacks','Location','northwest')
            xlabel('c'); ylabel('');
            title(['Slacks: ' num2str(totalcountSlacks) ' constraints are slack'])
        end
        if 1 % subplot(2,2,4); Mus + betas
            subplot(2,2,4)
            stem(cGrid,BorderDemandConstraintDuals)
            hold on
            stem(cGrid,QMonDualsComplete)
            legend('BorderDemand betas','Qmon mus','Location','northwest')
            xlabel('c'); ylabel('');
            toSet_yLim = BorderDemandConstraintDuals;
            toSet_yLim(T_num) = [];
            if max(toSet_yLim) < tol
                yMax = 1;
            else
                yMax = max(toSet_yLim);
            end
            ylim([0, yMax]);
            subPlotTitleStr = 'Dual solution: ';
            subPlotTitleStr = [ subPlotTitleStr num2str(numOfPositiveBetas) '  Betas ' ];
            subPlotTitleStr = [ subPlotTitleStr ' and ' num2str(numOfPositiveMus) ' Mus are positive' ];
            title(subPlotTitleStr)
        end
        if 1 % supTitle
            supTitleString = ['S = ' num2str(N) ',  T = ' num2str(T_num), ...
                ',  p = ' num2str(thresholdCost)];

            if v_Linear_f_Normal
                supTitleString = [supTitleString ',  v linear, slope ' num2str(vSlope_num)];
                supTitleString = [supTitleString ',  f normal'];
            elseif v_Quadratic_f_Uniform
                supTitleString = [supTitleString ',  f uniform'];
            end
            %            suptitle(supTitleString)
        end
    end
    if 0 % save figure as pdf: figName =

        figName = ['OPWCQ_fig_vSlope' num2str(vSlope_num) '.pdf'];

        h1.PaperPositionMode = 'manual';
        orient(h1,'landscape');
        set(gcf,'PaperUnits','inches');   x_width = 12;  y_width = 8.5;
        set(gcf, 'PaperPosition', [0 0 x_width y_width]);
        saveas(gcf,figName)
        close all
    end
    %DualTheory

end
return
