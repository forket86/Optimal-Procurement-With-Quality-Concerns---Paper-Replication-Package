desktopFolder = '.\';
modFileName = '..\OP01_mod.txt';

if 1 % 1. symbolic framework
    syms x y z p % vars
    syms a xi_1 xi_2 v_0 % params
    if 1.1 % f, F
        f_1 = 1 + a*(x-.5);
        F_1 = subs(int(f_1, x , [0,z]),z,x);
        f_2 = 1;
        F_2 = subs(int(f_2, y , [0,z]),z,y);
    end

    if 1.2 % v_1, v_2
        v_1 = v_0 + xi_1*(-1/3 + x - .5*(x^2));
        v_2 = v_0 + xi_2*(-1/3 + y - .5*(y^2));
    end
    if 1.3 % w_1, w_2
        w_1 = v_1 - x - F_1/f_1;
        w_2 = v_2 - y - F_2/f_2;
    end
    symbParams = [a, xi_1, xi_2, v_0];
end
a_Grid = linspace(-.5, .5, 17);
xi_2_Grid = linspace(2.5,5.5,11);
a_num = a_Grid(a_Idx);
xi_2_num = xi_2_Grid(xi_Idx);
datFileName = sprintf('..\\DAT_a\\%g_OP02_dat.txt',a_Idx);
if 1 % primitive numeric parameters
    costGridSize1 = 100;  costGridSize2 = 101;
    v_0_num = 2; xi_1_num = 4;
end
numParams = [a_num, xi_1_num, xi_2_num, v_0_num];
if 1 % 5.2 symbolic-specific
    if 1 % specific w_1, w_2
        w_1_specific = subs(w_1, symbParams, numParams);
        w_2_specific = subs(w_2, symbParams, numParams);
    end
    if 1 % matlabFunctions
        w_1_num_fn = matlabFunction(w_1_specific);
        w_2_num_fn = matlabFunction(w_2_specific);
    end
end
if 1 % 5.3 sample w1, w2
    costGrid1 = linspace(0,1,costGridSize1);
    f_1_sampled = nan(1,costGridSize1);
    F_1_sampled = nan(1,costGridSize1);
    w_1_sampled = nan(1,costGridSize1);

    costGrid2 = linspace(0,1,costGridSize2);
    f_2_sampled = nan(1,costGridSize2);
    F_2_sampled = nan(1,costGridSize2);
    w_2_sampled = nan(1,costGridSize2);

    for xIdx = 1 : costGridSize1
        f_1_sampled(xIdx) = 1/costGridSize1;
        F_1_sampled(xIdx) = sum(f_1_sampled(1:xIdx));
        w_1_sampled(xIdx) = w_1_num_fn(costGrid1(xIdx));
    end
    for xIdx = 1 : costGridSize2
        f_2_sampled(xIdx) = 1/costGridSize2;
        F_2_sampled(xIdx) = sum(f_2_sampled(1:xIdx));
        w_2_sampled(xIdx) = w_2_num_fn(costGrid2(xIdx));
    end
end
Asymmetries
if 1 % build m_1_opt,m_2_opt (using EPEC)
    m_1_opt = nan(costGridSize1,costGridSize2);
    for j = 1 : costGridSize2
        m_1_opt(costGridSize1,j) = costGrid1(costGridSize1) * q_1_opt(costGridSize1,j);
        for i = costGridSize1-1: -1 : 1
            m_1_opt(i,j)  = m_1_opt(i+1,j) -  costGrid1(i) * (q_1_opt(i+1,j) - q_1_opt(i,j));
        end
    end
    m_2_opt = nan(costGridSize1,costGridSize2);
    for i = 1 : costGridSize1
        m_2_opt(i,costGridSize2) = costGrid2(costGridSize2) * q_2_opt(i,costGridSize2);
        for j = costGridSize2 - 1: -1 : 1
            m_2_opt(i,j)  = m_2_opt(i,j+1) - costGrid2(j) * (q_2_opt(i,j+1) - q_2_opt(i,j));
        end
    end
