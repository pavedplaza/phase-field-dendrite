function equidistant_contour = resample_contour_equidistant(contour_data, target_spacing)
    % 使用弧长参数化实现等距重采样
    % 将不等距的边界轮廓点重新采样为等间距的点集
    %
    % 输入参数:
    %   contour_data - 原始边界轮廓坐标 [x_coords, y_coords]
    %   target_spacing - 目标采样间距（网格单位）
    %
    % 输出参数:
    %   equidistant_contour - 等距重采样后的轮廓坐标 [x_coords, y_coords]
    %
    % 使用方法:
    %   new_contour = resample_contour_equidistant(original_contour, 1.5);
    %
    % 算法说明:
    %   1. 计算原始轮廓的累积弧长
    %   2. 根据目标间距生成等距采样位置
    %   3. 通过线性插值计算新采样点的精确坐标

    % 输入验证
    if nargin < 2
        error('resample_contour_equidistant: 需要两个输入参数：轮廓数据和目标间距');
    end

    % 简单的等距重采样

    if isempty(contour_data) || size(contour_data, 1) < 2
        equidistant_contour = contour_data;
        return;
    end

    if target_spacing <= 0
        error('resample_contour_equidistant: 目标间距必须为正数');
    end

    % 确保轮廓数据格式正确
    if size(contour_data, 2) ~= 2
        error('resample_contour_equidistant: 轮廓数据必须是Nx2格式 [x, y]');
    end

    n_points = size(contour_data, 1);

    % 如果只有两个点，直接返回
    if n_points == 2
        equidistant_contour = contour_data;
        return;
    end

    % 第一步：计算累积弧长
    arc_lengths = zeros(n_points, 1);
    arc_lengths(1) = 0;

    for i = 2:n_points
        segment_length = sqrt(sum((contour_data(i,:) - contour_data(i-1,:)).^2));
        arc_lengths(i) = arc_lengths(i-1) + segment_length;
    end

    total_length = arc_lengths(end);

    % 如果总长度太小，返回原始数据
    if total_length < target_spacing
        equidistant_contour = contour_data;
        return;
    end

    % 第二步：计算目标点数
    target_points = max(3, round(total_length / target_spacing));

    % 第三步：生成等距采样位置
    target_arc_positions = linspace(0, total_length, target_points)';

    % 第四步：插值计算新采样点坐标
    equidistant_contour = zeros(target_points, 2);

    for i = 1:target_points
        target_pos = target_arc_positions(i);

        % 特殊情况：起点
        if target_pos <= 0
            equidistant_contour(i,:) = contour_data(1,:);
            continue;
        end

        % 特殊情况：终点
        if target_pos >= total_length
            equidistant_contour(i,:) = contour_data(end,:);
            continue;
        end

        % 找到目标位置所在的线段
        idx = find(arc_lengths >= target_pos, 1, 'first');

        if idx == 1
            % 第一个线段
            weight = target_pos / arc_lengths(2);
            interpolated_point = (1-weight) * contour_data(1,:) + weight * contour_data(2,:);
        elseif idx > n_points
            % 超出范围，使用最后一个点
            interpolated_point = contour_data(end,:);
        else
            % 正常插值
            prev_arc = arc_lengths(idx-1);
            curr_arc = arc_lengths(idx);

            % 计算插值权重
            weight = (target_pos - prev_arc) / (curr_arc - prev_arc);
            weight = max(0, min(1, weight)); % 确保权重在[0,1]范围内

            % 线性插值
            interpolated_point = (1-weight) * contour_data(idx-1,:) + weight * contour_data(idx,:);
        end

        % 直接使用插值点
        equidistant_contour(i,:) = interpolated_point;
    end

    % 验证结果
    if size(equidistant_contour, 1) < 3
        warning('resample_contour_equidistant: 重采样后点数过少，返回原始数据');
        equidistant_contour = contour_data;
    end
end