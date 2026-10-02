%RUNTHERMOSTAT Compare nominal and disturbed receding-horizon simulations.
clear;
close all;
clc;

%% Run both controllers in parallel from the same initial state.
p = thermostatParameters();
assert(~isempty(ver('parallel')) && ...
    license('test', 'Distrib_Computing_Toolbox'), ...
    'runThermostat requires Parallel Computing Toolbox.');
pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('Processes', 2);
end
assert(~isa(pool, 'parallel.ThreadPool') && pool.NumWorkers >= 2, ...
    'Use a process pool with at least two workers to run both simulations.');
disturbances = {@(x,k,j,h) 0, @(x,k,j,h) ...
    p.disturbanceAmplitude*(0.65*sin(0.7*k) + 0.35*cos(0.31*k))};
simulationLogs = cell(1, 2);
parfor (simulationIndex = 1:2, 2)
    simulationLogs{simulationIndex} = ...
        simulateThermostat(p, disturbances{simulationIndex});
end
nominal = simulationLogs{1};
perturbed = simulationLogs{2};

%% Physical time advances only on flows; jumps retain duplicate times.
nominalTime = p.s*nominal.k;
perturbedTime = p.s*perturbed.k;
timeEnd = max([nominalTime, perturbedTime]);
nominalColor = [0.00, 0.35, 0.70];
perturbedColor = [0.85, 0.33, 0.10];

%% 1. Temperature and the temperature band of the target set A.
figure('Color', 'w', 'Name', 'Temperature');
band = fill([0, timeEnd, timeEnd, 0], ...
    [p.zmin, p.zmin, p.zmax, p.zmax], [0.75, 0.87, 0.75], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on;
hNominal = plot(nominalTime, nominal.X(1,:), '-', ...
    'Color', nominalColor, 'LineWidth', 1.5);
hPerturbed = plot(perturbedTime, perturbed.X(1,:), '--', ...
    'Color', perturbedColor, 'LineWidth', 1.5);
yline(p.zmin, ':', '', 'Interpreter', 'latex', ...
    'HandleVisibility', 'off');
yline(p.zmax, ':', '', 'Interpreter', 'latex', ...
    'HandleVisibility', 'off');
ax = gca;
ax.FontSize = 20;
xlabel('Flow time $sk$ [sec]', 'Interpreter', 'latex', 'FontSize', 35);
ylabel('Temperature $z$', 'Interpreter', 'latex', 'FontSize', 35);
% legend([hNominal, hPerturbed, band], ...
%     {'Nominal', 'Perturbed', '$\mathcal{A}$ (temperature band)'}, ...
%     'Interpreter', 'latex', 'FontSize', 35, 'Location', 'best');
xlim([0, timeEnd]);
grid on;
box on;

%% 2. Heater mode, held constant between jumps.
figure('Color', 'w', 'Name', 'Heater mode');
stairs(nominalTime, nominal.X(2,:), '-', ...
    'Color', nominalColor, 'LineWidth', 1.5);
hold on;
stairs(perturbedTime, perturbed.X(2,:), '--', ...
    'Color', perturbedColor, 'LineWidth', 1.5);
ax = gca;
ax.FontSize = 20;
xlabel('Flow time $sk$ [sec]', 'Interpreter', 'latex', 'FontSize', 35);
ylabel('Heater mode $q$', 'Interpreter', 'latex', 'FontSize', 35);
yticks([0, 1]);
yticklabels({'OFF', 'ON'});
ylim([-0.1, 1.1]);
xlim([0, timeEnd]);
% legend('Nominal', 'Perturbed', ...
%     'Interpreter', 'latex', 'FontSize', 35, 'Location', 'best');
grid on;
box on;

%% 3. Optimal value at MPC reoptimization instants.
% solveAt is a zero-based transition index, not a flow count or time.
nominalSolveTime = nominalTime(nominal.solveAt+1);
perturbedSolveTime = perturbedTime(perturbed.solveAt+1);
figure('Color', 'w', 'Name', 'Optimal value function');
plot(nominalSolveTime, nominal.value, '-o', ...
    'Color', nominalColor, 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(perturbedSolveTime, perturbed.value, '--s', ...
    'Color', perturbedColor, 'LineWidth', 1.5, 'MarkerSize', 4);
ax = gca;
ax.FontSize = 20;
xlabel('$t \: [s]$', 'Interpreter', 'latex', 'FontSize', 35);
ylabel('Optimal value $V^*(x)$', 'Interpreter', 'latex', 'FontSize', 35);
title('Value function at MPC reoptimization instants');
xlim([0, timeEnd]);
legend('Nominal', 'Perturbed', ...
    'Interpreter', 'latex', 'FontSize', 35, 'Location', 'best');
grid on;
box on;

fprintf('Nominal: k=%d, j=%d; perturbed: k=%d, j=%d.\n', ...
    nominal.k(end), nominal.j(end), perturbed.k(end), perturbed.j(end));
