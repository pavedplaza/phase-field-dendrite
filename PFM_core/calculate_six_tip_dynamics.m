function [six_tips_dynamics, updated_buffer] = calculate_six_tip_dynamics(six_tips_info, contour_data, tip_history_buffer_6, istep, dtime, cx, cy, dx, dy)
% 六重对称枝晶动力学计算函数
% 计算六个尖端的速率、曲率等动力学参数
%
% 输入参数:
%   six_tips_info - 6×1结构体数组，包含六个尖端的基本信息
%   contour_data - 等值线坐标数据
%   tip_history_buffer_6 - 六尖端历史缓冲区
%   istep - 当前时间步
%   dtime - 时间步长
%   cx, cy - 晶核中心坐标（网格索引）
%   dx, dy - 空间步长
%
% 输出参数:
%   six_tips_dynamics - 6×1结构体数组，包含六个尖端的完整动力学信息
%   updated_buffer - 更新后的历史缓冲区

% 初始化输出
six_tips_dynamics = repmat(struct('id', [], 'position', [], 'distance', [], ...
                              'angle', [], 'target_angle', [], 'angle_deviation', [], ...
                              'is_valid', [], 'velocity', [], 'acceleration', [], ...
                              'curvature', [], 'curvature_radius', [], 'direction_stability', [], ...
                              'growth_rate', [], 'velocity_fit_quality', [], 'velocity_time_window', [], ...
                              'velocity_method', []), 6, 1);
updated_buffer = tip_history_buffer_6;

% 转换中心坐标到实际物理坐标
center_x = cx * dx;
center_y = cy * dy;

fprintf('六尖端动力学计算:\n');

