function ok = inCs(x, u, d)
%INCS Membership in Cs = R x {0,1} x {0} x R.
% Section VI imposes no temperature guard or disturbance magnitude bound.
ok = validTriple(x, u, d) && u == 0;
end
