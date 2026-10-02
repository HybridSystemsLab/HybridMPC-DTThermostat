function cost = terminalCost(x, p)
%TERMINALCOST Penalize final band excess with heater-dependent weights.
z = x(1);
q = x(2);
lowerExcess = max(p.zmin-z, 0);
upperExcess = max(z-p.zmax, 0);
cost = 0.5*(2-q)*lowerExcess^2 + 0.5*(1+q)*upperExcess^2;
end
