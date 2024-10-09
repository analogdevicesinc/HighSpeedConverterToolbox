classdef (Abstract) Base < adi.AD915x.Base
    %AD9152 Base
    

    %% API Functions
    methods (Hidden, Access = protected)
                
        function icon = getIconImpl(obj)
            icon = sprintf(['AD9152 ',obj.Type]);
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        function bName = getDescriptiveName(~)
            bName = 'AD9152';
        end
    end
end

