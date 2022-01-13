classdef ADF4371 < adi.common.Attribute & adi.common.Rx
    properties(Nontunable, Hidden)
        SamplesPerFrame = 0;
        devName = 'adf4371';
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        iioDriverName = 'adf4371';
        DevLabel = 'adf4371-0'
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Tx';
    end
    
    properties
        DevPtr
    end
    
    properties
        MUXOutEnable
        % MUXOutMode
        Name
        Frequency
        Phase
        PowerDown
        Temp
    end
    
    methods
        function result = get.MUXOutEnable(obj)
            result = false;
            if ~isempty(obj.DevPtr)
                result = logical(str2double(obj.getDeviceAttributeRAW('muxout_enable', 128, obj.DevPtr)));
            end
        end
        
        function set.MUXOutEnable(obj, value)
            obj.setDeviceAttributeRAW('muxout_enable', num2str(value), obj.DevPtr);
        end
        
        function result = get.Name(obj)
            result = false;
            if ~isempty(obj.DevPtr)
                result = obj.getAttributeRAW('name', 'raw', true, obj.DevPtr);
            end
        end
        
%         function set.TXRX0(obj, value)
%             obj.setAttributeRAW('voltage1', 'raw', num2str(value), true, obj.DevPtr);
%         end
    end
    
    methods (Hidden, Access = protected)
        function setupADF4371(obj)
            obj.DevPtr = getDev(obj, 'adf4371-0');
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
        
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
        end
        
        function setupInit(obj)
            obj.setupADF4371();
        end
    end
end