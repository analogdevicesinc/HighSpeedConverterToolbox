classdef MuxTxFFH < adi.common.Attribute
    properties
        TxFFHMuxSelect = 0
    end

    properties(Hidden)
        MuxTxFFHDeviceNames = {'iio-gen-mux'};
        MuxTxFFHDevLabel = 'mux-txffh';
        MuxTxFFHDevices
    end
        
    methods
        function set.TxFFHMuxSelect(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 0,'<=', 30}, ...
                '', 'TxFFHMuxSelect');
            options = 0:30;
            assert(any(value==options),'TxFFHMuxSelect can be >=0,<=30');
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('mux_select',num2str(value),obj.MuxTxFFHDevices);
            end
            obj.TxFFHMuxSelect = value;
        end
    end

    methods (Hidden, Access = protected)
        function setupInit(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            for dn = 1:length(obj.MuxTxFFHDeviceNames)
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(obj.MuxTxFFHDeviceNames{dn},name)
                        attr = obj.iio_device_get_attr(devPtr,0);
                        if strcmpi(attr,'label')
                            val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                            if strcmpi(val, obj.MuxTxFFHDevLabel)
                                obj.MuxTxFFHDevices = devPtr;
                                break;
                            else
                                continue;
                            end
                        end
                    end
                end
                if isempty(obj.MuxTxFFHDevices)
                   error('%s not found',obj.MuxTxFFHDeviceNames{dn});
                end
            end

            obj.setDeviceAttributeRAW('mux_select',num2str(obj.TxFFHMuxSelect),obj.MuxTxFFHDevices);
        end
    end
end