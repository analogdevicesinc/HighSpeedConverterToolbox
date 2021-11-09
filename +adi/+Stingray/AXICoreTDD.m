classdef AXICoreTDD < adi.common.Attribute & adi.common.Rx
    properties(Nontunable, Hidden)
        SamplesPerFrame = 0;
        devName = 'axi-core-tdd';
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        iioDriverName = 'axi-core-tdd';
        DevLabel = 'axi_core_tdd_control'
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
        % Device Attributes
        BurstCount
        CounterInt
        % DMA Gateing Mode
        % 0 - none
        % 1 - rx_only
        % 2 - tx_only
        % 3 - rx_tx
        DMAGateingMode = 0; 
        Enable
        % Enable Mode
        % 1 - rx_only
        % 2 - tx_only
        % 3 - rx_tx
        EnableMode = 3;
        FrameLength
        Secondary
        SyncTerminalType
        
        % Channel Attributes
        TxDPoff = [0 0];
        TxDPon = [0 0];
        TxOff = [0 0];
        TxOn = [0 0];
        TxVCOoff = [0 0];
        TxVCOon = [0 0];
        RxDPoff = [0 0];
        RxDPon = [0 0];
        RxOff = [0 0];
        RxOn = [0 0];
        RxVCOoff = [0 0];
        RxVCOon = [0 0];
    end
    
    % Get/Set Methods for Device Attributes
    methods
        function result = get.BurstCount(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('burst_count', 128, obj.DevPtr));
            end
        end
        
        function set.BurstCount(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('burst_count', num2str(value), obj.DevPtr);
            end
        end
        
        function result = get.CounterInt(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('counter_int', 128, obj.DevPtr));
            end
        end
        
        function set.CounterInt(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('counter_int', num2str(value), obj.DevPtr);
            end
        end
        
        function result = get.DMAGateingMode(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                ResultStr = obj.getDeviceAttributeRAW('dma_gateing_mode', 128, obj.DevPtr);
                switch ResultStr
                    case "none"
                        result = 0;
                    case "rx_only"
                        result = 1;
                    case "tx_only"
                        result = 2;
                    case "rx_tx"
                        result = 3;
                end
            end
        end
        
        function set.DMAGateingMode(obj, value)
            validateattributes( value, { 'double', 'single', 'uint32'}, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',3}, ...
                '', 'DMAGateingMode');
            if obj.ConnectedToDevice
                switch value
                    case 0
                        ValueStr = 'none';
                    case 1
                        ValueStr = 'rx_only';
                    case 2
                        ValueStr = 'rx_only';
                    case 3
                        ValueStr = 'rx_tx';
                end
                obj.setDeviceAttributeRAW('dma_gateing_mode', ValueStr, obj.DevPtr);
            end
        end
        
        function result = get.Enable(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('en', 128, obj.DevPtr));
            end
        end
        
        function set.Enable(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('en', num2str(value), obj.DevPtr);
            end
        end
        
        function result = get.EnableMode(obj)
            result = 3;
            if ~isempty(obj.DevPtr)
                ResultStr = obj.getDeviceAttributeRAW('en_mode', 128, obj.DevPtr);
                switch ResultStr
                    case "rx_only"
                        result = 1;
                    case "tx_only"
                        result = 2;
                    case "rx_tx"
                        result = 3;
                end
            end
        end
        
        function set.EnableMode(obj, value)
            validateattributes( value, { 'double', 'single', 'uint32'}, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',1,'<=',3}, ...
                '', 'EnableMode');
            if obj.ConnectedToDevice
                switch value
                    case 1
                        ValueStr = 'rx_only';
                    case 2
                        ValueStr = 'rx_only';
                    case 3
                        ValueStr = 'rx_tx';
                end
                obj.setDeviceAttributeRAW('en_mode', ValueStr, obj.DevPtr);
            end
        end
        
        function result = get.FrameLength(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('frame_length_ms', 128, obj.DevPtr));
            end
        end
        
        function set.FrameLength(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('frame_length_ms', num2str(value), obj.DevPtr);
            end
        end
        
        function result = get.Secondary(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('secondary', 128, obj.DevPtr));
            end
        end
        
        function set.Secondary(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('secondary', num2str(value), obj.DevPtr);
            end
        end
        
        function result = get.SyncTerminalType(obj)
            result = 0;
            if ~isempty(obj.DevPtr)
                result = str2double(obj.getDeviceAttributeRAW('sync_terminal_type', 128, obj.DevPtr));
            end
        end
        
        function set.SyncTerminalType(obj, value)
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('sync_terminal_type', num2str(value), obj.DevPtr);
            end
        end
    end
    
    % Get/Set Methods for Channel Attributes
    methods
        function result = get.TxDPoff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'dp_off_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'dp_off_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxDPoff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'dp_off_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'dp_off_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.TxDPon(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'dp_on_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'dp_on_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxDPon(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'dp_on_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'dp_on_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.TxOff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'off_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'off_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxOff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'off_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'off_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.TxOn(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'on_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'on_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxOn(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'on_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'on_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.TxVCOoff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'vco_off_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'vco_off_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxVCOoff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'vco_off_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'vco_off_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.TxVCOon(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'vco_on_ms', true, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'vco_on_ms', true, obj.DevPtr));
            end
        end
        
        function set.TxVCOon(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'vco_on_ms', value(1), true, obj.DevPtr);
                obj.setAttributeRAW('data1', 'vco_on_ms', value(2), true, obj.DevPtr);
            end
        end
        
        function result = get.RxDPoff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'dp_off_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'dp_off_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxDPoff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'dp_off_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'dp_off_ms', value(2), false, obj.DevPtr);
            end
        end
        
        function result = get.RxDPon(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'dp_on_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'dp_on_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxDPon(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'dp_on_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'dp_on_ms', value(2), false, obj.DevPtr);
            end
        end
        
        function result = get.RxOff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'off_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'off_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxOff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'off_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'off_ms', value(2), false, obj.DevPtr);
            end
        end
        
        function result = get.RxOn(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'on_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'on_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxOn(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'on_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'on_ms', value(2), false, obj.DevPtr);
            end
        end
        
        function result = get.RxVCOoff(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'vco_off_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'vco_off_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxVCOoff(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'vco_off_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'vco_off_ms', value(2), false, obj.DevPtr);
            end
        end
        
        function result = get.RxVCOon(obj)
            result = [0 0];
            if ~isempty(obj.DevPtr)
                result(1) = str2double(obj.getAttributeRAW('data0', 'vco_on_ms', false, obj.DevPtr));
                result(2) = str2double(obj.getAttributeRAW('data1', 'vco_on_ms', false, obj.DevPtr));
            end
        end
        
        function set.RxVCOon(obj, value)
            validateattributes(value, {'double', 'single', 'uint32'}, {'size', [1 2]});
            if obj.ConnectedToDevice
                obj.setAttributeRAW('data0', 'vco_on_ms', value(1), false, obj.DevPtr);
                obj.setAttributeRAW('data1', 'vco_on_ms', value(2), false, obj.DevPtr);
            end
        end
    end
    
    methods (Hidden, Access = protected)
        function setupAXICoreTDD(obj)
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
            obj.setupAXICoreTDD();
        end
    end
end