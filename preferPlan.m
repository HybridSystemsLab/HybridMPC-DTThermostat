function better = preferPlan(candidate, best)
%PREFERPLAN Compare costs and deterministically resolve numerical ties.
if isempty(best)
    better = true;
    return;
end

tolerance = 1e-9*(1 + max(best.cost, candidate.cost));
better = candidate.cost < best.cost-tolerance;
if abs(candidate.cost-best.cost) <= tolerance
    % Lexicographic preference: more flows, fewer jumps, then a first flow.
    % This selection rule does not modify the MPC objective.
    score = @(plan) [plan.k(end), -plan.j(end), -plan.u(1)];
    candidateScore = score(candidate);
    bestScore = score(best);
    firstDifference = find(candidateScore ~= bestScore, 1);
    better = ~isempty(firstDifference) && ...
        candidateScore(firstDifference) > bestScore(firstDifference);
end
end
