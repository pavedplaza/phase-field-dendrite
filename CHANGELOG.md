# Changelog | 版本历史

All notable changes to this project will be documented in this file.
本项目的所有重要更改都将记录在此文件中。

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
格式基于[Keep a Changelog](https://keepachangelog.com/en/1.0.0/)，
本项目遵循[语义化版本](https://semver.org/spec/v2.0.0.html)。

## [Unreleased]

### Added | 新增
- Bilingual documentation (Chinese/English)
  双语文档（中文/英文）
- Velocity field coupling with permeability model
  速度场耦合与渗透率模型
- Six-fold symmetric dendrite growth simulation
  六重对称枝晶生长模拟
- Tip tracking with dynamics analysis
  尖端追踪与动力学分析
- Video output (combined fields and velocity field visualization)
  视频输出（合并场和速度场可视化）

### Changed | 更改
- Improved code structure with modular design
  改进代码结构，模块化设计
- Enhanced error handling and validation
  增强错误处理和验证
- Optimized visualization performance
  优化可视化性能

---

## [1.9.0] - 2026-02-11

### Added | 新增
- **Velocity Field Support | 速度场支持**
  - Uniform flow (forced convection)
    均匀流（强制对流）
  - Shear flow (linear velocity gradient)
    剪切流（线性速度梯度）
  - Vortex flow (rotational velocity field)
    涡旋流（旋转速度场）
  - Permeability model to prevent fluid penetration into solid phase
    渗透率模型防止流体穿透固相

- **Enhanced Visualization | 增强可视化**
  - Real-time velocity field visualization with quiver plots
    实时速度场可视化（箭头图）
  - Combined field video output (phase + concentration + C/C∞)
    合并场视频输出（相场 + 浓度场 + C/C∞）
  - Velocity field contour video
    速度场轮廓视频

- **Improved Tip Tracking | 改进尖端追踪**
  - Direction-specific tip detection algorithm
    方向性尖端检测算法
  - Instantaneous tip velocity calculation
    瞬时尖端速度计算
  - Tip curvature radius estimation
    尖端曲率半径估计

- **Better Documentation | 改进文档**
  - Comprehensive README with bilingual comments
    全面的README与双语注释
  - Troubleshooting guide
    故障排除指南
  - Project structure documentation
    项目结构文档
  - Known limitations section
    已知限制章节

### Changed | 更改
- Refactored main simulation loop for better performance
  重构主模拟循环以提升性能
- Improved numerical stability with adaptive time stepping
  改进数值稳定性，自适应时间步进
- Enhanced parameter configuration system
  增强参数配置系统

### Fixed | 修复
- Fixed contour extraction for asymmetric growth patterns
  修复非对称生长模式的轮廓提取
- Fixed video generation when visualization is disabled
  修复禁用可视化时的视频生成
- Fixed path issues in example scripts
  修复示例脚本中的路径问题

### Technical Details | 技术细节
- **Phase Field Method | 相场法**: Anisotropic Allen-Cahn equation
  **各向异性Allen-Cahn方程**
- **Numerical Method | 数值方法**: Finite difference (5-point stencil)
  **有限差分（五点格式）**
- **Time Integration | 时间积分**: Explicit Euler scheme
  **显式欧拉格式**

---