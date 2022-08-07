function [domainGrid,sampledFunction] ...
    = fn_AnonFnSampler(anonFn, ...        % e.g. v = @(c)  4 * c - 2 * c^2;
    domainMin, domainMax, domainGridsize) % e.g. 0, 1, 10


if 1 % print function's expression
    anonFnInfo = functions(anonFn);
    %fprintf('%s',anonFnInfo.function)
end

domainGrid = linspace(domainMin,domainMax,domainGridsize); %generates N points between X1 and X2.

sampledFunction = nan(domainGridsize, 1);
for t = 1 : domainGridsize
    sampledFunction(t) =  anonFn(domainGrid(t));
end



end

