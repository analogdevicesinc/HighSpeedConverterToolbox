classdef ADAR3002 < adi.internal.ADAR300x
    %ADAR3002 Beamformer Single Chip Interface
    properties (Nontunable)
        
    end
    
    properties
    end
    
    properties(Nontunable, Hidden)
        ArrayMapInternal = 1:4;
    end
    
    properties(Hidden)
        deviceNames = {'adar3002_csb_0_0'};
    end
        
    methods
        %% Constructor
        function obj = ADAR3002(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.internal.ADAR300x(varargin{:});
        end
        % Destructor
        function delete(obj)
        end
    end
end



