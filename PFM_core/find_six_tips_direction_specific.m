function six_tips_info = find_six_tips_direction_specific(contour_data, cx, cy, dx, dy, tip_history_buffer_6, six_tip_angles)
% 六重对称枝晶尖端检测函数（几何交点方法）
% 基于六个优先生长方向，通过计算轮廓与直线的交点来检测尖端
%
% 输入参数:
%   contour_data - 等值线坐标数据 [x_coords, y_coords]
%   cx, cy - 晶核中心坐标（网格索引）
%   dx, dy - 空间步长
%   tip_history_buffer_6 - 六尖端历史缓冲区
%   six_tip_angles - 六个优先生长方向角度（弧度）
%
% 输出参数:
%   six_tips_info - 6×1结构体数组，每个元素包含一个尖端的信息

% 获取计算域大小（用于计算最大可能距离）
Nx = 300;  % 假设计算域大小
Ny = 300;

% 输入验证
if isempty(contour_data) || size(contour_data, 1) < 3
    six_tips_info = [];
    return;
end

% 转换中心坐标到实际物理坐标
center_x = cx * dx;
center_y = cy * dy;

% 初始化输出
six_tips_info = repmat(struct('id', [], 'position', [], 'distance', [], ...
                           'angle', [], 'target_angle', [], 'angle_deviation', [], ...
                           'direction_score', [], 'total_score', [], ...
                           'is_valid', false, 'detection_method', []), 6, 1);

% === 边界有效性检查 ===
% 筛选有效的等值线点，排除边界异常点
valid_points = true(size(contour_data, 1), 1);
max_reasonable_dist = 3 * max(dx, dy);  % 最大合理距离

for i = 1:size(contour_data, 1)
    dist = sqrt(sum((contour_data(i,:) - [center_x, center_y]).^2));

    % 检查距离是否合理
    if dist > max_reasonable_dist
        % 检查是否接近边界
        if contour_data(i, 1) < 2*dx || contour_data(i, 1) > (Nx-2)*dx || ...
           contour_data(i, 2) < 2*dy || contour_data(i, 2) > (Ny-2)*dy
            valid_points(i) = false;
        end
    end
end

% 应用有效性过滤
contour_data = contour_data(valid_points, :);

if isempty(contour_data) || size(contour_data, 1) < 3
    six_tips_info = [];
    return;
end

% 对每个轮廓点计算相对于中心的角度和距离
contour_x = contour_data(:, 1);
contour_y = contour_data(:, 2);

% 计算相对位置
relative_x = contour_x - center_x;
relative_y = contour_y - center_y;

% 计算角度和距离
angles = atan2(relative_y, relative_x);  % 范围：[-π, π]
distances = sqrt(relative_x.^2 + relative_y.^2);

% 处理角度范围，确保在[0, 2π]范围内
angles(angles < 0) = angles(angles < 0) + 2*pi;

fprintf('六尖端检测分析:\n');

