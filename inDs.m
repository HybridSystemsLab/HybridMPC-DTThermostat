function ok = inDs(x, u, d)
%INDS Membership in Ds = R x {0,1} x {1} x R.
% Section VI imposes no temperature guard or disturbance magnitude bound.
ok = validTriple(x, u, d) && u == 1;
end
