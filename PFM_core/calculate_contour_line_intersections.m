function [intersection_points, intersection_info] = calculate_contour_line_intersections(contour_data, line_start, line_end, center_point, eps_tolerance)
% 计算枝晶轮廓与直线的精确交点
% 使用参数方程方法计算直线与轮廓线段的交点，并选择最适合的尖端位置
%
% 输入参数:
%   contour_data - 轮廓坐标数据 [x_coords, y_coords]
%   line_start - 直线起点坐标 [x1, y1]
%   line_end - 直线终点坐标 [x2, y2]
%   center_point - 晶核中心坐标 [cx, cy]
%   eps_tolerance - 数值容差 (可选，默认1e-12)
%
% 输出参数:
%   intersection_points - 交点坐标数组 [x_coords, y_coords]
%   intersection_info - 交点详细信息结构体数组

% 输入验证和默认参数设置
if nargin < 5
    eps_tolerance = 1e-12;
end

% 初始化输出
intersection_points = [];
intersection_info = [];

% 检查输入有效性
if isempty(contour_data) || size(contour_data, 1) < 2
    return;
end

if isempty(line_start) || isempty(line_end) || isempty(center_point)
    return;
end

% 提取直线参数
x1 = line_start(1); y1 = line_start(2);
x2 = line_end(1); y2 = line_end(2);
cx = center_point(1); cy = center_point(2);

% 计算直线方向向量
dx = x2 - x1;
dy = y2 - y1;

% 检查直线是否有效（长度不为零）
line_length_sq = dx^2 + dy^2;
if line_length_sq < eps_tolerance^2
    return;
end

% 将轮廓分解为连续的线段
n_contour_points = size(contour_data, 1);
all_intersections = [];

fprintf('    - 计算轮廓-直线交点: 轮廓点数=%d, 直线=[%.1f,%.1f]-[%.1f,%.1f]\n', ...
        n_contour_points, x1, y1, x2, y2);

% 遍历轮廓的每条线段
for seg_idx = 1:(n_contour_points - 1)
    % 获取当前线段的端点
    x3 = contour_data(seg_idx, 1);
    y3 = contour_data(seg_idx, 2);
    x4 = contour_data(seg_idx + 1, 1);
    y4 = contour_data(seg_idx + 1, 2);

    % 计算线段方向向量
    dx2 = x4 - x3;
    dy2 = y4 - y3;

    % 检查线段是否有效（长度不为零）
    seg_length_sq = dx2^2 + dy2^2;
    if seg_length_sq < eps_tolerance^2
        continue;
    end

    % 使用参数方程方法计算交点
    % 直线1: (x,y) = (x1,y1) + t*(dx,dy), t ∈ [0,1]
    % 直线2: (x,y) = (x3,y3) + s*(dx2,dy2), s ∈ [0,1]

    % 解线性方程组
    denominator = dx * dy2 - dy * dx2;

    % 检查两直线是否平行
    if abs(denominator) < eps_tolerance
        % 两直线平行或重合，检查是否重合
        % 简化处理：跳过平行情况
        continue;
    end

    % 计算参数t和s
    t = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / denominator;
    s = ((x3 - x1) * dy - (y3 - y1) * dx) / denominator;

    % 验证交点是否在两条线段的有效范围内
    % t ∈ [0,1] 表示交点在line_start-line_end线段上
    % s ∈ [0,1] 表示交点在轮廓线段上
    t_in_range = (t >= -eps_tolerance) && (t <= 1 + eps_tolerance);
    s_in_range = (s >= -eps_tolerance) && (s <= 1 + eps_tolerance);

    if t_in_range && s_in_range
        % 计算交点坐标
        intersection_x = x1 + t * dx;
        intersection_y = y1 + t * dy;

        % 计算交点到中心的距离
        dist_to_center = sqrt((intersection_x - cx)^2 + (intersection_y - cy)^2);

        % 计算交点处的方向一致性（与直线方向的夹角）
        line_angle = atan2(dy, dx);
        intersection_angle = atan2(intersection_y - cy, intersection_x - cx);
        angle_deviation = abs(intersection_angle - line_angle);

        % 处理角度环绕
        if angle_deviation > pi
            angle_deviation = 2*pi - angle_deviation;
        end

        % 方向一致性评分（cos函数，值越大越好）
        direction_score = cos(angle_deviation);

        % 存储交点信息
        intersection_struct = struct();
        intersection_struct.x = intersection_x;
        intersection_struct.y = intersection_y;
        intersection_struct.distance = dist_to_center;
        intersection_struct.t = t;
        intersection_struct.s = s;
        intersection_struct.angle_deviation = angle_deviation;
        intersection_struct.direction_score = direction_score;
        intersection_struct.contour_segment = seg_idx;

        all_intersections = [all_intersections; intersection_struct];

        fprintf('      * 找到交点 %d: [%.3f, %.3f], 距离=%.2f, 角度偏差=%.1f°\n', ...
                length(all_intersections), intersection_x, intersection_y, ...
                dist_to_center, rad2deg(angle_deviation));
    end
