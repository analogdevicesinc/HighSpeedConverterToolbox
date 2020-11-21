classdef CalBoardVCU118 < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    % adi.CalBoardVCU118 Calibration Board VCU118
    %   The adi.CalBoardVCU118 System object is a control class for the ADI
    %   16 channel calibration board
    %
    %   16 channel calibration board for VCU118 FPGA development kit
    %   This board is typically mated with the Quad AD9081 prototyping kit
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        phyDevName = 'ad5592r';
        devName = 'one-bit-adc-dac';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties (Hidden)
        iioAD5592r;
        iioOneBitADCDAC
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    methods
        function obj = CalBoardVCU118(varargin)
            obj = obj@matlabshared.libiio.base(varargin{:});
        end      

        %% Configure Calibration Board for Combined Tx->Rx Loopback
        function ConfigureCombinedLoopback(obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage3','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage3','CTRL_RX_COMBINED_raw','0');
        end
        
        %% Configure Calibration Board for Adjacent Individual Tx->Rx Loopback
        function ConfigureAdjacentIndividualLoopback(obj)
            obj.setAttributeDouble('voltage2','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','0');
        end
        
        %% Configure Calibration Board for Combined Tx Output to J502 SMA Connector
        function ConfigureTxOutToSMA(obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','0');
        end
        
        %% Configure Calibration Board for Combined Tx Output to LTC5596 Detector
        function ConfigureTxOutToLTC5596(obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',0,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',1,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','0');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','1');            
        end
        
        %% Configure Calibration Board for Combined Rx Input from J501 SMA Connector
        function ConfigureRxInFromSMA(obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage3','raw',1,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage3','CTRL_RX_COMBINED_raw','1');
        end
        
        %% Query Digitized AD8318 Log Detector Voltage
        function AD8318_voltage = QueryAD8318_voltage(obj)
            AD8318_raw = obj.getAttributeDouble('voltage0','raw',false,obj.iioAD5592r);
            AD8318_scale = obj.getAttributeDouble('voltage0','scale',false,obj.iioAD5592r);
%             AD8318_raw = self.iio_attr_ad5592r('voltage0','raw');
%             AD8318_scale = self.iio_attr_ad5592r('voltage0','scale');
            AD8318_voltage = AD8318_raw*AD8318_scale/1e3; %Voltage returns in V
        end
        
        %% Query Digitized HMC948 Log Detector Voltage
        function HMC948_voltage = QueryHMC948_voltage(obj)
            HMC948_raw = obj.getAttributeDouble('voltage5','raw',false,obj.iioAD5592r);
            HMC948_scale = obj.getAttributeDouble('voltage5','scale',false,obj.iioAD5592r);
%             HMC948_raw = self.iio_attr_ad5592r('voltage5','raw');
%             HMC948_scale = self.iio_attr_ad5592r('voltage5','scale');
            HMC948_voltage = HMC948_raw*HMC948_scale/1e3; %Voltage returns in V
        end
        
        %% Query Digitized LTC5596 Log Detector Voltage
        function LTC5596_voltage = QueryLTC5596_voltage(obj)
            LTC5596_raw = obj.getAttributeDouble('voltage7','raw',false,obj.iioAD5592r);
            LTC5596_scale = obj.getAttributeDouble('voltage7','scale',false,obj.iioAD5592r);            
%             LTC5596_raw = self.iio_attr_ad5592r('voltage7','raw');
%             LTC5596_scale = self.iio_attr_ad5592r('voltage7','scale');
            LTC5596_voltage = LTC5596_raw*LTC5596_scale/1e3; %Voltage returns in V
        end        
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
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
            obj.pIsInSimulink = coder.const(obj.isInSimulink);
            obj.pNumBufferBytes = coder.const(obj.numBufferBytes);            
            obj.ConnectedToDevice = true;
            setupInit(obj);
        end
        
        function setupInit(obj)
            obj.iioAD5592r = getDev(obj, obj.phyDevName);
            obj.iioOneBitADCDAC = getDev(obj, obj.devName);
        end
        
    end
end