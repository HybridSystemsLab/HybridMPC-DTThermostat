function segment = applyControlHorizon(x, k, j, h, plan, p, disturbance)
%APPLYCONTROLHORIZON Replay a plan until tauC, blocked input, or run limit.
% k and j are global counters; h = k+j is the total transition count.
% disturbance(x,k,j,h) is evaluated at the current measured plant state.

segment.X = x(:);
segment.k = k;
segment.j = j;
segment.u = [];
segment.d = [];
segment.blocked = false;

for step = 1:numel(plan.u)
    if h >= p.nTransitions
        break;
    end
    u = plan.u(step);
    d = disturbance(x, k, j, h);
    [xp, kp, jp, allowed] = applyTransition(x, k, j, u, d, p);
    if ~allowed
        segment.blocked = true;
        break;
    end

    x = xp;
    k = kp;
    j = jp;
    h = h + 1;
    segment.X(:, end+1) = x;
    segment.k(end+1) = k;
    segment.j(end+1) = j;
    segment.u(end+1) = u;
    segment.d(end+1) = d;

    % The control horizon uses LOCAL plan counters, not global plant time.
    if max(plan.k(step+1), plan.j(step+1)) >= p.tauC
        break;
    end
end
end
