# Thermostat hybrid MPC

MATLAB files for the thermostat example in Section VI.

## File structure

`runThermostat.m` is the main script. It runs the nominal and disturbed
simulations and plots the results.

| Files | Purpose |
| --- | --- |
| `runThermostat.m` | Main script |
| `thermostatParameters.m` | Model parameters, initial state, horizons, and solver settings |
| `simulateThermostat.m` | Simulation loop and logging |
| `solveThermostatMPC.m` | MPC solver |
| `generateFlowJumpSequences.m` | Candidate flow/jump sequences |
| `predictSequence.m` | Predicted trajectory and cost for a sequence |
| `optimizeSequence.m` | Optimization for a fixed sequence |
| `preferPlan.m` | Comparison of candidate plans |
| `applyControlHorizon.m` | Execution of the selected plan |
| `applyTransition.m` | Single plant transition |
| `fs.m`, `gs.m` | Flow and jump maps |
| `inCs.m`, `inDs.m` | Flow and jump set membership |
| `validTriple.m` | State, control, and disturbance validation |
| `distanceToA.m` | Distance to the target set |
| `LC.m`, `LD.m`, `terminalCost.m` | Flow, jump, and terminal costs |
