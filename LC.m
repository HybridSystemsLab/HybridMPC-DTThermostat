function cost = LC(x, u, p)
%LC Nominal flow stage cost, evaluated before the transition.
assert(inCs(x, u, 0));
cost = (1-p.a^2)/2*distanceToA(x, p)^2;
end