% 对每个尖端进行动力学计算
for tip_id = 1:6
    tip_info = six_tips_info(tip_id);

    % 初始化动力学信息 - 确保所有字段都存在
    if tip_info.is_valid && ~isempty(tip_info.position)
        dynamics = struct('id', tip_id, 'position', tip_info.position, ...
                          'distance', tip_info.distance, 'angle', tip_info.angle, ...
                          'target_angle', tip_info.target_angle, 'angle_deviation', tip_info.angle_deviation, ...
                          'is_valid', tip_info.is_valid, 'velocity', 0, 'acceleration', 0, ...
                          'curvature', 0, 'curvature_radius', Inf, ...
                          'direction_stability', 0, 'growth_rate', 0, ...
                          'velocity_fit_quality', 0, 'velocity_time_window', 0, ...
                          'velocity_method', '');
    else
        dynamics = struct('id', tip_id, 'position', [], ...
                          'distance', 0, 'angle', 0, ...
                          'target_angle', 0, 'angle_deviation', 0, ...
                          'is_valid', false, 'velocity', 0, 'acceleration', 0, ...
                          'curvature', 0, 'curvature_radius', Inf, ...
                          'direction_stability', 0, 'growth_rate', 0, ...
                          'velocity_fit_quality', 0, 'velocity_time_window', 0, ...
                          'velocity_method', '');
    end

    if tip_info.is_valid && ~isempty(tip_info.position)
        % === 瞬时速率计算方法 ===
        velocity = 0;
        acceleration = 0;
        velocity_info = struct();

        if ~isempty(tip_history_buffer_6) && length(tip_history_buffer_6) >= tip_id && ...
           ~isempty(tip_history_buffer_6{tip_id})
            recent_history = tip_history_buffer_6{tip_id};

            % 提取历史数据（兼容性检查）
            history_time = [];
            history_distance = [];
            for i = 1:length(recent_history)
                history_time(i) = recent_history(i).step * dtime;
                history_distance(i) = recent_history(i).distance;
            end

            % 添加当前时间点数据
            current_time = istep * dtime;
            history_time = [history_time, current_time];
            history_distance = [history_distance, tip_info.distance];

            % 使用瞬时速率计算方法
            if length(history_time) >= 3
                [velocity, velocity_info] = calculate_instantaneous_tip_velocity(...
                    history_time, history_distance, current_time, dtime);
            else
                % 数据不足时使用简单差分法
                if length(history_time) >= 2
                    velocity = (history_distance(end) - history_distance(end-1)) / ...
                             (history_time(end) - history_time(end-1));
                end
                velocity_info.method = 'fallback_difference';
                velocity_info.quality = 0;
                velocity_info.time_window = length(history_time);
            end

            % 计算加速度（如果有足够的速度历史）
            if length(recent_history) >= 3
                % 安全提取速度历史
                velocities = [];
                steps = [];
                for i = 1:length(recent_history)
                    if isfield(recent_history(i), 'velocity')
                        velocities = [velocities, recent_history(i).velocity];
                        steps = [steps, recent_history(i).step];
                    end
                end

                if length(velocities) >= 2
                    velocities = [velocities, velocity];  % 添加当前速度
                    steps = [steps, istep];

                    if length(velocities) >= 3
                        time_diff = (steps(end) - steps(end-1)) * dtime;
                        if time_diff > 0
                            acceleration = (velocities(end) - velocities(end-1)) / time_diff;
                        end
                    end
                end
            end

            % 数值稳定性检查
            if isnan(velocity) || isinf(velocity)
                velocity = 0;
                velocity_info.method = 'numerical_fallback';
                velocity_info.error = 'NaN or Inf detected';
            end
        end

        dynamics.velocity = velocity;
        dynamics.acceleration = acceleration;

        % 添加速率计算质量信息
        if ~isempty(velocity_info) && isfield(velocity_info, 'quality')
            dynamics.velocity_fit_quality = velocity_info.quality;
            dynamics.velocity_time_window = velocity_info.time_window;
            dynamics.velocity_method = velocity_info.method;
        else
            dynamics.velocity_fit_quality = 0;
            dynamics.velocity_time_window = 0;
            dynamics.velocity_method = 'unknown';
        end

        % === 修改：使用7点拟合方法计算曲率半径（传递历史缓冲区） ===
        curvature_radius = calculate_tip_curvature_radius_seven_point(contour_data, tip_info.position, dx, dy, updated_buffer, tip_id);
        dynamics.curvature_radius = curvature_radius;

        if curvature_radius > 1e6
            dynamics.curvature = 0;
        else
            dynamics.curvature = 1.0 / curvature_radius;
        end

        % 计算方向稳定性
        direction_stability = cos(tip_info.angle_deviation);
        dynamics.direction_stability = direction_stability;

        % 计算生长速率（垂直于界面）
        growth_rate = velocity * direction_stability;
        dynamics.growth_rate = growth_rate;

        fprintf('  - 尖端 %d: 位置[%.1f, %.1f], 距离%.1f, 速度%.3f, 曲率%.3f\n', ...
                tip_id, tip_info.position(1), tip_info.position(2), ...
                tip_info.distance, velocity, dynamics.curvature);

        % 更新历史缓冲区
        new_entry = struct();
        new_entry.step = istep;
        new_entry.position = tip_info.position;
        new_entry.distance = tip_info.distance;
        new_entry.velocity = velocity;
        new_entry.velocity_fit_quality = dynamics.velocity_fit_quality;
        new_entry.velocity_time_window = dynamics.velocity_time_window;
        new_entry.velocity_method = dynamics.velocity_method;
        new_entry.curvature = dynamics.curvature;
        new_entry.curvature_radius = dynamics.curvature_radius;
        new_entry.angle = tip_info.angle;
        new_entry.angle_deviation = tip_info.angle_deviation;

        if isempty(updated_buffer) || length(updated_buffer) < tip_id
            updated_buffer = cell(6, 1);
            updated_buffer{tip_id} = new_entry;
        else
            updated_buffer{tip_id} = [updated_buffer{tip_id}, new_entry];
        end

        % 限制缓冲区大小
        if length(updated_buffer{tip_id}) > 50
            updated_buffer{tip_id} = updated_buffer{tip_id}(end-49:end);
        end

    else
        % 尖端无效或不存在（所有字段已在初始化时设置）
        fprintf('  - 尖端 %d: 无效或缺失\n', tip_id);
    end

    six_tips_dynamics(tip_id) = dynamics;
end

% 计算整体对称性和一致性指标
valid_dynamics = six_tips_dynamics([six_tips_dynamics.is_valid]);
num_valid = length(valid_dynamics);

if num_valid >= 4
    % 速度对称性
    valid_velocities = [valid_dynamics.velocity];
    mean_velocity = mean(valid_velocities);
    std_velocity = std(valid_velocities);
    velocity_symmetry = 1 - (std_velocity / (abs(mean_velocity) + eps));

    % 距离对称性
    valid_distances = [valid_dynamics.distance];
    mean_distance = mean(valid_distances);
    std_distance = std(valid_distances);
    distance_symmetry = 1 - (std_distance / (mean_distance + eps));

    % 方向对称性
    valid_directions = [valid_dynamics.direction_stability];
    mean_direction = mean(valid_directions);
    direction_symmetry = mean_direction;

    % 综合对称性指标
    overall_symmetry = (velocity_symmetry + distance_symmetry + direction_symmetry) / 3;

    fprintf('  - 对称性分析:\n');
    fprintf('    * 有效尖端数: %d/6\n', num_valid);
    fprintf('    * 速度对称性: %.3f (均值: %.3f, 标准差: %.3f)\n', ...
            velocity_symmetry, mean_velocity, std_velocity);
    fprintf('    * 距离对称性: %.3f (均值: %.1f, 标准差: %.1f)\n', ...
            distance_symmetry, mean_distance, std_distance);
    fprintf('    * 方向对称性: %.3f\n', direction_symmetry);
    fprintf('    * 综合对称性: %.3f\n', overall_symmetry);

    % 将对称性信息添加到每个尖端
    for tip_id = 1:6
        if six_tips_dynamics(tip_id).is_valid
            six_tips_dynamics(tip_id).velocity_symmetry = velocity_symmetry;
            six_tips_dynamics(tip_id).distance_symmetry = distance_symmetry;
            six_tips_dynamics(tip_id).direction_symmetry = direction_symmetry;
            six_tips_dynamics(tip_id).overall_symmetry = overall_symmetry;
            six_tips_dynamics(tip_id).velocity_deviation = ...
                six_tips_dynamics(tip_id).velocity - mean_velocity;
            six_tips_dynamics(tip_id).distance_deviation = ...
                six_tips_dynamics(tip_id).distance - mean_distance;
        end
    end
