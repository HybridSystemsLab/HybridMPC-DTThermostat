function xp = fs(x, u, d, p)
%FS Discrete flow: evolve temperature while holding heater mode constant.
% d is added once per flow; it is not multiplied by the step size p.s.
assert(inCs(x, u, d), 'fs:OutsideCs', 'Triple is outside Cs.');
x = x(:);
equilibriumTemperature = p.zo + p.zDelta*x(2);
xp = [p.a*x(1) + (1-p.a)*equilibriumTemperature + d; x(2)];
end
