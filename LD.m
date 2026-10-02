function cost = LD(x, u, p)
%LD Nominal jump stage cost, evaluated before the transition.
assert(inDs(x, u, 0));
cost = 1/2*distanceToA(x, p)^2;
end
