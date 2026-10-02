function log = simulateThermostat(p, disturbance)
%SIMULATETHERMOSTAT Alternate nominal optimization and disturbed execution.
% State logs have one more entry than input logs, including the initial state.
% solveAt stores global transition indices where a new plan was computed.

sequences = generateFlowJumpSequences(p.tauP);
x = p.x0(:);
k = 0;
j = 0;
h = 0;
log.X = x;
log.k = k;
log.j = j;
log.u = [];
log.d = [];
log.solveAt = [];
log.value = [];
log.status = 'transition limit reached';

while h < p.nTransitions
    plan = solveThermostatMPC(x, p, sequences);
    log.solveAt(end+1) = h;
    log.value(end+1) = plan.cost;
    segment = applyControlHorizon(x, k, j, h, plan, p, disturbance);
    if isempty(segment.u)
        log.status = 'no admissible transition';
        return;
    end

    % Skip the segment's initial state: it is already the last logged state.
    log.X = [log.X, segment.X(:, 2:end)];
    log.k = [log.k, segment.k(2:end)];
    log.j = [log.j, segment.j(2:end)];
    log.u = [log.u, segment.u];
    log.d = [log.d, segment.d];

    % Replan from the actual endpoint, including accumulated disturbances.
    x = segment.X(:, end);
    k = segment.k(end);
    j = segment.j(end);
    h = h + numel(segment.u);
end
end
