clear all; close all; clc;

%% Inputs
cL=1;pL=3;pH=4.4;cH=5;N=2;
f=@(x) 1/(cH-cL);
F=@(x) (x-cL)/(cH-cL);

%% Grids
numC=100;
c_grd=linspace(cL,cH,numC);

%% Main
f1=@(y)  (N-1)*f(y)*(1-F(y))^(N-2);
beta_integrand=@(y) min(y,pH)*f1(y);
beta_num=@(x) integral(beta_integrand, x, cH,'ArrayValued',true);
beta_den=@(x) integral(f1, x, cH,'ArrayValued',true);
beta=@(x) beta_num(x)/beta_den(x);
betainv=@(b) fzero(@(x) b-beta(x), .5*cL+.5*cH);
Qbar=(1-(1-F(pL))^N)/(N*F(pL));
betapL=beta(pL);
bL=(Qbar-(1-F(pL))^(N-1))/Qbar*pL+(1-F(pL))^(N-1)/Qbar*betapL;

beta_sampled_pre=NaN(1,numC-1);
beta_sampled_post=NaN(1,numC-1);
lola_bid_sampled=NaN(1,numC-1);
for c_index=1:numC-1
    
    if c_grd(c_index)<pL
        beta_sampled_pre(c_index)=bL;
        lola_bid_sampled(c_index)=pL;
    elseif c_grd(c_index)<pH
        beta_sampled_post(c_index)=beta(c_grd(c_index));
        lola_bid_sampled(c_index)=c_grd(c_index);
    end
end

figure(3) 
hold on
plot(c_grd(1:end-1), lola_bid_sampled,'b','linewidth',2)
plot(c_grd(1:end-1), beta_sampled_pre,'r','linewidth',2)
plot(c_grd(1:end-1), beta_sampled_post,'r','linewidth',2)
xlim([0, 5]);
ylim([0, 5]);
xlabel('supplier cost')
ylabel('bids')
legend('LoLA equilibrium bidding strategy','FP-LoLA equilibrium bidding strategy','Location', 'Best')