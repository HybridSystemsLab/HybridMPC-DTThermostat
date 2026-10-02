function best = solveThermostatMPC(x0, p, sequences)
%SOLVETHERMOSTATMPC Optimize every discrete sequence and select a plan.
% Pass precomputed sequences to reuse enumeration between controller calls.
if nargin < 3
    sequences = generateFlowJumpSequences(p.tauP);
end
assert(validTriple(x0, 0, 0), 'Invalid initial state.');

best = [];
for sequenceIndex = 1:numel(sequences)
    candidate = optimizeSequence(x0, sequences{sequenceIndex}, p);
    if preferPlan(candidate, best)
        best = candidate;
    end
end
best.numberOfSequences = numel(sequences);
assert(max(best.k(end), best.j(end)) == p.tauP);
end
