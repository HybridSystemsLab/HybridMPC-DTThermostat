function [xp, kp, jp, allowed] = applyTransition(x, k, j, u, d, p)
%APPLYTRANSITION Check membership and take one disturbed plant transition.
% k counts flows; j counts jumps. An inadmissible input leaves all unchanged.

xp = x(:);
kp = k;
jp = j;
allowed = (u == 0 && inCs(x, u, d)) || (u == 1 && inDs(x, u, d));
if ~allowed
    return;
end

if u == 0
    xp = fs(x, u, d, p);
    kp = k + 1;
else
    xp = gs(x, u, d, p);
    jp = j + 1;
end
end
