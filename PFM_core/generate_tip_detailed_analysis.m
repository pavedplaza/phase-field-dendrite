function generate_tip_detailed_analysis(times, velocities, curvatures, tip_id)
% 生成指定尖端的专项分析图表
%
% 输入参数:
%   times - 时间数组
%   velocities - 速率数组
%   curvatures - 曲率半径数组
%   tip_id - 尖端编号 (1-6)
%
% 颜色方案:
%   尖端1: 速率蓝色, 曲率红色
%   尖端2: 速率红色, 曲率绿色
%   尖端3: 速率绿色, 曲率品红色
%   尖端4: 速率蓝色, 曲率红色
%   尖端5: 速率品红色, 曲率青色
%   尖端6: 速率青色, 曲率黑色

% 输入验证
if nargin < 4
    error('generate_tip_detailed_analysis: 需要4个输入参数 (times, velocities, curvatures, tip_id)');
end

if tip_id < 1 || tip_id > 6
    error('generate_tip_detailed_analysis: tip_id 必须在 1-6 范围内');
end

if isempty(times) || isempty(velocities) || isempty(curvatures)
    fprintf('尖端%d数据不足，跳过专项分析\n', tip_id);
    return;
end

% 定义颜色方案
color_schemes = struct(...
    'velocity_color', {{'b-', 'r-', 'g-', 'b-', 'm-', 'c-'}}, ...
    'curvature_color', {{'r-', 'g-', 'm-', 'r-', 'c-', 'k-'}});

velocity_color = color_schemes.velocity_color{tip_id};
curvature_color = color_schemes.curvature_color{tip_id};

% 创建独立figure窗口
figure('Position', [100, 100, 800, 800]);
set(gcf, 'Name', sprintf('尖端%d专项分析 - 速率与曲率半径', tip_id), 'NumberTitle', 'off');

% 子图1：速率-时间曲线
subplot(2, 1, 1);
plot(times, velocities, velocity_color, 'LineWidth', 1.5);
xlabel('时间步', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('速率 (网格单位/时间步)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('尖端%d 速率随时间变化', tip_id), 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% 添加统计信息
valid_vel = velocities(~isnan(velocities) & isfinite(velocities));
if ~isempty(valid_vel)
    mean_vel = mean(valid_vel);
    std_vel = std(valid_vel);
    text(0.05, 0.95, sprintf('均值: %.3f\n标准差: %.3f', mean_vel, std_vel), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');
end

% 子图2：曲率半径-时间曲线
subplot(2, 1, 2);
plot(times, curvatures, curvature_color, 'LineWidth', 1.5);
xlabel('时间步', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('曲率半径 (网格单位)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('尖端%d 曲率半径随时间变化', tip_id), 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10);

% 添加统计信息
valid_curv = curvatures(~isnan(curvatures) & isfinite(curvatures));
if ~isempty(valid_curv)
    mean_curv = mean(valid_curv);
    std_curv = std(valid_curv);
    text(0.05, 0.95, sprintf('均值: %.3f\n标准差: %.3f', mean_curv, std_curv), ...
         'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');
end

% 添加整体标题
sgtitle(sprintf('尖端%d 专项动力学分析', tip_id), 'FontSize', 16, 'FontWeight', 'bold');

% 保存图像
try
    filename = sprintf('tip%d_detailed_analysis.png', tip_id);
    saveas(gcf, filename);
    fprintf('尖端%d专项分析图表已保存为 %s\n', tip_id, filename);
catch ME
    fprintf('保存尖端%d分析图表失败: %s\n', tip_id, ME.message);
end

% 输出关键数据到控制台
fprintf('\n=== 尖端%d专项分析 ===\n', tip_id);
fprintf('时间范围: %d - %d 步\n', min(times), max(times));
if ~isempty(valid_vel)
    fprintf('速率统计:\n');
    fprintf('  - 平均速率: %.4f 网格单位/时间步\n', mean_vel);
    fprintf('  - 速率标准差: %.4f\n', std_vel);
    fprintf('  - 最大速率: %.4f\n', max(valid_vel));
    fprintf('  - 最小速率: %.4f\n', min(valid_vel));
end
if ~isempty(valid_curv)
    fprintf('曲率半径统计:\n');
    fprintf('  - 平均曲率半径: %.4f 网格单位\n', mean_curv);
    fprintf('  - 曲率半径标准差: %.4f\n', std_curv);
    fprintf('  - 最大曲率半径: %.4f\n', max(valid_curv));
    fprintf('  - 最小曲率半径: %.4f\n', min(valid_curv));
end
fprintf('=====================================\n\n');

end