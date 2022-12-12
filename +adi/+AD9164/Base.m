classdef (Abstract) Base < adi.AD916x.Base
    %AD9162 Base Summary of this class goes here
    %   Detailed explanation goes here
   
    
    %% API Functions
    methods (Hidden, Access = protected)
                
        function icon = getIconImpl(obj)
            icon = sprintf(['AD9164',obj.Type]);
        end
        
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)       
        function bName = getDescriptiveName(~)
            bName = 'AD9164';
        end
        
    end
end

