classdef ADAR3002 < adi.internal.ADAR300x
    %ADAR1000 Beamformer
    properties (Nontunable)
    end
    
    properties
    end
    
    properties(Nontunable, Hidden)
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



