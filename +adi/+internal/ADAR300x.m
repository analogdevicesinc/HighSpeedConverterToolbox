classdef (Abstract) ADAR300x < adi.common.Attribute & ...
        adi.common.Channel & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    %ADAR300x Beamformer
    properties
        AmpBiasMuteELV = [3,3,3,3];
        AmpBiasOperationalELH = [3, 3, 3, 3];
        AmpBiasOperationalELV = [3, 3, 3, 3]
        AmpBiasResetELV = [3, 3, 3, 3];
        AmpBiasSleepELH = [3, 3, 3, 3];
        AmpBiasSleepELV = [3, 3, 3, 3];
        AmpENMuteELV = [0, 0, 0, 0];
        AmpENOperationalELH = [0, 0, 0, 0];
        AmpENOperationalELV = [0, 0, 0, 0];
        AmpENResetELV = [0, 0, 0, 0];
        AmpENSleepELH = [0, 0, 0, 0];
        AmpENSleepELV = [0, 0, 0, 0];
    end
    
    properties(Hidden, Constant)
        AmpBiasMuteELVAttrs = {...
            'amp_bias_mute_EL0V',...
            'amp_bias_mute_EL1V',...
            'amp_bias_mute_EL2V',...
            'amp_bias_mute_EL3V'};
        AmpBiasOperationalELHAttrs = {...
            'amp_bias_operational_EL0H',...
            'amp_bias_operational_EL1H',...
            'amp_bias_operational_EL2H',...
            'amp_bias_operational_EL3H'};
        AmpBiasOperationalELVAttrs = {...
            'amp_bias_operational_EL0V',...
            'amp_bias_operational_EL1V',...
            'amp_bias_operational_EL2V',...
            'amp_bias_operational_EL3V'};
        AmpBiasResetELVAttrs = {...
            'amp_bias_reset_EL0V',...
            'amp_bias_reset_EL1V',...
            'amp_bias_reset_EL2V',...
            'amp_bias_reset_EL3V'};
        AmpBiasSleepELHAttrs = {...
            'amp_bias_sleep_EL0H',...
            'amp_bias_sleep_EL1H',...
            'amp_bias_sleep_EL2H',...
            'amp_bias_sleep_EL3H'};
        AmpBiasSleepELVAttrs = {...
            'amp_bias_sleep_EL0V',...
            'amp_bias_sleep_EL1V',...
            'amp_bias_sleep_EL2V',...
            'amp_bias_sleep_EL3V'};
        AmpENMuteELVAttrs = {...
            'amp_en_mute_EL0V',...
            'amp_en_mute_EL1V',...
            'amp_en_mute_EL2V',...
            'amp_en_mute_EL3V'};
        AmpENOperationalELHAttrs = {...
            'amp_en_operational_EL0H',...
            'amp_en_operational_EL1H',...
            'amp_en_operational_EL2H',...
            'amp_en_operational_EL3H'};
        AmpENOperationalELVAttrs = {...
            'amp_en_operational_EL0V',...
            'amp_en_operational_EL1V',...
            'amp_en_operational_EL2V',...
            'amp_en_operational_EL3V'};
        AmpENResetELVAttrs = {...
            'amp_en_reset_EL0V',...
            'amp_en_reset_EL1V',...
            'amp_en_reset_EL2V',...
            'amp_en_reset_EL3V'};
        AmpENSleepELHAttrs = {...
            'amp_en_sleep_EL0H',...
            'amp_en_sleep_EL1H',...
            'amp_en_sleep_EL2H',...
            'amp_en_sleep_EL3H'};
        AmpENSleepELVAttrs = {...
            'amp_en_sleep_EL0V',...
            'amp_en_sleep_EL1V',...
            'amp_en_sleep_EL2V',...
            'amp_en_sleep_EL3V'};
    end
    
    properties
        PhasesH = [1, 1, 1, 1, 1, 1, 1, 1];
        PhasesV = [8, 8, 8, 8, 8, 8, 8, 8];
        PowersH = [0, 0, 0, 0, 0, 0, 0, 0];
        PowersV = [0, 0, 0, 0, 0, 0, 0, 0];
