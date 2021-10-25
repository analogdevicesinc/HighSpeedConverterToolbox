classdef Channel < matlab.mixin.SetGet
    properties
        BIAS_CODE_TO_VOLTAGE_SCALE
    end
    
    properties
        ADARParent
        ADARChannel
        ArrayElementNumber
        Row
        Col
        
        DetectorEnable
        DetectorPower
        PABiasOff
        PABiasOn
        RxAttn
        RxBeamState
        RxEnable
        RxGain
        RxPhase        
        TxAttn
        TxBeamState
        TxEnable
        TxGain
        TxPhase        
    end
    
    methods
        function obj = Channel(ADARParent, ADARChannel, ArrayElementNumber, Row, Col)
            obj.ADARParent = ADARParent;
            obj.ADARChannel = ADARChannel;
            obj.ArrayElementNumber = ArrayElementNumber;
            obj.Row = Row;
            obj.Col = Col;

            obj.BIAS_CODE_TO_VOLTAGE_SCALE = adar1000.BIAS_CODE_TO_VOLTAGE_SCALE;
        end
        
        function res = get.ADARParent(obj)
            res = obj.ADARParent;
        end
        
        function res = get.ADARChannel(obj)
            res = obj.ADARChannel;
        end

        function res = get.ArrayElementNumber(obj)
            res = obj.ArrayElementNumber;
        end
        
        function res = get.Row(obj)
            res = obj.Row;
        end

        function res = get.Col(obj)
            res = obj.Col;
        end
        
        function res = get.DetectorEnable(obj)
            res = obj.ADARParent.getAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'detector_en', true);
        end
        
        function set.DetectorEnable(obj, value)
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'detector_en', true, value);
        end
        
        function res = get.DetectorPower(obj)
            obj.DetectorEnable = true;
            res = obj.ADARParent.getAttributeRAW(sprintf('voltage%d',obj.ADARChannel), 'raw', true);
            obj.DetectorEnable = false;
        end
        
        function res = get.PABiasOff(obj)
            dac_code = obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true);
            res = dac_code*obj.BIAS_CODE_TO_VOLTAGE_SCALE;
        end
        
        function set.PABiasOff(obj, value)
            dac_code = int(value / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_off', true, dac_code);
        end
        
        function res = get.PABiasOn(obj)
            dac_code = obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_on', true);
            res = dac_code*obj.BIAS_CODE_TO_VOLTAGE_SCALE;
        end
        
        function set.PABiasOn(obj, value)
            dac_code = int(value / obj.BIAS_CODE_TO_VOLTAGE_SCALE);
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'pa_bias_on', true, dac_code);
        end
        
        function res = get.RxAttn(obj)
            res = logical(1 - obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'attenuation', false));
        end
        
        function set.RxAttn(obj, value)
            obj.ADARParent.setAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'attenuation', false, 1-int(value));
        end
        
        function res = get.RxBeamState(obj)
            res = obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'beam_pos_load', false);
        end
        
        function set.RxBeamState(obj, value)
            validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'RxBeamState'); 
            obj.ADARParent.setAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'beam_pos_load', false, value);
        end
        
        function res = get.RxEnable(obj)
            res = ~(obj.ADARParent.getAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'powerdown', false));
        end
        
        function set.RxEnable(obj, value)
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'powerdown', false, ~value);
        end
        
        function res = get.RxGain(obj)
            res = obj.ADARParent.getAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'hardwaregain', false);
        end
        
        function set.RxGain(obj, value)
            obj.ADARParent.setAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'hardwaregain', false, value);
        end
        
        function res = get.RxPhase(obj)
            res = obj.ADARParent.getAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'phase', false);
        end
        
        function set.RxPhase(obj, value)
            obj.ADARParent.setAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'phase', false, value);
        end
        
        function res = get.TxAttn(obj)
            res = logical(1 - obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'attenuation', true));
        end
        
        function set.TxAttn(obj, value)
            obj.ADARParent.setAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'attenuation', true, 1-int(value));
        end
        
        function res = get.TxBeamState(obj)
            res = obj.ADARParent.getAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'beam_pos_load', true);
        end
        
        function set.TxBeamState(obj, value)
            validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'TxBeamState'); 
            obj.ADARParent.setAttributeLongLong(sprintf('voltage%d',obj.ADARChannel), 'beam_pos_load', true, value);
        end
        
        function res = get.TxEnable(obj)
            res = ~(obj.ADARParent.getAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'powerdown', true));
        end
        
        function set.TxEnable(obj, value)
            obj.ADARParent.setAttributeBool(sprintf('voltage%d',obj.ADARChannel), 'powerdown', true, ~value);
        end
        
        function res = get.TxGain(obj)
            res = obj.ADARParent.getAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'hardwaregain', true);
        end
        
        function set.TxGain(obj, value)
            obj.ADARParent.setAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'hardwaregain', true, value);
        end
        
        function res = get.TxPhase(obj)
            res = obj.ADARParent.getAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'phase', true);
        end
        
        function set.TxPhase(obj, value)
            obj.ADARParent.setAttributeDouble(sprintf('voltage%d',obj.ADARChannel), 'phase', true, value);
        end
        
        function SaveRxBeam(obj, State, Attn, Gain, Phase)
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'State');
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',127}, ...
                '', 'Gain');             
            obj.ADARParent.setAttributeRAW(sprintf('voltage%d',obj.ADARChannel), ...
                'beam_pos_save', false, sprintf('%d, %d, %d, %f', State, 1 - int(Attn), Gain, Phase));
        end
        
        function SaveTxBeam(obj, State, Attn, Gain, Phase)
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',120}, ...
                '', 'State');
             validateattributes( value, { 'double','single', 'uint32' }, ...
                { 'real', 'nonnegative','scalar', 'finite', 'nonnan', 'nonempty','integer','>=',0,'<=',127}, ...
                '', 'Gain');             
            obj.ADARParent.setAttributeRAW(sprintf('voltage%d',obj.ADARChannel), ...
                'beam_pos_save', true, sprintf('%d, %d, %d, %f', State, 1 - int(Attn), Gain, Phase));
        end
    end
end