end

% 如果没有找到交点，返回空结果
if isempty(all_intersections)
    fprintf('    - 未找到有效交点\n');
    return;
end

fprintf('    - 共找到 %d 个交点，进行筛选和排序\n', length(all_intersections));

% 按距离中心的远近排序（从远到近）
distances = [all_intersections.distance];
[~, sort_indices] = sort(distances, 'descend');
all_intersections = all_intersections(sort_indices);

% 应用进一步的筛选条件
valid_intersections = [];
for i = 1:length(all_intersections)
    intersection = all_intersections(i);

    % 筛选条件1：方向一致性（角度偏差不能太大）
    max_angle_deviation = pi / 4;  % 45度
    if intersection.angle_deviation > max_angle_deviation
        fprintf('      * 交点 %d 被过滤: 角度偏差过大 %.1f° > %.1f°\n', ...
                i, rad2deg(intersection.angle_deviation), rad2deg(max_angle_deviation));
        continue;
    end

    % 筛选条件2：距离合理性检查
    max_reasonable_dist = 100;  % 最大合理距离（网格单位）
    if intersection.distance > max_reasonable_dist
        fprintf('      * 交点 %d 被过滤: 距离过大 %.2f > %.2f\n', ...
                i, intersection.distance, max_reasonable_dist);
        continue;
    end

    % 筛选条件3：交点稳定性检查（避免过于接近轮廓端点）
    min_segment_ratio = 0.1;  % 距离线段端点的最小比例
    if intersection.s < min_segment_ratio || intersection.s > (1 - min_segment_ratio)
        fprintf('      * 交点 %d 被过滤: 过于接近轮廓端点 (s=%.3f)\n', ...
                i, intersection.s);
        continue;
    end

    % 通过所有筛选条件
    valid_intersections = [valid_intersections; intersection];
    fprintf('      * 交点 %d 通过筛选: [%.3f, %.3f], 距离=%.2f, 评分=%.3f\n', ...
            length(valid_intersections), intersection.x, intersection.y, ...
            intersection.distance, intersection.direction_score);
end

% 如果没有通过筛选的交点，返回原始交点（放宽筛选条件）
if isempty(valid_intersections)
    fprintf('    - 无交点通过严格筛选，返回最佳原始交点\n');
    valid_intersections = all_intersections(1:min(3, length(all_intersections)));
end

% 输出最终结果
n_final = length(valid_intersections);
intersection_points = zeros(n_final, 2);
intersection_info = valid_intersections;

for i = 1:n_final
    intersection_points(i, :) = [valid_intersections(i).x, valid_intersections(i).y];
end

fprintf('    - 最终返回 %d 个有效交点\n', n_final);

% 可视化辅助信息（用于调试）
if nargout == 2 && ~isempty(valid_intersections)
    fprintf('      * 最佳交点: [%.3f, %.3f], 距离=%.2f, 方向评分=%.3f\n', ...
            valid_intersections(1).x, valid_intersections(1).y, ...
            valid_intersections(1).distance, valid_intersections(1).direction_score);
end

end