%         PropertyType = 'raw';
        UpdateIntfCtrl = 'pin';
    end
    
    properties(Hidden,Constant)
%         PropertyTypeSet = matlab.system.StringSet({ ...
%             'raw','SI'})
%         UpdateIntfCtrlSet = matlab.system.StringSet({ ...
%             'pin','spi'})
    end

    properties(Abstract, Nontunable, Hidden)
        ArrayMapInternal
        deviceNames
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        phyDevName = 'adar3002_csb_0_0';
        % Name of driver instance in device tree
        iioDriverName = 'dev';
        iioDevPHY
        devName = 'adar3002_T0';
        SamplesPerFrame = 0;
    end
    properties(Hidden)
        iioDevices = {};
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties (Hidden)
        beam_devs = {};
        PhasesHChannelNames = {};
        PhasesVChannelNames = {};
        PowersHChannelNames = {};
        PowersVChannelNames = {};
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    methods
        %% Constructor
        function obj = ADAR300x(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
            
            % Check for array sets
            amFound = false;
            dnFound = false;
            for k=1:length(varargin)
               if strcmp(varargin{k},'ArrayMap')
                   amFound = true;
               end
               if strcmp(varargin{k},'deviceNames')
                  dnFound = true; 
               end
            end
            if amFound && ~dnFound || ~amFound && dnFound
               error('When setting ArrayMap or deviceNames, both must be passed constructor');
            end
            obj.updateDefaultDims();
        end
        % Destructor
        function delete(obj)
        end
        
        function updateDefaultDims(obj)
            obj.PhasesH = zeros(size(obj.ArrayMapInternal));
            obj.PhasesV = zeros(size(obj.ArrayMapInternal));
            obj.PowersH = zeros(size(obj.ArrayMapInternal));
            obj.PowersV = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasMuteELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasOperationalELH = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasOperationalELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasResetELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasSleepELH = zeros(size(obj.ArrayMapInternal));
            obj.AmpBiasSleepELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpENMuteELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpENOperationalELH = zeros(size(obj.ArrayMapInternal));
            obj.AmpENOperationalELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpENResetELV = zeros(size(obj.ArrayMapInternal));
            obj.AmpENSleepELH = zeros(size(obj.ArrayMapInternal));
            obj.AmpENSleepELV = zeros(size(obj.ArrayMapInternal));
            
%             obj.PropertyType = repmat({'raw'},1,length(obj.deviceNames));
            obj.UpdateIntfCtrl = repmat({'spi'},1,length(obj.deviceNames));
        end
        
        function val = CheckDims(obj,attr,val)
            assert(isequal(size(val),size(obj.ArrayMapInternal)), ...
                [attr ' must be of size [' size(obj.ArrayMapInternal,1)...
                'x' size(obj.ArrayMapInternal,2) ']']);
        end
        
        % Check UpdateIntfCtrl
        function set.UpdateIntfCtrl(obj, values)
            assert(isequal(size(values),[1,length(obj.deviceNames)]),...
                sprintf(...
                'UpdateIntfCtrl must be a cell array of size [1x%d]',...
                length(obj.deviceNames)));
            for k=1:length(obj.deviceNames)
               if ~strcmp(values{k},'spi') && ~strcmp(values{k},'pin')
                  error('Individual values of UpdateIntfCtrl must be pin or spi');
               end
            end
            if obj.ConnectedToDevice
                for k=1:length(obj.deviceNames)
                    %Debug
                    if isempty(obj.iioDevices{k})
                       continue 
                    end
                    obj.setDeviceAttributeRAW('update_intf_ctrl',...
                            values{k},obj.iioDevices{k});
                end
            end
            obj.UpdateIntfCtrl = values;
        end
        
        % Check PhasesH
        function set.PhasesH(obj, values)
            if obj.ConnectedToDevice
                obj.setAllRelatedChannelAttrs('raw',values,...
                    obj.PhasesHChannelNames,true,obj.iioDevices);
            end
            obj.PhasesH = values;
        end
        % Check PhasesV
        function set.PhasesV(obj, values)
            if obj.ConnectedToDevice
                obj.setAllRelatedChannelAttrs('raw',values,...
                    obj.PhasesVChannelNames,true,obj.iioDevices);
            end
            obj.PhasesV = values;
        end
        % Check PowersH
        function set.PowersH(obj, values)
            if obj.ConnectedToDevice
                obj.setAllRelatedChannelAttrs('raw',values,...
                    obj.PowersHChannelNames,true,obj.iioDevices);
            end
            obj.PowersH = values;
        end
        % Check PowersV
        function set.PowersV(obj, values)
            if obj.ConnectedToDevice
                obj.setAllRelatedChannelAttrs('raw',values,...
                    obj.PowersVChannelNames,true,obj.iioDevices);
            end
            obj.PowersV = values;
        end
        % Check AmpBiasMuteELV
        function set.AmpBiasMuteELV(obj, value)
            obj.AmpBiasMuteELV = obj.CheckDims('AmpBiasMuteELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasMuteELVAttrs,...
                    obj.AmpBiasMuteELV,obj.iioDevices);
            end
        end
        % Check AmpBiasOperationalELH
        function set.AmpBiasOperationalELH(obj, value)
            obj.AmpBiasOperationalELH = obj.CheckDims('AmpBiasOperationalELH', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasOperationalELHAttrs,...
                    obj.AmpBiasOperationalELH,obj.iioDevices);
            end
        end
        % Check AmpBiasOperationalELV
        function set.AmpBiasOperationalELV(obj, value)
            obj.AmpBiasOperationalELV = obj.CheckDims('AmpBiasOperationalELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasOperationalELVAttrs,...
                    obj.AmpBiasOperationalELV,obj.iioDevices);
            end
        end
        % Check AmpBiasResetELV
        function set.AmpBiasResetELV(obj, value)
            obj.AmpBiasResetELV = obj.CheckDims('AmpBiasResetELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasResetELVAttrs,...
                    obj.AmpBiasResetELV,obj.iioDevices);
            end
        end
        % Check AmpBiasSleepELH
        function set.AmpBiasSleepELH(obj, value)
            obj.AmpBiasSleepELH = obj.CheckDims('AmpBiasSleepELH', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasSleepELHAttrs,...
                    obj.AmpBiasSleepELH,obj.iioDevices);
            end
        end
        % Check AmpBiasSleepELV
        function set.AmpBiasSleepELV(obj, value)
            obj.AmpBiasSleepELV = obj.CheckDims('AmpBiasSleepELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpBiasSleepELVAttrs,...
                    obj.AmpBiasSleepELV,obj.iioDevices);
            end
        end
        % Check AmpENMuteELV
        function set.AmpENMuteELV(obj, value)
            obj.AmpENMuteELV = obj.CheckDims('AmpENMuteELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENMuteELVAttrs,...
                    obj.AmpENMuteELV,obj.iioDevices);
            end
        end
        % Check AmpENOperationalELH
        function set.AmpENOperationalELH(obj, value)
            obj.AmpENOperationalELH = obj.CheckDims('AmpENOperationalELH', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENOperationalELHAttrs,...
                    obj.AmpENOperationalELH,obj.iioDevices);
            end
        end
        % Check AmpENOperationalELV
        function set.AmpENOperationalELV(obj, value)
            obj.AmpENOperationalELV = obj.CheckDims('AmpENOperationalELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENOperationalELVAttrs,...
                    obj.AmpENOperationalELV,obj.iioDevices);
            end
        end
        % Check AmpENResetELV
        function set.AmpENResetELV(obj, value)
            obj.AmpENResetELV = obj.CheckDims('AmpENResetELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENResetELVAttrs,...
                    obj.AmpENResetELV,obj.iioDevices);
            end
        end    
        % Check AmpENSleepELH
        function set.AmpENSleepELH(obj, value)
            obj.AmpENSleepELH = obj.CheckDims('AmpENSleepELH', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENSleepELHAttrs,...
                    obj.AmpENSleepELH,obj.iioDevices);
            end
        end
        % Check AmpENSleepELV
        function set.AmpENSleepELV(obj, value)
            obj.AmpENSleepELV = obj.CheckDims('AmpENSleepELV', value);
            if obj.ConnectedToDevice
                obj.setAllRelatedDevAttrs(obj.AmpENSleepELVAttrs,...
                    obj.AmpENSleepELV,obj.iioDevices);
            end
        end
    end
    
    %% API Functions
    
    methods (Hidden)
        function values = getAllRelatedChannelAttrs(obj,attr,channels,output,devices)
            % Check dimensions 
            numRows = size(obj.ArrayMapInternal,1);
            numCols = size(obj.ArrayMapInternal,2);
            
            values = zeros(numRows,numCols);
            
            numAttrs = length(channels);
            for r = 1:numRows
                for c = 1:numCols
                    indx = obj.ArrayMapInternal(r,c);
                    deviceIndx = ceil(indx/numAttrs);
                    attrIndx = mod(indx-1,numAttrs) + 1;
                    
                    %DEBUG
                    if isempty(devices{deviceIndx})
                        continue;
                    end
                    
                    values(r,c) = ...
                        obj.getAttributeLongLong(channels{attrIndx},attr,...
                            output,devices{deviceIndx});
                end
            end           
        end
        
        function values = getAllRelatedDevAttrs(obj,attrs,devices)
            % Check dimensions 
            numRows = size(obj.ArrayMapInternal,1);
            numCols = size(obj.ArrayMapInternal,2);
            
            values = zeros(numRows,numCols);
            
            numAttrs = length(attrs);
            for r = 1:numRows
                for c = 1:numCols
                    indx = obj.ArrayMapInternal(r,c);
                    deviceIndx = ceil(indx/numAttrs);
                    attrIndx = mod(indx-1,numAttrs) + 1;
                    
                    %DEBUG
                    if isempty(devices{deviceIndx})
                        continue;
                    end                    
                    values(r,c) = ...
                        obj.getDeviceAttributeLongLong(attrs{attrIndx},...
                            devices{deviceIndx});
                end
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
            % Flags
            obj.needsTeardown = true;
            obj.ConnectedToDevice = true;
            % Call final stage
            setupInit(obj);
        end
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
        end
        function setAllRelatedDevAttrs(obj,attrs,values,devices)
            
            % Check dimensions 
            numRows = size(obj.ArrayMapInternal,1);
            numCols = size(obj.ArrayMapInternal,2);
            assert(isequal(size(values),[numRows,numCols]),...
                sprintf('must of size [%dx%d]',numRows,numCols));
            
            numAttrs = length(attrs);
            for r = 1:numRows
                for c = 1:numCols
                    indx = obj.ArrayMapInternal(r,c);
                    deviceIndx = ceil(indx/numAttrs);
                    attrIndx = mod(indx-1,numAttrs) + 1;
                    
                    %DEBUG
                    if isempty(devices{deviceIndx})
                        if values(r,c)>0
                            error('Something wrong');
                        end
                        continue;
                    end
%                     fprintf("%d %d %s\n",r,c,attrs{attrIndx});

                    
                    obj.setDeviceAttributeLongLong(attrs{attrIndx},...
                        values(r,c),devices{deviceIndx});
                end
            end  
        end
        
        function setAllRelatedChannelAttrs(obj,attr,values,channels,output,devices)
                        
            tolerance = 0;
            
            % Check dimensions 
            numRows = size(obj.ArrayMapInternal,1);
            numCols = size(obj.ArrayMapInternal,2);
            assert(isequal(size(values),[numRows,numCols]),...
                sprintf('Input must of size [%dx%d]',numRows,numCols));
            
            numAttrs = length(channels);
            for r = 1:numRows
                for c = 1:numCols
                    indx = obj.ArrayMapInternal(r,c);
                    deviceIndx = ceil(indx/numAttrs);
                    attrIndx = mod(indx-1,numAttrs) + 1;
                    
                    %DEBUG
                    if isempty(devices{deviceIndx})
                        if values(r,c)>0
                            error('Something wrong');
                        end
                        continue;
                    end
                    
                    obj.setAttributeLongLong(channels{attrIndx},attr,...
                        values(r,c),output,tolerance,devices{deviceIndx});
                end
            end           
        end
        

        
        function channel_names = get_channel_names_for_prop(obj,phydevs,rxs)
            for pindx = 1:length(phydevs)
                
                %DEBUG
                if isempty(phydevs{pindx})
                    continue;
                end
                
                chanCount = obj.iio_device_get_channels_count(phydevs{pindx});
                channel_names = {};
                for c = 1:chanCount
                    chanPtr = obj.iio_device_get_channel(phydevs{pindx},c-1);
                    status = cPtrCheck(obj,chanPtr);
                    if status < 0
                        continue;
                    end
                    id = obj.iio_channel_get_id(chanPtr);
                    attrCount = obj.iio_channel_get_attrs_count(chanPtr);
                    for a = 1:attrCount
                        attr = obj.iio_channel_get_attr(chanPtr, a-1);
                        if strcmpi(attr,'label')
                            [~, label] = iio_channel_attr_read(obj,chanPtr,attr,64);
                            if ~isempty(regexp(label,rxs, 'once'))
                                channel_names = [channel_names(:)', {id}];
                            end
                        end
                    end
                end
            end
        end
        
        function flag = isInactivePropertyImpl(obj, prop)
            flag = isInactivePropertyImpl@adi.common.RxTx(obj,prop);
            if isprop(obj,'EnabledChannels')
                flag = flag || strcmpi(prop,'EnabledChannels');
            end
        end
        
        function setupInit(obj)
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            obj.iioDevices = cell(1,length(obj.deviceNames));
            for dn = 1:length(obj.deviceNames)
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(obj.deviceNames{dn},name)
                        obj.iioDevices{dn} = devPtr;
                    end
                end
%                 if isempty(obj.iioDevices{dn})
%                    error('%s not found',obj.deviceNames{dn});
%                 end
            end
            
            % Get all phase related channels
            obj.PhasesHChannelNames = obj.get_channel_names_for_prop(obj.iioDevices, "BEAM\d_H_EL\d_DELAY");
            obj.PhasesVChannelNames = obj.get_channel_names_for_prop(obj.iioDevices, "BEAM\d_V_EL\d_DELAY");
            obj.PowersHChannelNames = obj.get_channel_names_for_prop(obj.iioDevices, "BEAM\d_H_EL\d_ATTENUATION");
            obj.PowersVChannelNames = obj.get_channel_names_for_prop(obj.iioDevices, "BEAM\d_V_EL\d_ATTENUATION");

            % Set props
            obj.setAllRelatedDevAttrs(obj.AmpBiasMuteELVAttrs,obj.AmpBiasMuteELV,obj.iioDevices);
            obj.setAllRelatedDevAttrs(obj.AmpBiasOperationalELHAttrs,obj.AmpBiasOperationalELH,obj.iioDevices);            
            obj.setAllRelatedDevAttrs(obj.AmpBiasOperationalELVAttrs,obj.AmpBiasOperationalELV,obj.iioDevices);            
            obj.setAllRelatedDevAttrs(obj.AmpBiasResetELVAttrs,obj.AmpBiasResetELV,obj.iioDevices);            
            obj.setAllRelatedDevAttrs(obj.AmpBiasSleepELHAttrs,obj.AmpBiasSleepELH,obj.iioDevices);
            obj.setAllRelatedDevAttrs(obj.AmpBiasSleepELVAttrs,obj.AmpBiasSleepELV,obj.iioDevices);
            obj.setAllRelatedDevAttrs(obj.AmpENMuteELVAttrs,obj.AmpENMuteELV,obj.iioDevices);  
            obj.setAllRelatedDevAttrs(obj.AmpENOperationalELHAttrs,obj.AmpENOperationalELH,obj.iioDevices); 
            obj.setAllRelatedDevAttrs(obj.AmpENOperationalELVAttrs,obj.AmpENOperationalELV,obj.iioDevices);
            obj.setAllRelatedDevAttrs(obj.AmpENResetELVAttrs,obj.AmpENResetELV,obj.iioDevices);
            obj.setAllRelatedDevAttrs(obj.AmpENSleepELHAttrs,obj.AmpENSleepELH,obj.iioDevices);            
            obj.setAllRelatedDevAttrs(obj.AmpENSleepELVAttrs,obj.AmpENSleepELV,obj.iioDevices);            
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
    end
end



