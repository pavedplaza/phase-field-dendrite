function [velocity, velocity_info] = calculate_instantaneous_tip_velocity(time_history, distance_history, current_time, dtime)
% 基于位移-时间曲线拟合的瞬时速率计算函数
% 使用多项式拟合求导法计算瞬时速率，提供拟合质量评估
%
% 输入参数:
%   time_history - 时间历史数组
%   distance_history - 距离历史数组
%   current_time - 当前时间
%   dtime - 时间步长
%
% 输出参数:
%   velocity - 计算得到的瞬时速率
%   velocity_info - 包含拟合质量等详细信息结构体

% 初始化输出
velocity = 0;
velocity_info = struct();

% 输入验证和预处理
if nargin < 4
    dtime = 1.0;  % 默认时间步长
end

if isempty(time_history) || isempty(distance_history) || length(time_history) ~= length(distance_history)
    velocity_info.method = 'none';
    velocity_info.quality = 0;
    velocity_info.time_window = 0;
    velocity_info.error = 'Invalid input data';
    return;
end

% 移除无效数据点
valid_mask = ~isnan(time_history) & ~isnan(distance_history) & ...
             isfinite(time_history) & isfinite(distance_history) & ...
             time_history > 0 & distance_history >= 0;

time_points = time_history(valid_mask);
distance_points = distance_history(valid_mask);

if length(time_points) < 2
    velocity_info.method = 'none';
    velocity_info.quality = 0;
    velocity_info.time_window = 0;
    velocity_info.error = 'Insufficient valid data points';
    return;
end

% 自适应选择时间窗口
min_points = 3;
max_points = 15;
optimal_points = min(max_points, length(time_points));

if length(time_points) >= optimal_points
    % 使用最近的optimal_points个点
    time_points = time_points(end-optimal_points+1:end);
    distance_points = distance_points(end-optimal_points+1:end);
end

time_window = length(time_points);

% 异常值检测和移除
if time_window >= 5
    % 使用稳健统计方法检测异常值
    z_scores = abs(distance_points - median(distance_points)) / mad(distance_points, 1);
    outlier_threshold = 3.0;
    outlier_mask = z_scores <= outlier_threshold;

    if sum(outlier_mask) >= 3
        time_points = time_points(outlier_mask);
        distance_points = distance_points(outlier_mask);
        time_window = length(time_points);
    end
end

% 数据中心化以提高数值稳定性
time_mean = mean(time_points);
time_centered = time_points - time_mean;
distance_mean = mean(distance_points);
distance_centered = distance_points - distance_mean;

% 自动选择最佳拟合阶数
best_degree = 1;
best_r2 = -1;
best_fit_quality = 0;

% 尝试1-3阶多项式拟合
max_degree = min(3, time_window - 1);
for degree = 1:max_degree
    try
        % 多项式拟合
        p = polyfit(time_centered, distance_centered, degree);

        % 计算拟合值
        fitted_values = polyval(p, time_centered);

        % 计算R²（决定系数）
        ss_res = sum((distance_centered - fitted_values).^2);
        ss_tot = sum((distance_centered - mean(distance_centered)).^2);

        if ss_tot > 1e-10
            r2 = 1 - (ss_res / ss_tot);
        else
            r2 = 0;
        end

        % 考虑拟合质量的综合评分
        fit_quality = r2 * (1 - 0.1 * (degree - 1));  % 略微偏向低阶拟合

        if fit_quality > best_fit_quality && r2 > 0.5
            best_fit_quality = fit_quality;
            best_r2 = r2;
            best_degree = degree;
        end

    catch ME
        % 拟合失败，跳过当前阶数
        continue;
    end
end

% 使用最佳拟合阶数进行最终计算
try
    p = polyfit(time_centered, distance_centered, best_degree);

    % 计算当前时间点的中心化坐标
    current_time_centered = current_time - time_mean;

    % 计算瞬时速率（多项式导数）
    if best_degree == 1
        % 线性拟合: f(t) = at + b, f'(t) = a
        velocity = p(1);
    elseif best_degree == 2
        % 二次拟合: f(t) = at² + bt + c, f'(t) = 2at + b
        velocity = 2 * p(1) * current_time_centered + p(2);
    elseif best_degree == 3
        % 三次拟合: f(t) = at³ + bt² + ct + d, f'(t) = 3at² + 2bt + c
        velocity = 3 * p(1) * current_time_centered^2 + 2 * p(2) * current_time_centered + p(3);
    else
        velocity = 0;
    end

    % 计算拟合值用于验证
    fitted_values = polyval(p, time_centered);

    % 计算拟合误差
    fit_errors = abs(distance_centered - fitted_values);
    max_error = max(fit_errors);
    mean_error = mean(fit_errors);

    % 填充返回信息结构体
    velocity_info.method = 'polynomial_fit';
    velocity_info.degree = best_degree;
    velocity_info.r2 = best_r2;
    velocity_info.quality = best_fit_quality;
    velocity_info.time_window = time_window;
    velocity_info.max_error = max_error;
    velocity_info.mean_error = mean_error;
    velocity_info.time_mean = time_mean;
    velocity_info.distance_mean = distance_mean;
    velocity_info.coefficients = p;
    velocity_info.error = '';

    % 数值稳定性检查
    if isnan(velocity) || isinf(velocity)
        velocity = 0;
        velocity_info.method = 'fallback';
        velocity_info.error = 'Numerical instability detected';
    end

    % 合理性检查 - 使用前一个值替代硬编码限制
    max_reasonable_velocity = 100.0;  % 最大合理速率（网格单位/时间单位）
    if abs(velocity) > max_reasonable_velocity
        % 尝试使用前一个有效值
        prev_velocity = 0;  % 默认回退值

        % 从历史距离数据计算前一个时间步的速度
        if length(distance_points) >= 2 && length(time_points) >= 2
            % 使用最邻近的两个点计算前一个速度
            prev_velocity = (distance_points(end) - distance_points(end-1)) / ...
                           (time_points(end) - time_points(end-1));
        end

        % 如果前一个值合理则使用，否则使用限制值
        if abs(prev_velocity) <= max_reasonable_velocity && isfinite(prev_velocity)
            velocity = prev_velocity;
            velocity_info.error = 'Velocity replaced with previous reasonable value';
        else
            velocity = max_reasonable_velocity * sign(velocity);
            velocity_info.error = 'Velocity limited to reasonable range (previous value also unreasonable)';
        end
    end

catch ME
%     % 拟合失败，回退到简单差分法
%     if time_window >= 2
%         velocity = (distance_points(end) - distance_points(end-1)) / ...
%                   (time_points(end) - time_points(end-1));
%     else
%         velocity = 0;
%     end
% 
%     velocity_info.method = 'fallback_difference';
%     velocity_info.quality = 0;
%     velocity_info.time_window = time_window;
%     velocity_info.error = sprintf('Fit failed: %s', ME.message);
% end

% 输出调试信息
if nargout == 2
    fprintf('    - 瞬时速率计算: 使用%d个数据点, %d阶拟合, R²=%.3f, 速率=%.4f\n', ...
            time_window, best_degree, best_r2, velocity);
end

end