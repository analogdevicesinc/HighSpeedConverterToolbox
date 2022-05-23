classdef MuxRxNCO < adi.common.Attribute
    properties
        RxNCOMuxSelect = 0
    end

    properties(Hidden)
        MuxRxNCODeviceNames = {'iio-gen-mux'};
        MuxRxNCODevLabel = 'mux-rxnco';
        MuxRxNCODevices
    end
        
    methods
        function set.RxNCOMuxSelect(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 0,'<=', 3}, ...
                '', 'RxNCOMuxSelect');
            options = 0:3;
            assert(any(value==options),'RxNCOMuxSelect can be 0,1,2,3');
            if obj.ConnectedToDevice
                obj.setDeviceAttributeRAW('mux_select',num2str(value),obj.MuxRxNCODevices);
            end
            obj.RxNCOMuxSelect = value;
        end
    end

    methods (Hidden, Access = protected)
        function setupInit(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            for dn = 1:length(obj.MuxRxNCODeviceNames)
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(obj.MuxRxNCODeviceNames{dn},name)
                        attr = obj.iio_device_get_attr(devPtr,0);
                        if strcmpi(attr,'label')
                            val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                            if strcmpi(val, obj.MuxRxNCODevLabel)
                                obj.MuxRxNCODevices = devPtr;
                                break;
                            else
                                continue;
                            end
                        end
                    end
                end
                if isempty(obj.MuxRxNCODevices)
                   error('%s not found',obj.MuxRxNCODeviceNames{dn});
                end
            end

            obj.setDeviceAttributeRAW('mux_select',num2str(obj.RxNCOMuxSelect),obj.MuxRxNCODevices);
        end
    end
end