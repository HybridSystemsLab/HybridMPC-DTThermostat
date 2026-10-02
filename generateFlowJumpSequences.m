function sequences = generateFlowJumpSequences(tauP)
%GENERATEFLOWJUMPSEQUENCES Enumerate controls ending on max(k,j) = tauP.
% 0 means flow; 1 means jump. Neither counter may exceed tauP.
% A sequence can reach the boundary and then continue along it, so valid
% sequences have between tauP and 2*tauP transitions.

assert(tauP >= 1 && tauP == fix(tauP));
sequences = {};
visit([], 0, 0);

    function visit(controls, k, j)
        % Record this endpoint, but keep exploring any allowed extensions.
        if max(k, j) == tauP
            sequences{end+1} = controls; %#ok<AGROW>
        end
        if k < tauP
            visit([controls, 0], k+1, j);
        end
        if j < tauP
            visit([controls, 1], k, j+1);
        end
    end
end
