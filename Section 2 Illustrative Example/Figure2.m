%% reset + hello
if 1 % reset, initialize paths
    close all; clc; clear all;
end
if 1 % Hello!
    [pathstr, thisFileName, ext] = fileparts(mfilename('fullpath'));
    fprintf('This script  ''%s'' ',thisFileName)
    fprintf(' (today: %s)\n',datetime)
end

warning off

%%

cL = 0; cH = 1; c_Grid_size = 100;
v0 = 0; v1 = 4; v2 = 2;

linewidth = 1.5;
fontsize = 14;
style = {'','-.','--'};
Color2 = [0.8500, 0.3250, 0.0980];
Color3 = [0.9290, 0.6940, 0.1250];

F = @(c) (c-cL)./(cH-cL);
f = @(c) 1/(cH-cL);
v = @(c) v0 + v1 * c - v2 * c.^2;
g = @(c) v(c) - c;  gMaximizer = (v1-1)/(2*v2);
w = @(c) v(c) - c - F(c)./f(c);

pB = -(2*cL*v2 - 3*v1 + 6)/(4*v2);
if pB > cH
    pB = cH;
elseif pB < cL
    pB = cL;
else
    
end

pS = -(2*cL*v2 - 3*v1 + 3)/(4*v2);
if pS > cH
    pS = cH;
elseif pS < cL
    pS = cL;
end


if 1 % description
    fprintf('\nSection 2 in the PL paper has an example with:')
    fprintf('\n f uniform on [0,1],  v(c) = 4*c - 2*c^2')
    fprintf('   ->  w(c) = 2*c - 2*c^2')
    fprintf('\n\n  pB = %g is the solution of equation    [int_0^pB [w(c)*dF(c)] = w(pB) * F(pB)], ', pB)
    fprintf('\n\n  pS = %g, is the corner solution   [int_0^1 [(v(c)-c)*dF(c)] < (v(1)-1)]', pS)
end


% construct V2 and S2 as anonymous functions
V2 = @(p) fn_V2(p,[v0 v1 v2 cL cH]);
S2 = @(p) fn_S2(p,[v0 v1 v2 cL cH]);

Fig2 = figure;

subplot(1,2,1)
fplot(V2, [cL,cH],style{1},'linewidth',linewidth)
legend('$V(p)$','interpreter','latex')
ylim([.95*V2(0), 1.05*V2(0.75)])
xlabel('$p_L$','interpreter','latex')
set(gca,'FontSize',fontsize)

subplot(1,2,2)
fplot(S2, [cL,cH],style{1},'linewidth',linewidth,'Color',Color2,'LineStyle','--')
legend('$S(p)$','interpreter','latex')
xlabel('$p_L$','interpreter','latex')
ylim([.95*S2(0), 1.05*S2(1)])
set(gca,'FontSize',fontsize)

fprintf(' done')


%%
fprintf('\n\nAll done.\n')
