%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
%     Phase Field Dendrite Growth Simulation        %
%     相场枝晶生长模拟主程序                         %
%                                                   %
%     Unified Main Program - Version 1.9            %
%     统一主程序 - 版本 1.9                          %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear workspace
clear; clc;

%% Add PFM_core to path
% 添加PFM_core到路径
fprintf('Adding PFM_core to path...\n');
fprintf('正在添加PFM_core到路径...\n');
addpath('PFM_core');

%% Load default configuration
% 加载默认配置
fprintf('\nLoading default configuration...\n');
fprintf('正在加载默认配置...\n\n');
params = config_default();

%% (Optional) Customize parameters here
% 在此处自定义参数
%
% For example | 例如:
% params.visualization = true;
% params.total_time = 5.0;
% params.Nx = 400;
% params.epsilon_aniso = 0.03;

%% Display simulation parameters
% 显示模拟参数
fprintf('========================================================\n');
fprintf('  Simulation Parameters | 模拟参数\n');
fprintf('========================================================\n');
fprintf('Grid size: %d x %d\n', params.Nx, params.Ny);
fprintf('Spatial step: %.2f x %.2f\n', params.dx, params.dy);
fprintf('Total time: %.1f s\n', params.total_time);
fprintf('\n');
fprintf('  Partition coefficient (k): %.2f\n', params.k_partition);
fprintf('  Anisotropy strength (ε): %.2f\n', params.epsilon_aniso);
fprintf('  Anisotropy mode (m): %d\n', params.m_aniso);
fprintf('  Coupling constant (λ): %.1f\n', params.lambda_coup);
fprintf('  Diffusion coefficient (D): %.3f\n', params.D_coefficient);
fprintf('  Undercooling (θ): %.1f\n', params.theta_field);
fprintf('\n');
fprintf('Options:\n');
fprintf('  Visualization: %s\n', mat2str(params.visualization));
fprintf('  Tip tracking: %s\n', mat2str(params.tip_tracking));
fprintf('  Boundary condition: %s\n', params.boundary_condition);
fprintf('========================================================\n\n');

%% Run simulation
% 运行模拟
fprintf('Starting simulation...\n');
fprintf('开始模拟...\n\n');
tic;

results = run_simulation(params);

elapsed = toc;

%% Display summary
% 显示摘要
fprintf('\n========================================================\n');
fprintf('  Simulation Complete | 模拟完成\n');
fprintf('========================================================\n');
fprintf('Final time: %.2f s\n', results.final_time);
fprintf('Total steps: %d\n', results.total_steps);
fprintf('Computation time: %.2f s\n', elapsed);
fprintf('\nResults saved to: %s\n', params.output_filename);
fprintf('结果已保存到: %s\n', params.output_filename);
fprintf('========================================================\n\n');

%% End of main program
% 主程序结束
fprintf('Main program completed successfully!\n');
fprintf('主程序成功完成!\n');
