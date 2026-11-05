classdef BSPInstallerTests < BSPTestsBase
    properties
        installed = [];
    end
    
    methods(TestClassSetup)
        function requireCleanInstallation(~)
            folder = getenv('HSX_ADDON_ROOT');
            if ~isempty(folder)
                if ~isfolder(folder)
                    mkdir(folder);
                end
                preferences = settings;
                preferences.matlab.addons.InstallationFolder.TemporaryValue = folder;
                drawnow;
            end
            % Never remove unrelated user toolboxes during verification.
            str = 'Analog Devices, Inc. High-Speed Converter Toolbox';
            ts = matlab.addons.toolbox.installedToolboxes;
            for t = ts
                assert(~strcmp(t.Name,str), 'adi:ExistingToolbox', ...
                    'Run installer tests with an isolated add-on installation folder.');
            end
        end
        function installBSP(obj)
            %system('wget https://github.com/analogdevicesinc/MathWorks_tools/releases/download/v18.1.0/AnalogDevicesBSP_v18.1.0.mltbx');
            %system('rm *.mltbx');
            %system('curl -s https://api.github.com/repos/analogdevicesinc/MathWorks_tools/releases/latest | grep browser_download_url | cut -d "\"" -f 4 | wget --no-check-certificate -i -');
            %tbname = 'AnalogDevicesBSP_v18.1.mltbx';
            disp('BSP Installer tests setup called');           
            files = dir('.');
            for file = 1:length(files)
                fn = files(file).name;
                try
                    if strcmpi(fn(end-5:end),'.mltbx') && ~contains(fn,'examples')
                        tbname = fn;
                        break
                    end
                catch
                    continue;
                end
            end
            disp('BSP Installer tests setup called');
            disp(['Found: ',tbname]);
            try
                obj.installed = matlab.addons.toolbox.installToolbox(tbname);
            catch ME
                disp(ME);
                disp(ME.message);
                throw(ME);
            end
            obj.installed
            installedRoot = char(matlab.internal.addons.util.retrieveInstallationFolderForAddOn( ...
                obj.installed.Guid, obj.installed.Version));
            for name = {'adi.Version', 'AnalogDevices.plugin_rd'}
                resolved = which(name{1});
                assert(~isempty(resolved) && startsWith(resolved, [installedRoot,filesep]), ...
                    'adi:SourceShadowingInstaller', ...
                    'Installer test resolved %s from source or could not find it: %s', name{1}, resolved);
            end
            disp("Installed");
        end
    end
    
    methods(TestClassTeardown)
        function uninstallBSP(obj)
            if ~isempty(obj.installed)
                matlab.addons.toolbox.uninstallToolbox(obj.installed);
            end
        end
    end
    
end
