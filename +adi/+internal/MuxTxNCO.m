classdef MuxTxNCO < adi.common.Attribute
    properties
        TxNCOMuxSelect = 0
    end

    properties(Hidden)
        MuxTxNCODeviceNames = {'iio-gen-mux'};
        MuxTxNCODevLabel = 'mux-Txnco';
        MuxTxNCODevices
    end
        
    methods
        function set.TxNCOMuxSelect(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 0,'<=', 3}, ...
                '', 'TxNCOMuxSelect');
            options = 0:3;
            assert(any(value==options),'TxNCOMuxSelect can be 0,1,2,3');
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('mux_select',num2str(value),obj.MuxTxNCODevices);
            end
            obj.TxNCOMuxSelect = value;
        end
    end

    methods (Hidden, Access = protected)
        function setupInit(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            for dn = 1:length(obj.MuxTxNCODeviceNames)
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(obj.MuxTxNCODeviceNames{dn},name)
                        attr = obj.iio_device_get_attr(devPtr,0);
                        if strcmpi(attr,'label')
                            val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                            if strcmpi(val, obj.MuxTxNCODevLabel)
                                obj.MuxTxNCODevices = devPtr;
                                break;
                            else
                                continue;
                            end
                        end
                    end
                end
                if isempty(obj.MuxTxNCODevices)
                   error('%s not found',obj.MuxTxNCODeviceNames{dn});
                end
            end

            obj.setDeviceAttributeRAW('mux_select',num2str(obj.TxNCOMuxSelect),obj.MuxTxNCODevices);
        end
    end
end