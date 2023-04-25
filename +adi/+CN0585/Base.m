classdef (Abstract, Hidden = true) Base < ...
        adi.common.RxTx & ...
        adi.common.Attribute & ...
        matlabshared.libiio.base
    %adi.CN0585.Base Class
    %   This class contains shared parameters and methods between TX and RX
    %   classes

    properties (Hidden)
        iioOneBitADCDAC;
        HDLSystemID

    end

    methods
        %% Constructor
        function obj = Base(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end

        function result = CheckMathWorksCore(obj)
            result = contains(obj.HDLSystemID, "matlab");
        end

    end

    %% API Functions
    methods (Hidden, Access = protected)

        function setupInit(obj)

            % GPIO CONTROLLER

            obj.iioOneBitADCDAC = getDev(obj, 'one-bit-adc-dac');
            obj.setAttributeBool('voltage0', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage1', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage2', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage3', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage4', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage5', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage6', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage7', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage8', 'raw', boolean(1), true, obj.iioOneBitADCDAC);
            obj.setAttributeBool('voltage9', 'raw', boolean(1), true, obj.iioOneBitADCDAC);

            % HDLSystemID SYSID STRING VALUE

            obj.HDLSystemID = obj.iio_context_get_attr_value(obj.iioCtx, 'hdl_system_id');

            % UPDATED PARAMETERS

            obj.setDeviceAttributeRAW('input_source', obj.InputSource);
            obj.setDeviceAttributeRAW('output_range', obj.OutputRange);
            
        end

    end

end
