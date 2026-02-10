function params = config_default()
% CONFIG_DEFAULT Default parameter configuration for phase field simulation
% 默认参数配置函数 | 相场模拟默认参数
%
% This function returns a structure containing all default parameters for
% the concentration-phase field simulation of dendritic growth.
% 本函数返回枝晶生长浓度-相场模拟的所有默认参数结构体。
%
% Output:
%   params - Structure containing all simulation parameters
%          - 包含所有模拟参数的结构体
%
% Example:
%   params = config_default();
%   params.k_partition = 0.2;  % Modify as needed
%   run_simulation(params);
%
% See also: run_simulation

    %% Material Parameters | 材料参数

    params.k_partition = 0.15;         % Solute partition coefficient / 溶质分配系数
    params.epsilon_aniso = 0.02;       % Anisotropy strength / 各向异性强度
    params.m_aniso = 6;                % Anisotropy mode (6-fold symmetry) / 各向异性模数（六重对称）
    params.omega0_aniso = 0;           % Preferred growth direction angle (degrees) / 优先生长方向角度（度）
    params.lambda_coup = 10.0;         % Coupling strength parameter / 耦合强度参数
    params.D_coefficient = 6.267;      % Dimensionless diffusion coefficient / 无量纲扩散系数
    params.theta_field = -0.2;         % Dimensionless undercooling / 无量纲过冷度

    %% Numerical Parameters | 数值参数
    % Grid and spatial discretization
    % 网格与空间离散化

    params.Nx = 300;                   % Grid points in x-direction / x方向网格点数
    params.Ny = 300;                   % Grid points in y-direction / y方向网格点数
    params.dx = 0.8;                   % Spatial step size in x / x方向空间步长
    params.dy = 0.8;                   % Spatial step size in y / y方向空间步长
    params.safety_factor = 0.25;       % CFL safety factor for time step / CFL安全系数

    %% Simulation Control | 模拟控制
    % Time stepping and output control
    % 时间步进与输出控制

    params.total_time = 10.0;          % Total simulation time (τ₀) / 总模拟时间（τ₀）
    params.output_interval = 0.5;     % Data output interval (τ₀) / 数据输出间隔（τ₀）

    %% Simulation Options | 模拟选项
    % Feature flags for enabling/disabling functionality
    % 功能开关，用于启用/禁用特定功能

    params.visualization = true;      % Enable real-time visualization / 启用实时可视化
    params.tip_tracking = false;        % Enable tip tracking and dynamics / 启用尖端追踪与动力学分析
    params.velocity_field = 'none';    % Velocity field type / 速度场类型
                                      % Options: 'none', 'uniform', 'shear', 'vortex'
                                      % 选项：'none'（无）, 'uniform'（均匀）, 'shear'（剪切）, 'vortex'（涡旋）

    %% Velocity Field Parameters | 速度场参数
    % Parameters for different velocity field types
    % 不同速度场类型的参数

    params.v_x_magnitude = 2.0;        % x-velocity magnitude (uniform flow) / x方向速度幅度（均匀流）
    params.v_y_magnitude = 0.0;        % y-velocity magnitude (uniform flow) / y方向速度幅度（均匀流）
    params.shear_rate = 0.05;          % Shear rate (shear flow) / 剪切速率（剪切流）
    params.vortex_strength = 1.5;      % Vortex strength (vortex flow) / 涡旋强度（涡旋流）

    %% Numerical Precision | 数值精度
    % Constants for numerical stability and tolerance
    % 数值稳定性和容差常量

    params.eps_numerical = 1e-12;      % Numerical precision constant / 数值精度常量

    %% Boundary Conditions | 边界条件
    % Type of boundary conditions to apply
    % 要应用的边界条件类型

    params.boundary_condition = 'periodic';  % Boundary condition type / 边界条件类型
                                            % Options: 'periodic', 'zero-gradient'
                                            % 选项：'periodic'（周期性）, 'zero-gradient'（零梯度）

    %% Tip Tracking Parameters | 尖端追踪参数
    % Parameters for six-fold symmetric tip detection and tracking
    % 六重对称尖端检测与追踪的参数

    params.six_tip_angles = 0:60:300;  % Target angles for six tips (degrees) / 六个尖端的目标角度（度）
    params.tip_search_radius = 50;     % Maximum search radius for tip detection / 尖端检测最大搜索半径
    params.tip_angle_tolerance = 15;   % Angle tolerance for tip validation (degrees) / 尖端验证角度容差（度）
    params.enable_resampling = true;   % Enable boundary particle resampling for tip tracking / 启用边界粒子重采样以提高尖端追踪精度

    %% Output Options | 输出选项
    % Control what data to save and where
    % 控制保存哪些数据及保存位置

    params.save_fields = true;         % Save phase and concentration fields / 保存相场和浓度场
    params.save_tip_data = true;       % Save tip tracking data / 保存尖端追踪数据
    params.save_probes = true;         % Save probe line data / 保存探针线数据
    params.output_filename = 'simulation_data.mat';  % Output filename / 输出文件名

    %% Video Output Options | 视频输出选项
    % Control video generation from simulation results
    % 控制从模拟结果生成视频

    params.save_video = false;         % Enable video saving / 启用视频保存
    params.video_fps = 10;             % Video frames per second / 视频帧率

end