end
if 1 % find floor prices
    if q_1_opt(1,1) == 1 % 1 wins in the SW rectangle
        pL1_idx = find(abs(diff(q_1_opt(:,1))) > .1);
        if isempty(pL1_idx)
            pL1_idx = costGridSize1;
            pL2_idx = find(abs(diff(q_1_opt(1,:))) > .1);
        else
            pL2_idx = find(abs(diff(q_1_opt(pL1_idx+1,:))) > .1);
        end
    end

    if q_2_opt(1,1) == 1 % 2 wins in the SW rectangle
        pL2_idx = find(abs(diff(q_2_opt(1,:))) > .1);
        if isempty(pL2_idx)
            pL2_idx = costGridSize2;
            pL1_idx = find(abs(diff(q_2_opt(:,1))) > .1);
        else
            pL1_idx = find(abs(diff(q_2_opt(:,pL2_idx+1))) > .1);
        end
    end
    pL2 = costGrid2(pL2_idx);
    pL1 = costGrid1(pL1_idx);
end
if 1 % six-panel figure: w's, f's, q's, m's
    figure('units','normalized','outerposition',[.3 .1 .5 .5])
    % ----------------------------------------------------
    subplot(3,2,1)
    hold on
    fplot(w_1_specific, 'r')
    fplot(w_2_specific, 'g')
    plot(costGrid1,w_1_sampled,  'r')
    plot(costGrid2,w_2_sampled, 'g')
    xlim([0,1])
    ylim([0,1.5])
    % titleStr = sprintf('$w_1$ and $w_2$, ');
    %titleStr = [titleStr ...
    %   sprintf('\\quad $a = %g$,  \\quad $\\xi_1 = %g$, \\quad $\\xi_2 = %g$', ...
    %  a_num, xi_1_num, xi_2_num) ];
    %title(titleStr)
    legend('$w_1$', '$w_2$','Location','best')
    % ----------------------------------------------------
    subplot(3,2,2)
    hold on
    f_1_specific = subs(f_1, symbParams, numParams);
    fplot(f_1_specific,[0,1],'r')
    plot([0,1], [1,1],'g')
    %  titleStr = sprintf('$f_1$ and $f_2$, ');
    % titleStr = [titleStr ...
    %    sprintf('\\quad $a = %g$,  \\quad $\\xi_1 = %g$, \\quad $\\xi_2 = %g$', ...
    %   a_num, xi_1_num, xi_2_num) ];
    %title(titleStr)
    legend('$f_1$', '$f_2$','Location','best' )
    ylim([0,2])
    % ----------------------------------------------------
    subplot(3,2,3)
    surf(costGrid1,costGrid2,q_1_opt')
    xlabel('$x$'); ylabel('$y$');
    title('$q_1$')
    view([0,90]) %view([-20,30])
    zlim([.01,1])
    % ----------------------------------------------------
    subplot(3,2,4)
    surf(costGrid1,costGrid2,q_2_opt')
    xlabel('$x$'); ylabel('$y$');
    title('$q_2$')
    view([0,90]) %view([-20,30])
    zlim([.01,1])
    % ----------------------------------------------------
    subplot(3,2,5)
    surf(costGrid1,costGrid2,m_1_opt')
    xlabel('$x$'); ylabel('$y$');
    title('$m_1$')
    view([0,90]) %view([-20,30])
    zlim([.01,1])
    % ----------------------------------------------------
    subplot(3,2,6)
    surf(costGrid1,costGrid2,m_2_opt')
    xlabel('$x$'); ylabel('$y$');
    title('$m_2$')
    view([0,90]) %view([-20,30])
    zlim([.01,1])
    % ----------------------------------------------------
    titleStr = sprintf('$\\xi_1 = %g$, \\ \\  $\\xi_2 = %g$, \\ \\ $a = %g$', ...
        xi_1_num, xi_2_num, a_num );
    titleStr = [titleStr ...
        sprintf(', \\ \\  $p_{L,1} = %g$, \\  $p_{L,2} = %g$', ...
        pL1, pL2)];

    sgtitle(titleStr)
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')
    colormap(jet);
end
