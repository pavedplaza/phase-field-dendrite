function success = verify_installation()
% VERIFY_INSTALLATION Verify phase-field simulation installation
% 验证相场模拟安装
%
% Syntax:
%   success = verify_installation()
%
% Output:
%   success - true if all checks pass, false otherwise
%          - 如果所有检查通过返回true,否则返回false
%
% Example:
%   if verify_installation()
%       params = config_default();
%       run_simulation(params);
%   end
%
% See also: config_default, run_simulation

    fprintf('========================================================\n');
    fprintf('Phase Field Simulation Installation Verification\n');
    fprintf('相场模拟安装验证\n');
    fprintf('========================================================\n\n');

    all_passed = true;

    % Check 1: PFM_core directory exists
    fprintf('Check 1: PFM_core directory... ');
    if exist('PFM_core', 'dir')
        fprintf('✓ Found\n');
    else
        fprintf('✗ Not found\n');
        all_passed = false;
    end

    % Check 2: Add PFM_core to path
    fprintf('Check 2: Adding PFM_core to path... ');
    try
        addpath('PFM_core');
        fprintf('✓ Success\n');
    catch
        fprintf('✗ Failed\n');
        all_passed = false;
    end

    % Check 3: Required PFM_core functions
    fprintf('Check 3: Required PFM_core functions:\n');

    required_functions = {
        'calculate_six_tip_dynamics'
        'calculate_instantaneous_tip_velocity'
        'find_six_tips_direction_specific'
        'calculate_contour_line_intersections'
        'resample_contour_equidistant'
        'generate_tip_detailed_analysis'
        'plot_six_tip_dynamics_analysis'
    };

    for i = 1:length(required_functions)
        func_name = required_functions{i};
        fprintf('  - %s', func_name);
        if exist(func_name, 'file')
            fprintf('... ✓\n');
        else
            fprintf('... ✗ Missing\n');
            all_passed = false;
        end
    end

    % Check 4: config_default function
    fprintf('\nCheck 4: config_default function... ');
    if exist('config_default', 'file')
        fprintf('✓ Found\n');
        try
            params = config_default();
            fprintf('  Successfully loaded default configuration\n');
            fprintf('  Grid size: %dx%d\n', params.Nx, params.Ny);
            fprintf('  Material: k=%.2f, ε=%.2f\n', params.k_partition, params.epsilon_aniso);
        catch ME
            fprintf('✗ Error loading config: %s\n', ME.message);
            all_passed = false;
        end
    else
        fprintf('✗ Not found\n');
        all_passed = false;
    end

    % Check 5: Main simulation files
    fprintf('\nCheck 5: Main simulation files:\n');

    main_files = {
        'phase_field_simulation.m'
        'run_simulation.m'
    };

    for i = 1:length(main_files)
        file_name = main_files{i};
        fprintf('  - %s', file_name);
        if exist(file_name, 'file')
            fprintf('... ✓\n');
        else
            fprintf('... ✗ Missing (will be created during installation)\n');
            % Don't fail on missing main files - they may be created during setup
        end
    end

    % Final result
    fprintf('\n========================================================\n');
    if all_passed
        fprintf('✓ ALL CHECKS PASSED\n');
        fprintf('Installation is ready to use!\n');
        fprintf('安装验证完成，可以开始使用！\n');
    else
        fprintf('✗ SOME CHECKS FAILED\n');
        fprintf('Please resolve the issues above before running simulations.\n');
        fprintf('请解决上述问题后再运行模拟。\n');
    end
    fprintf('========================================================\n');

    success = all_passed;
end
