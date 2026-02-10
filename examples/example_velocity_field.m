% Velocity Field Effects Example with Video Output
% 速度场影响示例（含视频输出）
%
% This example demonstrates dendritic growth under uniform flow,
% and generates comprehensive growth videos including:
% 本示例演示均匀流场下的枝晶生长，并生成全面的生长视频，包括：
% - Phase field evolution (相场演化)
% - Concentration field evolution (浓度场演化)
% - C/C∞ field evolution (C/C∞场演化)
% - Dendrite contour evolution with velocity field (速度场下枝晶轮廓演化)
%
% Author: pavedplaza(Zhejiang University And Chongqing Uinversity, 2026)
% Date: 2026-02-11

clear; clc; close all;

%% Step 1: Switch to project root directory
% 步骤1：切换到项目根目录
% Get the directory of this script
script_dir = fileparts(mfilename('fullpath'));
% Go up one level to reach project root
project_root = fileparts(script_dir);
% Change to project root directory
cd(project_root);

fprintf('========================================================\n');
fprintf('  Velocity Field Effects Example | 速度场影响示例\n');
fprintf('========================================================\n');
fprintf('Current directory: %s\n', pwd);
fprintf('\n');

%% Step 2: Add PFM_core to path
% 步骤2：添加PFM_core到路径
if exist('PFM_core', 'dir')
    addpath('PFM_core');
    fprintf('✓ PFM_core added to path\n');
else
    error('✗ Error: PFM_core directory not found!');
end

if exist('config_default.m', 'file')
    fprintf('✓ config_default.m found\n');
else
    error('✗ Error: config_default.m not found!');
end

%% Step 3: Load and customize configuration
% 步骤3：加载并自定义配置
fprintf('\nLoading configuration...\n');
params = config_default();

% Customize parameters for this example
% 为此示例自定义参数
params.total_time = 20.0;          % Total simulation time (τ₀) | 总模拟时间
params.visualization = true;       % Enable real-time visualization | 启用实时可视化
params.tip_tracking = false;       % Disable tip tracking for velocity field demo | 禁用尖端追踪
params.output_interval = 0.5;      % Output interval for video smoothness | 输出间隔（视频流畅度）

% Enable uniform flow field
% 启用均匀流场
params.velocity_field = 'uniform';  % Uniform flow type | 均匀流类型
params.v_x_magnitude = 2.0;         % Uniform velocity in x-direction | x方向均匀流速
params.v_y_magnitude = 0.0;         % Uniform velocity in y-direction | y方向均匀流速

% Video output settings
% 视频输出设置
params.save_video = true;          % Enable video saving | 启用视频保存
params.video_fps = 10;             % Video frames per second | 视频帧率

%% Step 4: Display simulation parameters
% 步骤4：显示模拟参数
fprintf('\n========================================================\n');
fprintf('  Simulation Parameters | 模拟参数\n');
fprintf('========================================================\n');
fprintf('Grid size: %d x %d\n', params.Nx, params.Ny);
fprintf('Spatial step: %.2f x %.2f\n', params.dx, params.dy);
fprintf('Total time: %.1f τ₀\n', params.total_time);
fprintf('Output interval: %.2f τ₀\n', params.output_interval);
fprintf('\n');
fprintf('  Partition coefficient (k): %.2f\n', params.k_partition);
fprintf('  Anisotropy strength (ε): %.2f\n', params.epsilon_aniso);
fprintf('  Anisotropy mode (m): %d\n', params.m_aniso);
fprintf('  Coupling constant (λ): %.1f\n', params.lambda_coup);
fprintf('  Diffusion coefficient (D): %.3f\n', params.D_coefficient);
fprintf('  Undercooling (θ): %.1f\n', params.theta_field);
fprintf('\n');
fprintf('Velocity Field:\n');
fprintf('  Type: %s\n', params.velocity_field);
fprintf('  X-velocity magnitude: %.1f\n', params.v_x_magnitude);
fprintf('  Y-velocity magnitude: %.1f\n', params.v_y_magnitude);
fprintf('\n');
fprintf('Options:\n');
fprintf('  Visualization: %s\n', mat2str(params.visualization));
fprintf('  Video output: %s\n', mat2str(params.save_video));
fprintf('  Video FPS: %d\n', params.video_fps);
fprintf('========================================================\n\n');

%% Step 5: Run simulation
% 步骤5：运行模拟
fprintf('Starting simulation...\n');
fprintf('开始模拟...\n');
fprintf('Estimated time: 20-40 minutes (depending on your hardware)\n\n');
tic;

results = run_simulation(params);

elapsed = toc;

%% Step 6: Display summary
% 步骤6：显示摘要
fprintf('\n========================================================\n');
fprintf('  Simulation Complete | 模拟完成\n');
fprintf('========================================================\n');
fprintf('Final time: %.2f τ₀\n', results.final_time);
fprintf('Total steps: %d\n', results.total_steps);
fprintf('Computation time: %.2f seconds (%.2f minutes)\n', elapsed, elapsed/60);
fprintf('\n');
fprintf('Output files:\n');
fprintf('  - Data: %s\n', params.output_filename);
if params.save_video
    fprintf('  - Video: velocity_field_combined.mp4 (3 subplots: phase, concentration, C/C∞)\n');
    fprintf('  - Video: velocity_field_contour.mp4 (quiver plot with dendrite contour)\n');
end
fprintf('========================================================\n\n');

%% End of example
fprintf('Example completed successfully!\n');
fprintf('示例成功完成！\n');
