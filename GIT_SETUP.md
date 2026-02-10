# Git Setup Guide | Git设置指南

This guide helps you initialize git for the project and prepare for open-source release.
本指南帮助您为项目初始化git并准备开源发布。

## Quick Start | 快速开始

### 1. Initialize Git Repository | 初始化Git仓库

```bash
# Navigate to project root | 切换到项目根目录
cd "path/to/phase-field-dendrite-basic"

# Initialize git repository | 初始化git仓库
git init

# Add all files | 添加所有文件
git add .

# Create initial commit | 创建初始提交
git commit -m "Initial commit: Phase-field dendrite growth simulation v1.9.0"
```

### 2. Create GitHub Repository | 创建GitHub仓库

**Option A: Via GitHub Website | 通过GitHub网站**
1. Go to [GitHub](https://github.com) and create a new repository
   转到[GitHub](https://github.com)并创建新仓库
2. Repository name: `phase-field-dendrite-basic`
   仓库名称：`phase-field-dendrite-basic`
3. **DO NOT** initialize with README (you already have one)
   **不要**用README初始化（您已经有了）
4. Follow the instructions shown after creation
   按照创建后显示的说明操作

**Option B: Using GitHub CLI | 使用GitHub CLI**

```bash
# Install GitHub CLI first
# gh auth login

# Create repository | 创建仓库
gh repo create phase-field-dendrite-basic --public --source=. --remote=origin

# Or private repository | 或私有仓库
gh repo create phase-field-dendrite-basic --private --source=. --remote=origin
```

### 3. Link Local to Remote | 关联本地到远程

```bash
# Add remote origin | 添加远程源
git remote add origin https://github.com/pavedplaza/phase-field-dendrite-basic.git

# Push to GitHub | 推送到GitHub
git push -u origin main
```

### 4. Create First Release Tag | 创建第一个发布标签

```bash
# Create annotated tag for v1.9.0
# 为v1.9.0创建带注释的标签
git tag -a v1.9.0 -m "Release v1.9.0: Initial open-source release

- Phase-field dendrite growth simulation
- Velocity field coupling
- Six-fold symmetric growth
- Comprehensive documentation

Features:
- Bilingual support (Chinese/English)
- Real-time visualization
- Video output
- Tip tracking
- Multiple velocity field types"

# Push tag to GitHub | 推送标签到GitHub
git push origin v1.9.0
```

### 5. Create GitHub Release | 创建GitHub发布

1. Go to: https://github.com/pavedplaza/phase-field-dendrite-basic/releases/new
   转到：https://github.com/pavedplaza/phase-field-dendrite-basic/releases/new
2. Select tag: `v1.9.0`
   选择标签：`v1.9.0`
3. Release title: `Version 1.9.0`
   发布标题：`Version 1.9.0`
4. Copy release notes from CHANGELOG.md
   从CHANGELOG.md复制发布说明
5. Click "Publish release"
   点击"Publish release"

## Pre-Push Checklist | 推送前检查清单

Before pushing to GitHub, ensure:
推送到GitHub之前，确保：

- [ ] **.gitignore is configured correctly**
    **.gitignore配置正确**
  ```bash
  # Check what will be pushed | 检查将要推送的内容
  git status
  git ls-files
  ```

- [ ] **No sensitive data is included**
    **没有包含敏感数据**
  - [ ] No personal information in code
    代码中没有个人信息
  - [ ] No API keys or passwords
    没有API密钥或密码
  - [ ] Check `simulation_data.mat` is ignored (large file)
    检查`simulation_data.mat`被忽略（大文件）

- [ ] **All example files work**
    **所有示例文件都能工作**
  ```bash
  # Test examples | 测试示例
  # (In MATLAB)
  addpath(genpath('.'))
  run('examples/example_basic_growth.m')
  ```

- [ ] **Documentation is complete**
    **文档完整**
  - [ ] README.md is up-to-date
    README.md是最新的
  - [ ] CHANGELOG.md has v1.9.0 entry
    CHANGELOG.md有v1.9.0条目
  - [ ] Contributing guidelines exist
    贡献指南存在

## Workflow Overview | 工作流程概述

```
Development Flow | 开发流程

1. Create feature branch | 创建功能分支
   git checkout -b feature/new-feature

2. Make changes and commit | 进行更改并提交
   git add .
   git commit -m "Add new feature"

3. Push to remote | 推送到远程
   git push origin feature/new-feature

4. Create pull request | 创建拉取请求
   (Via GitHub web interface)

5. Review and merge | 审查并合并
   (After approval)

6. Delete branch | 删除分支
   git branch -d feature/new-feature

Release Flow | 发布流程

1. Update version numbers | 更新版本号
2. Update CHANGELOG.md | 更新CHANGELOG.md
3. Create release branch | 创建发布分支
4. Test thoroughly | 彻底测试
5. Create tag | 创建标签
6. Push tag | 推送标签
7. Create GitHub release | 创建GitHub发布
```

## Verification | 验证

After setup, verify everything works:
设置完成后，验证一切正常：

```bash
# Check remote | 检查远程
git remote -v

# Check branches | 检查分支
git branch -a

# Check tags | 检查标签
git tag

# Verify gitignore | 验证gitignore
git check-ignore -v *.mat *.png

# View log | 查看日志
git log --oneline --graph --all
```

---

**Last Updated | 最后更新**: 2026-02-11

**Maintainer | 维护者**: pavedplaza
