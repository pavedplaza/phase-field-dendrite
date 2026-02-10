# Contributing to Phase Field Dendrite Simulation

Thank you for your interest in contributing!

---

## Quick Ways to Contribute

### 1. Report Bugs

**Before reporting**:
- Check [README.md](README.md) for common issues and solutions
- Many issues are documented in the [Known Limitations](https://github.com/pavedplaza/phase-field-dendrite-basic#known-limitations-) section

Found an issue? Please let us know!

- Search [existing issues](https://github.com/pavedplaza/phase-field-dendrite-basic/issues) first
- Include:
  - MATLAB version
  - Error message
  - Steps to reproduce
  - Expected vs actual behavior

### 2. Suggest Features

Have an idea? We'd love to hear it!

- Use clear titles
- Explain the use case
- Describe why it's useful

### 3. Improve Documentation

- Fix typos
- Add examples
- Clarify explanations

---

## Submitting Code

### Basic Workflow

```bash
# 1. Fork and clone
git clone https://github.com/pavedplaza/phase-field-dendrite-basic.git
cd phase-field-dendrite-basic

# 2. Create a branch
git checkout -b feature/your-feature-name

# 3. Make changes and test
# ... (make your changes) ...

# 4. Commit
git commit -m "Add: brief description"

# 5. Push
git push origin feature/your-feature-name

# 6. Create Pull Request on GitHub
```

### Commit Messages

Use clear format:

```
<type>: <short description>

<type options>
- Add: new feature
- Fix: bug fix
- Docs: documentation update
- Refactor: refactoring
```

Examples:
```
Add: Support for vortex velocity field
Fix: Correct tip velocity calculation error
Docs: Update Quick Start section
```

---

## Code Style Basics

### File Header

Every function should start with:

```matlab
function [output] = function_name(input)
    % Brief one-line description
    %
    % Inputs: input - Description
    % Outputs: output - Description
```

### Naming

- **Functions**: `lowercase_with_underscores`
- **Variables**: `descriptive_names`
- **Constants**: `ALL_CAPS`

### Comments

- Use bilingual comments (English/Chinese)
- Comment complex logic

```matlab
% Calculate tip velocity using polynomial fitting
velocity = fit_polynomial(time, distance);
```

### Indentation

- 4 spaces (no tabs)
- Space around operators

```matlab
% Good
result = (a + b) * c;

% Bad
result=(a+b)*c;
```

---

## Testing Your Changes

Before submitting:

1. **Run the simulation**
   ```matlab
   run('phase_field_simulation.m')
   ```

2. **Verify functionality**
   - Check for errors
   - Test new features

3. **Update documentation**
   - README if needed
   - Function help text

---

## Questions?

- **GitHub Issues**: [Report bugs or ask questions](https://github.com/pavedplaza/phase-field-dendrite-basic/issues)
- **Email**: pavedplaza <2300837983@qq.com>

---

**Thank you for contributing!**

**Questions? Please open an issue or contact the maintainers.**