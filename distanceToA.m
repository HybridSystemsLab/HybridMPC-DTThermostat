function distance = distanceToA(x, p)
%DISTANCETOA Temperature distance to A = [zmin,zmax] x {0,1}.
% For a valid binary heater mode, only temperature contributes to distance.
distance = max([p.zmin-x(1), 0, x(1)-p.zmax]);
end
