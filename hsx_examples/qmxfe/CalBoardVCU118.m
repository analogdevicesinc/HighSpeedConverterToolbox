classdef CalBoardVCU118
    properties
%         uri = 'ip:analog';
    end
   
    methods
        function obj = CalBoardVCU118(varargin)
        end
        
%     	function iio_attr_one_bit_adc_dac(obj, chan, attr, val)
%             system(['iio_attr -u ' obj.uri ' -c one-bit-adc-dac ' chan ' ' attr ' ' val]);
%         end
%         
%     	function returnVal = iio_attr_ad5592r(obj, chan, attr)
%             [~, returnVal] = system(['iio_attr -u ' obj.uri ' -c ad5592r ' chan ' ' attr]);
%             returnVal = str2double(returnVal);
%         end        

        %% Configure Calibration Board for Combined Tx->Rx Loopback
        function ConfigureCombinedLoopback(~,obj)
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
        function ConfigureAdjacentIndividualLoopback(~,obj)
            obj.setAttributeDouble('voltage2','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','0');
        end
        
        %% Configure Calibration Board for Combined Tx Output to J502 SMA Connector
        function ConfigureTxOutToSMA(~,obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',0,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','0');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','0');
        end
        
        %% Configure Calibration Board for Combined Tx Output to LTC5596 Detector
        function ConfigureTxOutToLTC5596(~,obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',0,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',1,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','0');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','1');            
        end
        
        %% Configure Calibration Board for Combined Tx Output to AD8318 Detector
        function ConfigureTxOutToAD8318(~,obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage0','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage1','raw',0,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage0','5045_V1_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage1','5045_V2_raw','0');            
        end        
        
        %% Configure Calibration Board for Combined Rx Input from J501 SMA Connector
        function ConfigureRxInFromSMA(~,obj)
            obj.setAttributeDouble('voltage2','raw',1,true,0,obj.iioOneBitADCDAC);
            obj.setAttributeDouble('voltage3','raw',1,true,0,obj.iioOneBitADCDAC);
%             self.iio_attr_one_bit_adc_dac('voltage2','CTRL_IND_raw','1');
%             self.iio_attr_one_bit_adc_dac('voltage3','CTRL_RX_COMBINED_raw','1');
        end
        
        %% Query Digitized AD8318 Log Detector Voltage
        function AD8318_voltage = QueryAD8318_voltage(~,obj)
            AD8318_raw = obj.getAttributeDouble('voltage0','raw',false,obj.iioAD5592r);
            AD8318_scale = obj.getAttributeDouble('voltage0','scale',false,obj.iioAD5592r);
%             AD8318_raw = self.iio_attr_ad5592r('voltage0','raw');
%             AD8318_scale = self.iio_attr_ad5592r('voltage0','scale');
            AD8318_voltage = AD8318_raw*AD8318_scale/1e3; %Voltage returns in V
        end
        
        %% Query Digitized HMC948 Log Detector Voltage
        function HMC948_voltage = QueryHMC948_voltage(~,obj)
            HMC948_raw = obj.getAttributeDouble('voltage5','raw',false,obj.iioAD5592r);
            HMC948_scale = obj.getAttributeDouble('voltage5','scale',false,obj.iioAD5592r);
%             HMC948_raw = self.iio_attr_ad5592r('voltage5','raw');
%             HMC948_scale = self.iio_attr_ad5592r('voltage5','scale');
            HMC948_voltage = HMC948_raw*HMC948_scale/1e3; %Voltage returns in V
        end
        
        %% Query Digitized LTC5596 Log Detector Voltage
        function LTC5596_voltage = QueryLTC5596_voltage(~,obj)
            LTC5596_raw = obj.getAttributeDouble('voltage7','raw',false,obj.iioAD5592r);
            LTC5596_scale = obj.getAttributeDouble('voltage7','scale',false,obj.iioAD5592r);            
%             LTC5596_raw = self.iio_attr_ad5592r('voltage7','raw');
%             LTC5596_scale = self.iio_attr_ad5592r('voltage7','scale');
            LTC5596_voltage = LTC5596_raw*LTC5596_scale/1e3; %Voltage returns in V
        end        
    end
end