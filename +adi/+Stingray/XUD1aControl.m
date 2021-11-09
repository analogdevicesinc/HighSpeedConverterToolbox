classdef XUD1aControl < adi.common.Attribute & adi.common.Rx
    properties(Nontunable, Hidden)
        SamplesPerFrame = 0;
        devName = 'one-bit-adc-dac';
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        iioDriverName = 'one-bit-adc-dac';
        DevLabel = 'stingray_control'
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
        DevPtr
    end
    
    properties
        GPIO0
        GPIO5
        IMU_GPIO3
    end
    
    methods
        function result = get.GPIO0(obj)
            result = false;
            if ~isempty(obj.DevPtr)
                result = obj.getAttributeRAW('voltage0', 'raw', true, obj.DevPtr);
            end
        end
        
        function set.GPIO0(obj, value)
            obj.setAttributeRAW('voltage0', 'raw', num2str(value), true, obj.DevPtr);
        end
        
        function result = get.GPIO5(obj)
            result = false;
            if ~isempty(obj.DevPtr)
                result = obj.getAttributeRAW('voltage1', 'raw', true, obj.DevPtr);
            end
        end
        
        function set.GPIO5(obj, value)
            obj.setAttributeRAW('voltage1', 'raw', num2str(value), true, obj.DevPtr);
        end
        
        function result = get.IMU_GPIO3(obj)
            result = false;
            if ~isempty(obj.DevPtr)
                result = obj.getAttributeRAW('voltage2', 'raw', true, obj.DevPtr);
            end
        end
        
        function set.IMU_GPIO3(obj, value)
            obj.setAttributeRAW('voltage2', 'raw', num2str(value), true, obj.DevPtr);
        end
    end
    
    methods (Hidden, Access = protected)
        function setupXUD1aControl(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);            
            found = false;
            for k = 1:numDevs
                devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);                    
                attrCount = obj.iio_device_get_attrs_count(devPtr);
                name = obj.iio_device_get_name(devPtr);
                if contains(name,obj.iioDriverName)
                    for i = 1:attrCount
                        attr = obj.iio_device_get_attr(devPtr,i-1);
                        if strcmpi(attr,'label')
                            val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                            if contains(obj.DevLabel,val)
                                obj.DevPtr = devPtr;
                                found = true;
                                break;
                            end
                        end
                    end
                    if found
                        break;
                    end
                end
            end
            if ~found
                error('Unable to locate %s in context',obj.ChipID{ChipIDIndx});
            end
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
            obj.setupXUD1aControl();
        end
    end
end