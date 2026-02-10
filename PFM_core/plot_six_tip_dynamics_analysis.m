function plot_six_tip_dynamics_analysis(time_history, tip_position_history_6, tip_distance_history_6, tip_velocity_history_6, tip_curvature_history_6, nprint)
% 六重对称枝晶尖端动力学分析可视化函数
% 生成六个尖端的对比分析图表
%
% 输入参数:
%   time_history - 时间历史数组
%   tip_position_history_6 - 六尖端位置历史 [时间, 尖端ID, 坐标(x,y)]
%   tip_distance_history_6 - 六尖端距离历史 [时间, 尖端ID]
%   tip_velocity_history_6 - 六尖端速度历史 [时间, 尖端ID]
%   tip_curvature_history_6 - 六尖端曲率历史 [时间, 尖端ID]
%   nprint - 输出间隔

if exist('figure', 'builtin')
    figure('Position', [100, 100, 1600, 1000]);

    % 设置颜色方案
    colors = lines(6);
    markers = {'o', 's', '^', 'd', 'v', '>'};
    tip_labels = {'尖端1 (0°)', '尖端2 (60°)', '尖端3 (120°)', '尖端4 (180°)', '尖端5 (240°)', '尖端6 (300°)'};

    % 获取有效的时间步
    valid_time_steps = time_history > 0;
    valid_times = time_history(valid_time_steps);

    if length(valid_times) < 2
        fprintf('数据不足，无法生成六尖端分析图\n');
        return;
    end

    fprintf('生成六尖端动力学分析图...\n');

    % 子图1：距离演化对比
    subplot(2, 3, 1);
    hold on;
    for tip_id = 1:6
        valid_distances = tip_distance_history_6(valid_time_steps, tip_id);
        valid_mask = valid_distances > 0;

        if sum(valid_mask) > 0
            plot(valid_times(valid_mask), valid_distances(valid_mask), ...
                 'Color', colors(tip_id, :), 'LineWidth', 1.2, 'DisplayName', tip_labels{tip_id});
        end
    end
    xlabel('时间');
    ylabel('尖端到中心距离');
    title('六尖端距离演化对比');
    legend('Location', 'best');
    grid on;

    % 子图2：速度演化对比
    subplot(2, 3, 2);
    hold on;
    for tip_id = 1:6
        valid_velocities = tip_velocity_history_6(valid_time_steps, tip_id);
        valid_mask = abs(valid_velocities) > 1e-6;

        if sum(valid_mask) > 0
            plot(valid_times(valid_mask), valid_velocities(valid_mask), ...
                 'Color', colors(tip_id, :), 'LineWidth', 1.2, 'DisplayName', tip_labels{tip_id});
        end
    end
    xlabel('时间');
    ylabel('尖端生长速度');
    title('六尖端速度演化对比');
    legend('Location', 'best');
    grid on;

    % 子图3：曲率半径演化对比
    subplot(2, 3, 3);
    hold on;
    for tip_id = 1:6
        valid_curvatures = tip_curvature_history_6(valid_time_steps, tip_id);
        valid_mask = isfinite(valid_curvatures) & valid_curvatures > 0 & valid_curvatures < 100;

        if sum(valid_mask) > 0
            plot(valid_times(valid_mask), valid_curvatures(valid_mask), ...
                 'Color', colors(tip_id, :), 'LineWidth', 1.2, 'DisplayName', tip_labels{tip_id});
        end
    end
    xlabel('时间');
    ylabel('尖端曲率半径');
    title('六尖端曲率半径演化对比');
    legend('Location', 'best');
    grid on;

    % 子图4：距离对称性分析
    subplot(2, 3, 4);
    if size(tip_distance_history_6, 1) > 1
        % 计算每个时间步的距离统计
        mean_distances = zeros(size(valid_times));
        std_distances = zeros(size(valid_times));

        for t = 1:length(valid_times)
            distances_at_time = tip_distance_history_6(valid_time_steps, :);
            valid_mask = distances_at_time(t, :) > 0;

            if sum(valid_mask) >= 4
                mean_distances(t) = mean(distances_at_time(t, valid_mask));
                std_distances(t) = std(distances_at_time(t, valid_mask));
            end
        end

        valid_mask = mean_distances > 0;
        if sum(valid_mask) > 0
            yyaxis left;
            plot(valid_times(valid_mask), mean_distances(valid_mask), 'b-', 'LineWidth', 2);
            ylabel('平均距离', 'Color', 'b');

            yyaxis right;
            plot(valid_times(valid_mask), std_distances(valid_mask), 'r-', 'LineWidth', 2);
            ylabel('距离标准差', 'Color', 'r');

            xlabel('时间');
            title('距离对称性分析');
            grid on;
        end
    end

    % 子图5：速度对称性分析
    subplot(2, 3, 5);
    if size(tip_velocity_history_6, 1) > 1
        % 计算每个时间步的速度统计
        mean_velocities = zeros(size(valid_times));
        std_velocities = zeros(size(valid_times));

        for t = 1:length(valid_times)
            velocities_at_time = tip_velocity_history_6(valid_time_steps, :);
            valid_mask = abs(velocities_at_time(t, :)) > 1e-6;

            if sum(valid_mask) >= 4
                mean_velocities(t) = mean(velocities_at_time(t, valid_mask));
                std_velocities(t) = std(velocities_at_time(t, valid_mask));
            end
        end

        valid_mask = abs(mean_velocities) > 1e-6;
        if sum(valid_mask) > 0
            yyaxis left;
            plot(valid_times(valid_mask), mean_velocities(valid_mask), 'b-', 'LineWidth', 2);
            ylabel('平均速度', 'Color', 'b');

            yyaxis right;
            plot(valid_times(valid_mask), std_velocities(valid_mask), 'r-', 'LineWidth', 2);
            ylabel('速度标准差', 'Color', 'r');

            xlabel('时间');
            title('速度对称性分析');
            grid on;
        end
    end

    % 子图6：六尖端轨迹对比
    subplot(2, 3, 6);
    hold on;
    for tip_id = 1:6
        valid_positions = tip_position_history_6(valid_time_steps, tip_id, :);
        % 检查是否有有效的位置数据
        valid_x = valid_positions(:, 1);
        valid_y = valid_positions(:, 2);
        valid_mask = (valid_x > 0) & (valid_y > 0);

        if sum(valid_mask) > 1
            % 绘制轨迹（只显示连线，去掉点标记）
            plot(valid_x(valid_mask), valid_y(valid_mask), ...
                 'Color', colors(tip_id, :), 'LineWidth', 1.2, 'DisplayName', tip_labels{tip_id});

            % 标记起点和终点
            if sum(valid_mask) >= 1
                start_idx = find(valid_mask, 1, 'first');
                end_idx = find(valid_mask, 1, 'last');

                plot(valid_x(start_idx), valid_y(start_idx), ...
                     'ko', 'MarkerSize', 8, 'MarkerFaceColor', colors(tip_id, :));
                plot(valid_x(end_idx), valid_y(end_idx), ...
                     'ks', 'MarkerSize', 8, 'MarkerFaceColor', colors(tip_id, :));
            end
        end
    end

    % 添加中心点
    center_x = 150 * 0.8;  % 假设中心在(150, 150)，dx = 0.8
    center_y = 150 * 0.8;
    plot(center_x, center_y, 'k+', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', '中心');

    xlabel('X坐标');
    ylabel('Y坐标');
    title('六尖端轨迹对比');
    axis equal;
    legend('Location', 'best');
    grid on;

    % 总标题
    sgtitle('六重对称枝晶尖端动力学分析', 'FontSize', 16, 'FontWeight', 'bold');

    % 保存图像
    saveas(gcf, 'six_tip_dynamics_analysis.png');
    fprintf('六尖端动力学分析图已保存: six_tip_dynamics_analysis.png\n');

    drawnow;

    % 生成数值统计报告
    generate_six_tip_statistics_report(valid_times, tip_distance_history_6(valid_time_steps, :), ...
                                     tip_velocity_history_6(valid_time_steps, :), tip_labels);
end

function generate_six_tip_statistics_report(times, distances, velocities, tip_labels)
% 生成六尖端数值统计报告

fprintf('\n=== 六重对称枝晶尖端统计报告 ===\n');

% 距离统计
fprintf('\n距离统计 (最终状态):\n');
for tip_id = 1:6
    final_distance = distances(end, tip_id);
    if final_distance > 0
        fprintf('  %s: %.2f\n', tip_labels{tip_id}, final_distance);
    else
        fprintf('  %s: 未检测到\n', tip_labels{tip_id});
    end
end

valid_distances = distances(end, :);
valid_mask = valid_distances > 0;
if sum(valid_mask) >= 4
    mean_dist = mean(valid_distances(valid_mask));
    std_dist = std(valid_distances(valid_mask));
    cv_dist = std_dist / mean_dist;  % 变异系数

    fprintf('  平均距离: %.2f\n', mean_dist);
    fprintf('  标准差: %.2f\n', std_dist);
    fprintf('  变异系数: %.3f\n', cv_dist);
    fprintf('  对称性指标: %.3f\n', 1 - cv_dist);
end

% 速度统计
fprintf('\n速度统计 (平均):\n');
for tip_id = 1:6
    tip_velocities = velocities(:, tip_id);
    valid_mask = abs(tip_velocities) > 1e-6;

    if sum(valid_mask) > 0
        avg_velocity = mean(tip_velocities(valid_mask));
        fprintf('  %s: %.4f\n', tip_labels{tip_id}, avg_velocity);
    else
        fprintf('  %s: 未检测到有效速度\n', tip_labels{tip_id});
    end
end

% 计算整体速度统计
all_valid_velocities = [];
for tip_id = 1:6
    tip_velocities = velocities(:, tip_id);
    valid_mask = abs(tip_velocities) > 1e-6;
    all_valid_velocities = [all_valid_velocities; tip_velocities(valid_mask)];
end

if length(all_valid_velocities) >= 4
    mean_vel = mean(all_valid_velocities);
    std_vel = std(all_valid_velocities);
    cv_vel = std_vel / abs(mean_vel);

    fprintf('  平均速度: %.4f\n', mean_vel);
    fprintf('  标准差: %.4f\n', std_vel);
    fprintf('  变异系数: %.3f\n', cv_vel);
    fprintf('  速度对称性: %.3f\n', 1 - cv_vel);
end

fprintf('\n=====================================\n');

end  % generate_six_tip_statistics_report 函数结束


end  % plot_six_tip_dynamics_analysis 函数结束