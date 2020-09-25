classdef DemoTests < matlab.uitest.TestCase
    
    properties
        root = '';
    end
    
    methods(TestClassSetup)
        function addpaths(testCase)
            here = mfilename('fullpath');
            here = strsplit(here,'/');
            here = fullfile('/',here{1:end-2});
            testCase.root = here;
            addpath(genpath(fullfile(here,'hdl')));
        end
        function setupVivado(~)
            v=ver('matlab'); Release = v.Release;
            switch Release
                case '(R2017a)'
                    vivado = '2016.2';
                case '(R2017b)'
                    vivado = '2017.4';
                case '(R2018b)'
                    vivado = '2017.4';
                case '(R2019a)'
                    vivado = '2018.2';
                case '(R2019b)'
                    vivado = '2018.2';
                case '(R2020a)'
                    vivado = '2018.2';
            end
            if ispc
                hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
                    'ToolPath', ['C:\Xilinx\Vivado\',vivado,'\bin\vivado.bat']);
            elseif isunix
                hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
                    'ToolPath', ['/opt/Xilinx/Vivado/',vivado,'/bin/vivado']);
            end
            
        end
    end
    
    methods(TestMethodTeardown)
        function cleanup_hdl_prj(testCase)
            if exist(fullpath(testCase.root,'hdl_prj'),'dir')
                rmdir(fullpath(testCase.root,'hdl_prj'), 's');
            end
        end
    end
    
    methods(Test)
        function buildHDLDAQ2ZCU102_BOOTBIN(testCase)
            cd(fullfile(testCase.root,'test'));
            hdlworkflow_daq2_zcu102_rx;
            if ~isempty(out)
                disp(out.message);
            end
            % Check for BOOT.BIN
            if exist('hdl_prj/vivado_ip_prj/boot/BOOT.BIN', 'file') ~= 2
                error('BOOT.BIN Failed');
            end
        end
    end
    
end