% 对每个扇区进行处理
for tip_id = 1:6
    target_angle = six_tip_angles(tip_id);

    % === 新增：基于几何交点方法的尖端检测 ===
    fprintf('  - 扇区 %d (目标角度 %.0f°): 开始几何交点检测\n', tip_id, rad2deg(target_angle));

    % 构造当前方向的直线（从中心向外延伸足够距离）
    line_length = max(Nx * dx, Ny * dy) * 2;  % 直线长度
    line_start = [center_x, center_y];
    line_end = [center_x + line_length * cos(target_angle), ...
                center_y + line_length * sin(target_angle)];

    % 计算轮廓与直线的交点
    [intersection_points, intersection_info] = calculate_contour_line_intersections(...
        contour_data, line_start, line_end, [center_x, center_y], 1e-8);

    % 几何交点方法的结果
    geometry_candidate_tip = [];
    geometry_distance = 0;
    geometry_angle = 0;
    geometry_angle_diff = pi;
    geometry_score = 0;
    geometry_is_valid = false;

    if ~isempty(intersection_points)
        % 选择最佳交点（距离最远且方向一致性最好的）
        best_intersection = intersection_info(1);  % 已按距离排序
        geometry_candidate_tip = [best_intersection.x, best_intersection.y];
        geometry_distance = best_intersection.distance;

        % 计算几何候选点的角度
        geometry_relative = geometry_candidate_tip - [center_x, center_y];
        geometry_angle = atan2(geometry_relative(2), geometry_relative(1));
        if geometry_angle < 0
            geometry_angle = geometry_angle + 2*pi;
        end

        % 计算角度偏差
        geometry_angle_diff = abs(geometry_angle - target_angle);
        if geometry_angle_diff > pi
            geometry_angle_diff = 2*pi - geometry_angle_diff;
        end

        % 几何方法的评分（主要基于方向一致性和距离）
        geometry_direction_score = best_intersection.direction_score;
        max_possible_distance = min(Nx * dx, Ny * dy) / 2;
        geometry_distance_score = geometry_distance / max_possible_distance;
        geometry_score = 0.6 * geometry_distance_score + 0.4 * geometry_direction_score;
        geometry_is_valid = geometry_score > 0.2 && geometry_angle_diff < pi/3;  % 较宽松的有效性阈值

        fprintf('    * 几何方法: 找到交点 [%.1f, %.1f], 距离 %.1f, 角度偏差 %.1f°, 评分 %.2f\n', ...
                geometry_candidate_tip(1), geometry_candidate_tip(2), geometry_distance, ...
                rad2deg(geometry_angle_diff), geometry_score);
    else
        fprintf('    * 几何方法: 未找到有效交点\n');
    end

    % === 仅使用几何交点方法的结果 ===
    final_candidate_tip = [];
    final_distance = 0;
    final_angle = 0;
    final_angle_diff = pi;
    final_direction_score = 0;
    final_total_score = 0;
    final_is_valid = false;
    detection_method = 'none';

    if geometry_is_valid && ~isempty(geometry_candidate_tip)
        % 使用几何交点方法的结果
        final_candidate_tip = geometry_candidate_tip;
        final_distance = geometry_distance;
        final_angle = geometry_angle;
        final_angle_diff = geometry_angle_diff;
        final_direction_score = cos(geometry_angle_diff);
        final_total_score = geometry_score;
        final_is_valid = true;
        detection_method = 'geometry';

        fprintf('    * 最终选择: 几何交点方法结果\n');
    else
        % 几何方法无效
        fprintf('    * 最终选择: 无有效检测结果\n');
    end

    % 基于历史数据的趋势评分（如果找到有效尖端）
    trend_score = 0;
    if final_is_valid && ~isempty(tip_history_buffer_6) && length(tip_history_buffer_6) >= tip_id && ...
       ~isempty(tip_history_buffer_6(tip_id))
        recent_history = tip_history_buffer_6(tip_id);
        if length(recent_history) >= 2
            prev_distance = recent_history(end).distance;
            if final_distance > prev_distance * 0.8  % 生长趋势检查
                trend_score = 1.0;
            elseif final_distance > prev_distance * 0.6
                trend_score = 0.5;
            end
        end
    end

    % 最终评分调整
    final_total_score = final_total_score + 0.2 * trend_score;

    % 创建尖端信息结构体
    tip_info = struct();
    tip_info.id = tip_id;
    tip_info.position = final_candidate_tip;
    tip_info.distance = final_distance;
    tip_info.angle = final_angle;
    tip_info.target_angle = target_angle;
    tip_info.angle_deviation = final_angle_diff;
    tip_info.direction_score = final_direction_score;
    tip_info.total_score = final_total_score;
    tip_info.is_valid = final_is_valid;
    tip_info.detection_method = detection_method;

    six_tips_info(tip_id) = tip_info;

    % 输出最终结果
    if final_is_valid
        fprintf('  - 尖端 %d (目标角度 %.0f°): 检测结果 [%.1f, %.1f], 距离 %.1f, 角度偏差 %.1f°, 评分 %.2f (%s)\n', ...
                tip_id, rad2deg(target_angle), final_candidate_tip(1), final_candidate_tip(2), ...
                final_distance, rad2deg(final_angle_diff), final_total_score, detection_method);
    else
        fprintf('  - 尖端 %d (目标角度 %.0f°): 无有效检测结果\n', tip_id, rad2deg(target_angle));
    end
end

% 验证六个尖端的对称性和一致性
valid_tips = zeros(1, 6);
for tip_id = 1:6
    if isfield(six_tips_info(tip_id), 'is_valid')
        valid_tips(tip_id) = six_tips_info(tip_id).is_valid;
    end
end
num_valid_tips = sum(valid_tips);

if num_valid_tips >= 4  % 至少需要4个有效尖端进行对称性分析
    fprintf('  - 有效尖端数: %d/6\n', num_valid_tips);

    % 计算对称性指标
    valid_distances = [];
    for tip_id = 1:6
        if valid_tips(tip_id) && isfield(six_tips_info(tip_id), 'distance')
            valid_distances = [valid_distances, six_tips_info(tip_id).distance];
        end
    end
    if ~isempty(valid_distances)
        mean_distance = mean(valid_distances);
        std_distance = std(valid_distances);
        symmetry_ratio = 1 - (std_distance / (mean_distance + eps));
    else
        mean_distance = 0;
        std_distance = 0;
        symmetry_ratio = 0;
    end

    fprintf('  - 对称性指标: %.3f (平均值: %.1f, 标准差: %.1f)\n', ...
            symmetry_ratio, mean_distance, std_distance);

    % 将对称性信息添加到每个尖端
    for tip_id = 1:6
        if isfield(six_tips_info(tip_id), 'is_valid') && six_tips_info(tip_id).is_valid
            if isfield(six_tips_info(tip_id), 'distance')
                six_tips_info(tip_id).symmetry_ratio = symmetry_ratio;
                six_tips_info(tip_id).distance_deviation = ...
                    six_tips_info(tip_id).distance - mean_distance;
            end
        end
    end
else
    fprintf('  - 有效尖端数不足 (%d/6)，跳过对称性分析\n', num_valid_tips);
end

end