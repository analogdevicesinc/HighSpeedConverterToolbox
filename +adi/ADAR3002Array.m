classdef ADAR3002Array < adi.internal.ADAR300x
    %ADAR3002Array Beamformer
    properties (Nontunable)
    end
    
    properties(Dependent)
        ArrayMap
    end
    
    properties(Nontunable, Hidden)
        ArrayMapInternal = [1,2,3,4;5,6,7,8];
    end
    
    properties(Hidden)
       deviceNames = {'adar3002_csb_0_0','adar3002_csb_1_1'};
    end
        
    methods
        %% Constructor
        function obj = ADAR3002Array(varargin)
            coder.allowpcode('plain');
            obj = obj@adi.internal.ADAR300x(varargin{:});
        end
        % Destructor
        function delete(obj)
        end
        % Sets
        function set.ArrayMap(obj,value)
            obj.ArrayMapInternal = value;
        end
        function value = get.ArrayMap(obj)
            value = obj.ArrayMapInternal;
        end
    end
end



