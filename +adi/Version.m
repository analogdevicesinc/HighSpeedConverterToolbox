classdef Version
    %Version
    %   BSP Version information
    properties(Constant)
        HDL = 'hdl_2018_r2';
        Vivado = '2018.2';
        MATLAB = 'R2021a';
        Release = '21.1.1';
        AppName = 'Analog Devices, Inc. High-Speed Converter Toolbox';
        ToolboxName = 'HighSpeedConverterToolbox';
        ToolboxNameShort = 'hsx';
        ExamplesDir = 'hsx_examples';
        HasHDL = true;
    end
    properties(Dependent)
        VivadoShort
    end
    
    methods
        function value = get.VivadoShort(obj)
            value = obj.Vivado(1:6); 
        end
    end
end

