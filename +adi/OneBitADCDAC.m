classdef OneBitADCDAC < adi.common.Attribute% & adi.common.Rx
    properties(Nontunable, Hidden)
        SamplesPerFrame = 0;
        devName = 'one-bit-adc-dac';
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
    end
    
    properties
        PowerUpDown
        Ctrl5V
        PAOn
    end
    
    methods
        function set.PowerUpDown(obj, value)
            obj.setAttributeBool('voltage5', 'raw', true, value);
        end
        
        function set.Ctrl5V(obj, value)
            obj.setAttributeBool('voltage4', 'raw', true, value);
        end
    end
    
    methods (Hidden, Access = protected)
        function setupImpl(obj)
            % Setup LibIIO
            setupLib(obj);
            
            % Initialize the pointers
            initPointers(obj);
            
            getContext(obj);
            
            setContextTimeout(obj);
            
            obj.needsTeardown = true;
            
            % Pre-calculate values to be used faster in stepImpl()
%             obj.pIsInSimulink = coder.const(obj.isInSimulink);
%             obj.pNumBufferBytes = coder.const(obj.numBufferBytes);
            
            obj.ConnectedToDevice = true;
            setupInit(obj);
        end
        
        function setupInit(obj)            
        end
    end
end