else
    fprintf('  - 有效尖端数不足 (%d/6)，跳过对称性分析\n', num_valid);
end

end

%% 辅助函数：使用7点拟合法计算尖端曲率半径
function curvature_radius = calculate_tip_curvature_radius_seven_point(contour_data, tip_position, dx, dy, updated_buffer, tip_id)
    % 使用七点二次拟合法计算尖端曲率半径
    %
    % 输入参数:
    %   contour_data - 界面轮廓坐标 [x_coords, y_coords]
    %   tip_position - 尖端位置 [x, y]
    %   dx, dy - 空间步长
    %
    % 输出参数:
    %   curvature_radius - 尖端处曲率半径（网格单位）

    curvature_radius = [];
    window_size = 7;  % 使用7个点进行拟合

    if isempty(contour_data) || size(contour_data, 1) < 3
        curvature_radius = 0;
        return;
    end

    % 找到距离尖端最近的轮廓点作为基准点
    distances_to_tip = sqrt(sum((contour_data - tip_position).^2, 2));
    [~, tip_idx] = min(distances_to_tip);

    n_points = size(contour_data, 1);

    % 确定拟合窗口
    half_window = floor(window_size/2);
    start_idx = max(1, tip_idx - half_window);
    end_idx = min(n_points, tip_idx + half_window);

    % 提取窗口内的点
    window_points = contour_data(start_idx:end_idx, :);
    n_fit_points = size(window_points, 1);

    if n_fit_points < 3
        curvature_radius = 0;
        return;
    end

    % === v7标准方法：参数化拟合 ===
    % 将曲线参数化为 t ∈ [0,1]
    arc_lengths = zeros(n_fit_points, 1);
    for i = 2:n_fit_points
        arc_lengths(i) = arc_lengths(i-1) + sqrt(sum((window_points(i,:) - window_points(i-1,:)).^2));
    end

    % 归一化参数
    if arc_lengths(end) < 1e-10
        curvature_radius = 0;
        return;
    end

    t = arc_lengths / arc_lengths(end);

    % 对x(t)和y(t)分别进行二次多项式拟合
    px = polyfit(t, window_points(:, 1), 2);
    py = polyfit(t, window_points(:, 2), 2);

    % 计算尖端处的曲率（对应t=0.5）
    t_tip = 0.5;

    % 一阶导数
    dx_dt = polyval(polyder(px), t_tip);
    dy_dt = polyval(polyder(py), t_tip);

    % 二阶导数
    d2x_dt2 = polyval(polyder(polyder(px)), t_tip);
    d2y_dt2 = polyval(polyder(polyder(py)), t_tip);

    % 计算曲率 κ = |x'y'' - y'x''| / (x'^2 + y'^2)^(3/2)
    numerator = abs(dx_dt * d2y_dt2 - dy_dt * d2x_dt2);
    denominator = (dx_dt^2 + dy_dt^2)^(3/2);

    if denominator < 1e-10
        curvature_radius = 1e6;  % 近似直线
    else
        curvature = numerator / denominator;
        curvature_radius = 1 / curvature;
    end

    % === 使用前一个值替代硬编码1000限制 ===
    if curvature_radius > 1000.0
        % 使用前一个有效值
        if ~isempty(updated_buffer) && length(updated_buffer) >= tip_id && ...
           ~isempty(updated_buffer{tip_id}) && length(updated_buffer{tip_id}) >= 1
            prev_entry = updated_buffer{tip_id}(end);
            if isfield(prev_entry, 'curvature_radius') && isfinite(prev_entry.curvature_radius)
                curvature_radius = prev_entry.curvature_radius;
            else
                curvature_radius = 500.0;  % 回退到合理中值
            end
        else
            curvature_radius = 500.0;  % 第一个时间步的回退值
        end
    else
        curvature_radius = max(1.0, curvature_radius);
    end

end