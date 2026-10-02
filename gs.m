function xp = gs(x, u, d, p) %#ok<INUSD>
%GS Instantaneous jump: toggle the heater and preserve temperature.
% d has no effect on jumps; p is retained for the shared plant-map interface.
assert(inDs(x, u, d), 'gs:OutsideDs', 'Triple is outside Ds.');
x = x(:);
xp = [x(1); 1-x(2)];
end
