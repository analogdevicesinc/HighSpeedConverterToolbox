classdef ReleaseCompatibilityTests < matlab.unittest.TestCase
    methods (Test)
        function versionMetadataTargetsSupportedRelease(testCase)
            v = adi.Version;
            testCase.verifyEqual(v.MATLAB, 'R2025b');
            testCase.verifyEqual(v.HDL, 'hdl_2026_r1');
            testCase.verifyEqual(v.Vivado, '2025.1');
            testCase.verifyEqual(v.VivadoShort, '2025.1');
            testCase.verifyEqual(v.Release, '25.2.1');
        end

        function documentationMetadataTargetsSupportedRelease(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            info = fileread(fullfile(root, 'info.xml'));
            contents = fileread(fullfile(root, '+adi', 'Contents.m'));
            testCase.verifySubstring(info, ...
                '<matlabrelease>R2025b</matlabrelease>');
            testCase.verifySubstring(contents, ...
                '% Version 25.2.1 (R2025b)');
        end

        function packagedHdlMatchesReleaseMetadata(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            envFile = fullfile(root, 'hdl', 'vendor', 'AnalogDevices', ...
                'vivado', 'scripts', 'adi_env.tcl');
            testCase.assertTrue(isfile(envFile), ...
                'Packaged HDL release metadata is missing.');
            text = fileread(envFile);
            expected = sprintf('set required_vivado_version "%s"', ...
                adi.Version.Vivado);
            testCase.verifySubstring(text, expected);

            pluginRoot = fullfile(root, 'hdl', 'vendor', ...
                'AnalogDevices', '+AnalogDevices');
            pluginFiles = dir(fullfile(pluginRoot, '**', 'plugin_*.m'));
            versions = {};
            expression = ...
                ['(?m)^\s*[^%\r\n]*\.SupportedToolVersion\s*=\s*' ...
                 '\{\s*''([^'']+)''\s*\}\s*;?\s*$'];
            for file = pluginFiles'
                pluginText = fileread(fullfile(file.folder, file.name));
                matches = regexp(pluginText, expression, 'tokens');
                for match = matches
                    versions{end + 1} = match{1}{1}; %#ok<AGROW>
                end
            end
            testCase.assertNotEmpty(versions, ...
                'No generated HDL Coder tool-version declarations found.');
            testCase.verifyTrue(all(strcmp(versions, adi.Version.Vivado)), ...
                sprintf('Generated plugins must all target Vivado %s.', ...
                adi.Version.Vivado));
        end
    end
end
