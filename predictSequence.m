function plan = predictSequence(x0, u, p)
%PREDICTSEQUENCE Roll out a control sequence with zero disturbance.
% X(:,step) is the state before u(step). k and j count flows and jumps
% relative to this prediction's initial state; both counters start at zero.

nTransitions = numel(u);
X = zeros(2, nTransitions+1);
X(:, 1) = x0(:);
k = zeros(1, nTransitions+1);
j = zeros(1, nTransitions+1);
stageCost = 0;

for step = 1:nTransitions
    if u(step) == 0
        stageCost = stageCost + LC(X(:, step), 0, p);
        X(:, step+1) = fs(X(:, step), 0, 0, p);
        k(step+1) = k(step) + 1;
        j(step+1) = j(step);
    else
        stageCost = stageCost + LD(X(:, step), 1, p);
        X(:, step+1) = gs(X(:, step), 1, 0, p);
        k(step+1) = k(step);
        j(step+1) = j(step) + 1;
    end
end

plan = struct('X', X, 'u', u, 'k', k, 'j', j, ...
    'cost', stageCost + terminalCost(X(:, end), p));
end
