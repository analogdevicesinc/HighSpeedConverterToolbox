classdef Single < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    
    properties (Constant)
        BIAS_CODE_TO_VOLTAGE_SCALE = -0.018824
    end
    
    properties
        %ChipID Chip ID
        %   String identifying desired chip select option of 
        %   ADAR100. This is based on the jumper configuration
        %   if the EVAL-ADAR100 is used. This string is the label
        %   coinciding with each chip select and is typically in the
        %   form csb*_chip*, e.g., csb1_chip1. When an ADAR1000 array
        %   is instantiated, the array class will handle the instantiation 
        %   of individual adar1000 handles.
        ChipID = {'csb1_chip1'};
        ArrayElementMap = [1 2 3 4];
        ChannelElementMap = [2 1 4 3];
    end
    
    properties (Dependent)
        NumADAR1000s
    end
    
    properties
        ElementR
        ElementC
    end
    
    properties
        Channels
        
    end
    
    properties(Nontunable, Hidden)
%         Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
%         phyDevName = 'adar1000';
        % Name of driver instance in device tree
        iioDriverName = 'adar1000';
%         iioDevPHY
        devName = 'adar1000';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden)
        ChipIDHandle
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
%         channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties
        % Device Attributes
        Mode = {'Rx'}
        StateTxOrRx = {'Rx'}
        RxEnable = true
        TxEnable = false
        LNABiasOutEnable = true
        LNABiasOn = -4.80012
        BeamMemEnable = true
        BiasDACEnable = true
        BiasDACMode = {'On'}
        BiasMemEnable = true
        CommonMemEnable = true
        CommonRxBeamState = 0
        CommonTxBeamState = 0
        ExternalTRPin = {'Pos'}
        ExternalTRPolarity = false
        
        % Channel Attributes
        DetectorEnable = true(1, 4)
        DetectorPower = 255*ones(1, 4)
        PABiasOff = -4.80012*ones(1, 4)
        PABiasOn = -4.80012*ones(1, 4)
        RxAttn = true(1, 4)
        RxBeamState = zeros(1, 4)
        RxPowerDown = false(1, 4)
        RxGain = ones(1, 4)
        RxPhase = zeros(1, 4)
        TxAttn = true(1, 4)
        TxBeamState = zeros(1, 4)
        TxPowerDown = false(1, 4)
        TxGain = ones(1, 4)
        TxPhase = zeros(1, 4)
    end
    
    %% API Functions
    methods
        %% Constructor
        function obj = Single(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
            % Check that the number of chips matches for all the inputs
            if ((numel(obj.ChipID)*4) ~= numel(obj.ArrayElementMap))
                error('Expected equal number of elements in ArrayElementMap and 4*numel(ChipIDs)');
            end
            if (numel(obj.ArrayElementMap) ~= numel(obj.ChannelElementMap))
                error('Expected equal number of elements in ArrayElementMap and ChannelElementMap');
            end
        end
        % Destructor
        function delete(obj)
        end
        
        function result = getAllChipsChannelAttribute(obj, attr, isOutput, AttrClass)
            result = zeros(size(obj.ChannelElementMap));
            for d = 1:numel(obj.ChipID)
                for c = 0:3
                    channel = sprintf('voltage%d', c);
                    if strcmpi(AttrClass, 'logical')
                        result(d, c+1) = obj.getAttributeBool(channel, attr, isOutput, obj.ChipIDHandle{d});
                    elseif strcmpi(AttrClass, 'raw')
                        result(d, c+1) = str2double(obj.getAttributeRAW(channel, attr, isOutput, obj.ChipIDHandle{d}));
                    elseif strcmpi(AttrClass, 'int32') || strcmpi(AttrClass, 'int64')
                        result(d, c+1) = obj.getAttributeLongLong(channel, attr, isOutput, obj.ChipIDHandle{d});
                    elseif strcmpi(AttrClass, 'double')
                        result(d, c+1) = obj.getAttributeDouble(channel, attr, isOutput, obj.ChipIDHandle{d});
                    end
                end
            end
        end
        
        function setAllChipsChannelAttribute(obj, values, attr, isOutput, AttrClass)
            if strcmpi(AttrClass, 'logical')
                validateattributes(values, {'logical'},...
                    {'size', size(obj.ChannelElementMap)});
            elseif strcmpi(AttrClass, 'raw') || ...
                    strcmpi(AttrClass, 'int32') || strcmpi(AttrClass, 'int64')
                validateattributes(values, {'numeric', 'uint32'},...
                    {'size', size(obj.ChannelElementMap)});
            elseif strcmpi(AttrClass, 'double')
                validateattributes(values, {'numeric', 'double'},...
                    {'size', size(obj.ChannelElementMap)});
            end
            
            if obj.ConnectedToDevice
                for dev = 1:numel(obj.ChipID)
                    for ch = 1:4
                        channel = sprintf('voltage%d', ch-1);
                        if strcmpi(AttrClass, 'logical')
                            obj.setAttributeBool(channel, attr, ...
                                values(dev, ch), isOutput, obj.ChipIDHandle{dev});
                        elseif strcmpi(AttrClass, 'raw')
                            obj.setAttributeRAW(channel, attr, ...
                                values(dev, ch), isOutput, obj.ChipIDHandle{dev});
                        elseif strcmpi(AttrClass, 'int32') || strcmpi(AttrClass, 'int64')
                            tol = 0;
                            obj.setAttributeLongLong(channel, attr, ...
                                values(dev, ch), isOutput, tol, obj.ChipIDHandle{dev});
                        elseif strcmpi(AttrClass, 'double')
                            tol = sqrt(eps);
                            obj.setAttributeDouble(channel, attr, ...
                                values(dev, ch), isOutput, tol, obj.ChipIDHandle{dev});
                        end
                    end
                end
            end
        end
        
        function result = getAllChipsDeviceAttributeRAW(obj, attr, isBooleanAttr)
            temp = zeros(size(obj.ChipID));
            for ii = 1:numel(obj.ChipID)
                if isBooleanAttr
                    temp(ii) = obj.getDeviceAttributeRAW(attr, 128, obj.ChipIDHandle{ii});
                else
                    temp(ii) = str2num(obj.getDeviceAttributeRAW(attr, 128, obj.ChipIDHandle{ii}));
                end
            end
            if isBooleanAttr
                result = logical(temp);
            else
                result = temp;
            end
        end
        
        function setAllChipsDeviceAttributeRAW(obj, attr, values, isBooleanAttr)
            if isBooleanAttr
                temp = char(ones(size(obj.ChipID)) * '1');
                for ii = 1:size(values, 1)
                    temp(ii, :) = strrep(values(ii, :), ' ', '');
                end
                values = temp;
                validateattributes(values, {'char'}, {'size', size(obj.ChipID)});
            end
            
            if obj.ConnectedToDevice
                for ii = 1:numel(obj.ChipID)
                    if isBooleanAttr
                        obj.setDeviceAttributeRAW(attr, values(ii), obj.ChipIDHandle{ii});
                    else
                        obj.setDeviceAttributeRAW(attr, values{ii}, obj.ChipIDHandle{ii});
                    end
                end
            end
        end        
    end
    
    % Get/Set Methods for Device Attributes
    methods
        function result = get.Mode(obj)
            result = cell(size(obj.ChipID));
            result(:) = {'Rx'};
            RxEnableMat = obj.RxEnable;
            TxEnableMat = obj.TxEnable;
            StateTxOrRxMat = obj.StateTxOrRx;
            if ~isempty(obj.ChipIDHandle)
                for ii = 1:numel(obj.ChipID)
                    if (RxEnableMat(ii) && ~TxEnableMat(ii))
                        if strcmp(StateTxOrRxMat(ii), 'Rx')
                            result(ii) = {'Rx'};
                        else
                            result(ii) = {'Disabled'};
                        end
                    elseif (TxEnableMat(ii) && ~RxEnableMat(ii))
                        if strcmp(StateTxOrRxMat(ii), 'Tx')
                            result(ii) = {'Tx'};
                        else
                            result(ii) = {'Disabled'};
                        end
                    elseif (TxEnableMat(ii) && RxEnableMat(ii))
                        result(ii) = StateTxOrRxMat(ii);
                    else
                        result(ii) = {'Disabled'};
                    end
                end
            end
        end
        
        function set.Mode(obj, values)
            RxEnableMat = char(ones(size(values)) * '0');
            TxEnableMat = char(ones(size(values)) * '0');
            StateTxOrRxMat = cell(size(values));
            StateTxOrRxMat(:) = {'Rx'};
            for ii = 1:numel(values)
                if ~(strcmpi(values{ii}, 'Tx') || strcmpi(values{ii}, 'Rx') ...
                         || strcmpi(values{ii}, 'Disabled'))
                    error('Expected ''Tx'' or ''Rx'' or ''Disabled'' for property, Mode');
                end
                if ~strcmpi(values{ii}, 'Disabled')
%                     RxEnableMat(ii) = false;
%                     TxEnableMat(ii) = false;
%                 else
                    StateTxOrRxMat{ii} = values{ii};
                    if strcmpi(values(ii), 'Tx')
%                         RxEnableMat(ii) = false;
                        TxEnableMat(ii) = '1';                        
                    else
                        RxEnableMat(ii) = '1';
%                         TxEnableMat(ii) = false;
                    end
                end
            end
            obj.RxEnable = RxEnableMat;
            obj.TxEnable = TxEnableMat;
            obj.StateTxOrRx = StateTxOrRxMat;
        end
        
        function result = get.RxEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'rx_en', true);
            end
        end
        
        function set.RxEnable(obj, values)
            setAllChipsDeviceAttributeRAW(obj, 'rx_en', num2str(values), true);
        end
        
        function result = get.TxEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'tx_en', true);
            end
        end
        
        function set.TxEnable(obj, values)
            setAllChipsDeviceAttributeRAW(obj, 'tx_en', num2str(values), true);
        end
        
        function result = get.LNABiasOutEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'lna_bias_out_enable', true);
            end
        end
        
        function set.LNABiasOutEnable(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'lna_bias_out_enable', num2str(values), true);
        end
        
        function result = get.LNABiasOn(obj)
            result = 255*obj.BIAS_CODE_TO_VOLTAGE_SCALE*ones(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'lna_bias_on', false);
                result = obj.BIAS_CODE_TO_VOLTAGE_SCALE*result;
            end            
        end
        
        function set.LNABiasOn(obj, values)
            dac_codes = int32(values / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            dac_codes = convertStringsToChars(string(dac_codes));
            setAllChipsDeviceAttributeRAW(obj, 'lna_bias_on', dac_codes, false);
        end
        
        function result = get.StateTxOrRx(obj)
            result = cell(size(obj.ChipID));
            result(:) = {'Rx'};
            if ~isempty(obj.ChipIDHandle)
                temp = getAllChipsDeviceAttributeRAW(obj,'tr_spi', true);
                for ii = 1:numel(temp)
                    if temp(ii)
                        result(ii) = {'Tx'};
                    else
                        result(ii) = {'Rx'};
                    end
                end
            end
        end
        
        function set.StateTxOrRx(obj, values)
            ivalues = char(ones(size(values)) * '0');
            for ii = 1:numel(values)
                if ~(strcmpi(values(ii), 'Tx') || strcmpi(values(ii), 'Rx'))
                    error('Expected ''Tx'' or ''Rx'' for property, StateTxOrRx');
                end
                if strcmpi(values(ii), 'Tx')
                    ivalues(ii) = '1';
                else
                    ivalues(ii) = '0';
                end
            end
            setAllChipsDeviceAttributeRAW(obj, 'tr_spi', ivalues, true);
        end
        
        function result = get.BeamMemEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'beam_mem_enable', true);
            end
        end
        
        function set.BeamMemEnable(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'beam_mem_enable', num2str(values), true);
        end
        
        function result = get.BiasDACEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'bias_enable', true);
            end
        end
        
        function set.BiasDACEnable(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'bias_enable', num2str(values), true);
        end
        
        function result = get.BiasDACMode(obj)
            result = cell(size(obj.ChipID));
            result(:) = {'On'};
            if ~isempty(obj.ChipIDHandle)
                temp = getAllChipsDeviceAttributeRAW(obj,'bias_ctrl', true);
                for ii = 1:numel(temp)
                    if temp(ii)
                        result(ii) = {'Toggle'};
                    else
                        result(ii) = {'On'};
                    end
                end
            end
        end
        
        function set.BiasDACMode(obj, values)
            ivalues = char(ones(size(values)) * '0');
            for ii = 1:numel(values)
                if ~(strcmpi(values(ii), 'Tx') || strcmpi(values(ii), 'Rx'))
                    error('Expected ''Toggle'' or ''On'' for property, BiasDACMode');
                end
                if strcmpi(values(ii), 'Toggle')
                    ivalues(ii) = '1';
                else
                    ivalues(ii) = '0';
                end
            end
            setAllChipsDeviceAttributeRAW(obj, 'bias_ctrl', ivalues, true);
        end
        
        function result = get.BiasMemEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'bias_mem_enable', true);
            end
        end
        
        function set.BiasMemEnable(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'bias_mem_enable', num2str(values), true);
        end
        
        function result = get.CommonMemEnable(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'common_mem_enable', true);
            end
        end
        
        function set.CommonMemEnable(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'common_mem_enable', num2str(values), true);
        end
        
        function result = get.CommonRxBeamState(obj)
            result = zeros(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'static_rx_beam_pos_load', false);
            end            
        end
        
        function set.CommonRxBeamState(obj, values)
            values = int32(values);
            values = convertStringsToChars(string(values));
            setAllChipsDeviceAttributeRAW(obj, 'static_rx_beam_pos_load', values, false);
        end
        
        function result = get.CommonTxBeamState(obj)
            result = zeros(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'static_tx_beam_pos_load', false);
            end            
        end
        
        function set.CommonTxBeamState(obj, values)
            values = int32(values);
            values = convertStringsToChars(string(values));
            setAllChipsDeviceAttributeRAW(obj, 'static_tx_beam_pos_load', values, false);
        end
        
        function result = get.ExternalTRPin(obj)
            result = cell(size(obj.ChipID));
            result(:) = {'Pos'};
            if ~isempty(obj.ChipIDHandle)
                temp = getAllChipsDeviceAttributeRAW(obj,'sw_drv_tr_mode_sel', true);
                for ii = 1:numel(temp)
                    if temp(ii)
                        result(ii) = {'Neg'};
                    else
                        result(ii) = {'Pos'};
                    end
                end
            end
        end
        
        function set.ExternalTRPin(obj, values)
            ivalues = char(ones(size(values)) * '0');
            for ii = 1:numel(values)
                if ~(strcmpi(values(ii), 'Tx') || strcmpi(values(ii), 'Rx'))
                    error('Expected ''Toggle'' or ''On'' for property, BiasDACMode');
                end
                if strcmpi(values(ii), 'Neg')
                    ivalues(ii) = '1';
                else
                    ivalues(ii) = '0';
                end
            end
            setAllChipsDeviceAttributeRAW(obj, 'sw_drv_tr_mode_sel', ivalues, true);
        end
        
        function result = get.ExternalTRPolarity(obj)
            result = true(size(obj.ChipID));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsDeviceAttributeRAW(obj,'sw_drv_tr_state', true);
            end
        end
        
        function set.ExternalTRPolarity(obj, values)            
            setAllChipsDeviceAttributeRAW(obj, 'sw_drv_tr_state', num2str(values), true);
        end
    end
    
    methods
        function LatchRxSettings(obj)
            setAllChipsDeviceAttributeRAW(obj, 'rx_load_spi', ones(size(obj.ChipID)), true);
        end
        
        function LatchTxSettings(obj)
            setAllChipsDeviceAttributeRAW(obj, 'Tx_load_spi', ones(size(obj.ChipID)), true);
        end
    end
    
    % Get/Set Methods for Channel Attributes
    methods
        function result = get.DetectorEnable(obj)
            result = true(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'detector_en', true, 'logical');
            end
        end
        
        function set.DetectorEnable(obj, values)
            setAllChipsChannelAttribute(obj, values, 'detector_en', true, 'logical');
        end
        
        function result = get.DetectorPower(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                obj.DetectorEnable = true(size(obj.ChannelElementMap));
                result = getAllChipsChannelAttribute(obj, 'raw', true, 'raw');
                obj.DetectorEnable = false(size(obj.ChannelElementMap));
            end
        end
        
        function result = get.PABiasOff(obj)
            result = 255*ones(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                dac_code = getAllChipsChannelAttribute(obj, 'pa_bias_off', true, 'int32');
                result = dac_code*obj.BIAS_CODE_TO_VOLTAGE_SCALE;
            end
        end
        
        function set.PABiasOff(obj, values)
            dac_codes = int32(values / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            setAllChipsChannelAttribute(obj, dac_codes, 'pa_bias_off', true, 'int32');
        end
        
        function result = get.PABiasOn(obj)
            result = 255*ones(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                dac_code = getAllChipsChannelAttribute(obj, 'pa_bias_on', true, 'int32');
                result = dac_code*obj.BIAS_CODE_TO_VOLTAGE_SCALE;
            end
        end
        
        function set.PABiasOn(obj, values)
            dac_codes = int64(values / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            setAllChipsChannelAttribute(obj, dac_codes, 'pa_bias_on', true, 'int32');
        end
        
        function result = get.RxAttn(obj)
            result = true(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = ~getAllChipsChannelAttribute(obj, 'attenuation', false, 'logical');
            end
        end
        
        function set.RxAttn(obj, values)
            setAllChipsChannelAttribute(obj, ~values, 'attenuation', false, 'logical');
        end
        
        function result = get.RxBeamState(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'beam_pos_load', false, 'int32');
            end
        end
        
        function set.RxBeamState(obj, values)
            validateattributes( values, { 'double', 'single', 'uint32'}, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'RxBeamState');
            setAllChipsChannelAttribute(obj, values, 'beam_pos_load', false, 'int32');
        end
        
        function result = get.RxPowerDown(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = ~getAllChipsChannelAttribute(obj, 'powerdown', false, 'logical');
            end
        end
        
        function set.RxPowerDown(obj, values)
            setAllChipsChannelAttribute(obj, ~values, 'powerdown', false, 'logical');
        end
        
        function result = get.RxGain(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'hardwaregain', false, 'double');
            end
        end
        
        function set.RxGain(obj, values)
            setAllChipsChannelAttribute(obj, values, 'hardwaregain', false, 'double');
        end
        
        function result = get.RxPhase(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'phase', false, 'double');
            end
        end
        
        function set.RxPhase(obj, values)
            setAllChipsChannelAttribute(obj, values, 'phase', false, 'double');
        end
        
        function result = get.TxAttn(obj)
            result = true(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = ~getAllChipsChannelAttribute(obj, 'attenuation', true, 'logical');
            end
        end
        
        function set.TxAttn(obj, values)
            setAllChipsChannelAttribute(obj, ~values, 'attenuation', true, 'logical');
        end
        
        function result = get.TxBeamState(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'beam_pos_load', true, 'int32');
            end
        end
        
        function set.TxBeamState(obj, values)
            validateattributes( values, { 'double', 'single', 'uint32'}, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'RxBeamState');
            setAllChipsChannelAttribute(obj, values, 'beam_pos_load', true, 'int32');
        end
        
        function result = get.TxPowerDown(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = ~getAllChipsChannelAttribute(obj, 'powerdown', true, 'logical');
            end
        end
        
        function set.TxPowerDown(obj, values)
            setAllChipsChannelAttribute(obj, ~values, 'powerdown', true, 'logical');
        end
        
        function result = get.TxGain(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'hardwaregain', true, 'double');
            end
        end
        
        function set.TxGain(obj, values)
            setAllChipsChannelAttribute(obj, values, 'hardwaregain', true, 'double');
        end
        
        function result = get.TxPhase(obj)
            result = zeros(size(obj.ChannelElementMap));
            if ~isempty(obj.ChipIDHandle)
                result = getAllChipsChannelAttribute(obj, 'phase', true, 'double');
            end
        end
        
        function set.TxPhase(obj, values)
            setAllChipsChannelAttribute(obj, values, 'phase', true, 'double');
        end
    end
    
    methods    
        function SaveRxBeam(obj, ChipIDIndx, ChIndx, State, Attn, Gain, Phase)
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'State');
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',127}, ...
                '', 'Gain');             
            obj.setAttributeRAW(sprintf('voltage%d', ChIndx), ...
                'beam_pos_save', sprintf('%d, %d, %d, %f', State, 1 - int32(Attn), Gain, Phase), false, obj.ChipIDHandles{ChipIDIndx});
        end
        
        function SaveTxBeam(obj, ChipIDIndx, ChIndx, State, Attn, Gain, Phase)
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'State');
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',127}, ...
                '', 'Gain');             
            obj.setAttributeRAW(sprintf('voltage%d', ChIndx), ...
                'beam_pos_save', sprintf('%d, %d, %d, %f', State, 1 - int32(Attn), Gain, Phase), true, obj.ChipIDHandles{ChipIDIndx});
        end
    end
    
    methods
        function result = get.NumADAR1000s(obj)
            result = numel(obj.ChipID);
        end
    end
    
    methods (Hidden, Access = protected)
        function setChipID(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            obj.ChipIDHandle = {};
            for ChipIDIndx = 1:obj.NumADAR1000s
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
                                if contains(obj.ChipID{ChipIDIndx},val)
                                    obj.ChipIDHandle = [obj.ChipIDHandle(:)', {devPtr}];
                                    found = true;
                                end
                            end
                        end
                    end
                end            
                if ~found
                    error('Unable to locate %s in context',obj.ChipID{ChipIDIndx});
                end
            end
        end
        
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
            % Do writes directly to hardware without using set methods.
            % This is required since Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            % Check ArrayElementMap and ChannelElementMap have the same
            % elements
            if (numel(intersect(obj.ArrayElementMap, obj.ChannelElementMap)) ~= ...
                    numel(obj.ChannelElementMap))
                error('ChannelElementMap needs to contain the same elements as ArrayElementMap');
            end
            % Check dimensions of arrays
            %{
            rows = length(obj.ChipID);
            assert(isequal(size(obj.RxPhases),[rows,4]), 'RxPhases must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.TxPhases),[rows,4]), 'TxPhases must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.RxGains),[rows,4]), 'RxGains must be of size 4 x length(ChipID)');
            assert(isequal(size(obj.TxGains),[rows,4]), 'TxGains must be of size 4 x length(ChipID)');
            %}
            % Get devices based on beam arrangement
            obj.setChipID();
            
            % Get element indices in 2D, i.e., row and column numbers
            obj.ElementR = zeros(numel(obj.ArrayElementMap), 1);
            obj.ElementC = zeros(numel(obj.ArrayElementMap), 1);
            for ii = 1:numel(obj.ChannelElementMap)
                [obj.ElementR(ii), obj.ElementC(ii)] = ...
                    find(obj.ChannelElementMap(ii) == obj.ArrayElementMap);
            end
            %{
            % Create channel vector
            obj.Channels = cell(size(obj.ArrayElementMap));
            for ii = 1:numel(obj.ChannelElementMap)
                obj.Channels(ii) = adi.ADAR1000.Channel(obj, ii, ...
                    obj.ChannelElementMap(ii), obj.ElementR(ii), obj.ElementC(ii));
            end
            
            % Set attributes in hardware
            obj.setAllDevs(obj.RxPhases,'phase',false)
            obj.setAllDevs(obj.TxPhases,'phase',true)
            obj.setAllDevs(obj.RxGains,'hardwaregain',false)
            obj.setAllDevs(obj.TxGains,'hardwaregain',true)
            %}
        end
    end
    
    methods
        function result = getDeviceAttribute(obj, DevAttrName)
            attrCount = obj.iio_device_get_attrs_count(devPtr);
            for i = 1:attrCount
                attr = obj.iio_device_get_attr(devPtr,i-1);
                if strcmpi(attr,'label')
                end
            end
            
        end
        %{
        function result = get.BeamMemEnable(obj)
            result = obj.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true);
            attrCount = obj.iio_device_get_attrs_count(devPtr);
            for i = 1:attrCount
                attr = obj.iio_device_get_attr(devPtr,i-1);
                if strcmpi(attr,'label')
                end
            end
        end
        
        function set.BeamMemEnable(obj, value)
            dac_code = int32(value / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true, dac_code);
        end
        %}
    end
end