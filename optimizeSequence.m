function result = optimizeSequence(x0, u, p)
%OPTIMIZESEQUENCE Solve the convex subproblem for a fixed binary sequence.
% x = [z; q] contains temperature z and heater mode q. The sequence u fixes
% every heater mode, so only temperatures and band excesses enter fmincon.
% Decision vector: [all temperatures; all lower excesses; all upper excesses].

plan = predictSequence(x0, u, p);
nStates = numel(u) + 1;
heaterModes = plan.X(2, :)';

% Fix the initial temperature and enforce one dynamics equation per step.
% Each row involves only the temperature block of the decision vector.
Aeq = zeros(nStates, 3*nStates);
beq = zeros(nStates, 1);
Aeq(1, 1) = 1;
beq(1) = x0(1);
for step = 1:nStates-1
    Aeq(step+1, step+1) = 1;
    if u(step) == 0
        Aeq(step+1, step) = -p.a;
        beq(step+1) = (1-p.a)*(p.zo + p.zDelta*heaterModes(step));
    else
        % A jump toggles the heater without changing temperature.
        Aeq(step+1, step) = -1;
    end
end

% Nonnegative excesses satisfy lower >= zmin-z and upper >= z-zmax.
identity = eye(nStates);
zeroBlock = zeros(nStates);
A = [-identity, -identity, zeroBlock; identity, zeroBlock, -identity];
b = [-p.zmin*ones(nStates, 1); p.zmax*ones(nStates, 1)];
lowerBounds = [-inf(nStates, 1); zeros(2*nStates, 1)];

% Stage costs use the pre-transition state. The last state instead receives
% terminal weights, which depend on the final heater mode.
stageWeights = zeros(nStates, 1);
stageWeights(1:nStates-1) = ((1-p.a^2)*(u(:) == 0) + (u(:) == 1))/2;
lowerWeights = stageWeights;
upperWeights = stageWeights;
lowerWeights(end) = (2-heaterModes(end))/2;
upperWeights(end) = (1+heaterModes(end))/2;

% Exact nominal rollout supplies a feasible initial guess and reference cost.
temperatures = plan.X(1, :)';
initialGuess = [temperatures; max(p.zmin-temperatures, 0); ...
    max(temperatures-p.zmax, 0)];
[solution, solverCost, exitflag, output] = fmincon(@objective, ...
    initialGuess, A, b, Aeq, beq, lowerBounds, [], [], p.options);
residual = max([0; A*solution-b; abs(Aeq*solution-beq); lowerBounds-solution]);

% Reject failed solves or disagreement with the independently computed cost.
if exitflag <= 0 || residual > 1e-7 || ...
        abs(solverCost-plan.cost) > 1e-6*(1+plan.cost)
    error('optimizeSequence:Failure', ...
        'fmincon failed: flag %d, residual %g.', exitflag, residual);
end
result = plan;
result.fminconCost = solverCost;
result.exitflag = exitflag;
result.output = output;

    function [cost, gradient] = objective(variables)
        lowerExcess = variables(nStates+1:2*nStates);
        upperExcess = variables(2*nStates+1:3*nStates);
        cost = sum(lowerWeights.*lowerExcess.^2 + upperWeights.*upperExcess.^2);
        gradient = [zeros(nStates, 1); ...
            2*lowerWeights.*lowerExcess; 2*upperWeights.*upperExcess];
    end
end
