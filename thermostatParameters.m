function p = thermostatParameters()
%THERMOSTATPARAMETERS Model, horizons, simulation settings, and solver options.
% Values are illustrative; Section VI specifies inequalities, not numbers.

% Thermal model: q=0 cools toward zo; q=1 heats toward zo+zDelta.
p.zo = 10;
p.zDelta = 20;
p.zmin = 19;                  % Lower edge of the target temperature band.
p.zmax = 21;                  % Upper edge of the target temperature band.
p.s = 0.1;                    % Physical time elapsed during one flow step.
p.a = exp(-p.s);              % Discrete thermal decay factor.

% Hybrid horizons are measured by max(flow count, jump count).
p.tauP = 5;                   % Prediction horizon.
p.tauC = 3;                   % Execution horizon before replanning.
p.nTransitions = 60;         % Simulation limit measured by k+j.
p.x0 = [24; 1];               % Initial [temperature; heater mode].
% Illustrative bounded disturbance chosen to show small target-band exits.
% This amplitude is not a certified local ISS disturbance bound.
p.disturbanceAmplitude = 0.30; % Additive temperature disturbance per flow.

% Check the model assumptions in equation (14).
limit = min([(p.zmax-p.zo)/(p.zmin-p.zo), ...
    (p.zo+p.zDelta-p.zmin)/(p.zo+p.zDelta-p.zmax), ...
    p.zDelta/(p.zmin+p.zDelta-p.zmax)]);
assert(0 < p.zo && p.zo < p.zmin && p.zmin < p.zmax && ...
    p.zmax < p.zo+p.zDelta && exp(p.s) < limit, 'Equation (14) fails.');
assert(p.tauC >= 1 && p.tauC <= p.tauP && p.tauP == fix(p.tauP) ...
    && p.tauC == fix(p.tauC));

p.options = optimoptions('fmincon', 'Algorithm', 'interior-point', ...
    'Display', 'off', 'SpecifyObjectiveGradient', true, ...
    'ConstraintTolerance', 1e-9, 'OptimalityTolerance', 1e-9, ...
    'MaxIterations', 200);
end
