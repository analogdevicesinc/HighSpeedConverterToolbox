classdef Version
    %Version
    %   BSP Version information
    properties(Constant)
        HDL = 'hdl_2022_r2';
        MATLAB = 'R2023b';
        Release = '23.2.1';
        AppName = 'Analog Devices, Inc. High-Speed Converter Toolbox';
        ToolboxName = 'HighSpeedConverterToolbox';
        ToolboxNameShort = 'hsx';
        ExamplesDir = 'hsx_examples';
        HasHDL = true;
    end
    
    properties
        Vivado
    end 

   properties(Dependent)
        VivadoShort
    end

methods
        % Set Vivado version dynamically
        function obj = Version(vivado_version)
            if nargin > 0
                obj.Vivado = vivado_version;  % Set Vivado based on input
            else
                obj.Vivado = '2023.1';  % Default value
            end
        end
        
        function value = get.VivadoShort(obj)
            value = obj.Vivado(1:6);
        end
    end
end

