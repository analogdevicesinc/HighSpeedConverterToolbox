classdef MuxRxFFH < adi.common.Attribute
    properties
        RxFFHMuxSelect = 0
    end

    properties(Hidden)
        MuxRxFFHDeviceNames = {'iio-gen-mux'};
        MuxRxFFHDevLabel = 'mux-rxffh';
        MuxRxFFHDevices
    end
        
    methods
        function set.RxFFHMuxSelect(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 0,'<=', 15}, ...
                '', 'RxFFHMuxSelect');
            options = 0:15;
            assert(any(value==options),'RxFFHMuxSelect can be >=0,<=15');
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('mux_select',num2str(value),obj.MuxRxFFHDevices);
            end
            obj.RxFFHMuxSelect = value;
        end
    end

    methods (Hidden, Access = protected)
        function setupInit(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            for dn = 1:length(obj.MuxRxFFHDeviceNames)
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(obj.MuxRxFFHDeviceNames{dn},name)
                        attr = obj.iio_device_get_attr(devPtr,0);
                        if strcmpi(attr,'label')
                            val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                            if strcmpi(val, obj.MuxRxFFHDevLabel)
                                obj.MuxRxFFHDevices = devPtr;
                                break;
                            else
                                continue;
                            end
                        end
                    end
                end
                if isempty(obj.MuxRxFFHDevices)
                   error('%s not found',obj.MuxRxFFHDeviceNames{dn});
                end
            end

            obj.setDeviceAttributeRAW('mux_select',num2str(obj.RxFFHMuxSelect),obj.MuxRxFFHDevices);
        end
    end
end