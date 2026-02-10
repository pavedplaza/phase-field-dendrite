# Contributing to Phase Field Dendrite Simulation
# 为相场枝晶模拟项目贡献

Thank you for your interest in contributing!
感谢您对本项目的贡献兴趣！

---

## Quick Ways to Contribute | 快速贡献方式

### 1. Report Bugs | 报告Bug

**Before reporting** | **报告前**:
- Check [README.md](README.md) for common issues and solutions
  查看[README.md](README.md)了解常见问题和解决方案
- Many issues are documented in the [Known Limitations](https://github.com/pavedplaza/phase-field-dendrite-basic#known-limitations--已知限制) section
  许多问题记录在[已知限制](https://github.com/pavedplaza/phase-field-dendrite-basic#known-limitations--已知限制)章节中

Found an issue? Please let us know!
发现了问题？请告诉我们！

- Search [existing issues](https://github.com/pavedplaza/phase-field-dendrite-basic/issues) first
  首先搜索[现有问题](https://github.com/pavedplaza/phase-field-dendrite-basic/issues)
- Include:
  请包括：
  - MATLAB version | MATLAB版本
  - Error message | 错误信息
  - Steps to reproduce | 重现步骤
  - Expected vs actual behavior | 预期与实际行为

### 2. Suggest Features | 建议功能

Have an idea? We'd love to hear it!
有想法？我们很乐意听取！

- Use clear titles | 使用清晰的标题
- Explain the use case | 解释使用场景
- Describe why it's useful | 描述为什么有用

### 3. Improve Documentation | 改进文档

- Fix typos | 修正拼写错误
- Add examples | 添加示例
- Clarify explanations | 澄清说明

---

## Submitting Code | 提交代码

### Basic Workflow | 基本流程

```bash
# 1. Fork and clone | Fork并克隆
git clone https://github.com/pavedplaza/phase-field-dendrite-basic.git
cd phase-field-dendrite-basic

# 2. Create a branch | 创建分支
git checkout -b feature/your-feature-name

# 3. Make changes and test | 修改并测试
# ... (make your changes) ... | （进行修改）

# 4. Commit | 提交
git commit -m "Add: brief description"

# 5. Push | 推送
git push origin feature/your-feature-name

# 6. Create Pull Request on GitHub
#    在GitHub上创建Pull Request
```

### Commit Messages | 提交消息

Use clear format:
使用清晰格式：

```
<type>: <short description>
<类型>: <简短描述>

<类型 options>
- Add: 新功能
- Fix: 修复bug
- Docs: 文档更新
- Refactor: 重构
```

Examples | 示例：
```
Add: Support for vortex velocity field
Fix: Correct tip velocity calculation error
Docs: Update Quick Start section
```

---

## Code Style Basics | 代码风格基础

### File Header | 文件头

Every function should start with:
每个函数应以以下内容开头：

```matlab
function [output] = function_name(input)
    % Brief one-line description
    % 简短的一行描述
    %
    % Inputs: input - Description
    % Outputs: output - Description
```

### Naming | 命名

- **Functions**: `lowercase_with_underscores`
  **函数**：`lowercase_with_underscores`
- **Variables**: `descriptive_names`
  **变量**：`descriptive_names`
- **Constants**: `ALL_CAPS`
  **常量**：`ALL_CAPS`

### Comments | 注释

- Use bilingual comments (English/Chinese)
  使用双语注释（英文/中文）
- Comment complex logic
  注释复杂逻辑

```matlab
% Calculate tip velocity using polynomial fitting
% 使用多项式拟合计算尖端速率
velocity = fit_polynomial(time, distance);
```

### Indentation | 缩进

- 4 spaces (no tabs) | 4个空格（无制表符）
- Space around operators | 运算符周围留空格

```matlab
% Good | 好
result = (a + b) * c;

% Bad | 差
result=(a+b)*c;
```

---

## Testing Your Changes | 测试您的更改

Before submitting:
提交前请：

1. **Run the simulation | 运行模拟**
   ```matlab
   run('phase_field_simulation.m')
   ```

2. **Verify functionality | 验证功能**
   - Check for errors | 检查错误
   - Test new features | 测试新功能

3. **Update documentation | 更新文档**
   - README if needed | 如需要更新README
   - Function help text | 函数帮助文本

---

## Questions? | 有问题？

- **GitHub Issues**: [Report bugs or ask questions](https://github.com/pavedplaza/phase-field-dendrite-basic/issues)
  **GitHub Issues**：[报告bug或提问](https://github.com/pavedplaza/phase-field-dendrite-basic/issues)
- **Email**: pavedplaza <2300837983@qq.com>

---

**Thank you for contributing!**
**感谢您的贡献！**

**Questions? Please open an issue or contact the maintainers.**
**有问题？请打开issue或联系维护者。**