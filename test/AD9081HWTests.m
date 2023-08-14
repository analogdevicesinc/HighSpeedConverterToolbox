classdef AD9081HWTests < HardwareTests
    
    properties
        uri = 'ip:analog.local';
        author = 'ADI';
    end
    
    methods(TestClassSetup)
        % Check hardware connected
        function CheckForHardware(testCase)
            disp('Skipping init test');
%             Device = @()adi.AD9081.Rx;
%             testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
    end
    
    methods (Static)
        function estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
%             df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
%             plot(freqRangeRx, FFTRxData);
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).'/1000;
            plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end,:));
        end
        
        function freq = estFrequencyMax(data,fs)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).';
            [~,ind] = max(FFTRxData(end-length(freqRangeRx)+1:end,:));
            freq = freqRangeRx(ind);
        end
        
    end
    
    methods (Test)
        
        function testAD9081Rx(testCase)    
            % Test Rx DMA data output
            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = 1;
            [out, valid] = rx();
            rx.release();
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
        end
        
        function testAD9081RxWithTxDDS(testCase)
            % Test DDS output
            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc] = tx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc);
            tx.DataSource = 'DDS';
            toneFreq = 45e6;
            tx.DDSFrequencies = repmat(toneFreq,2,2);
            tx();
            pause(1);
            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = 1;
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
        function testAD9081RxWithTxDDSTwoChan(testCase)
            % Test DDS output
            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc] = tx.GetDataPathConfiguration();
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc);
            tx.DataSource = 'DDS';
            toneFreq1 = 160e6;
            toneFreq2 = 300e6;
            tx.DDSFrequencies = [toneFreq1,toneFreq2;toneFreq1,toneFreq2];
            tx.DDSScales = [1,1;0,0].*0.029;
            tx();
            pause(1);
            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = [1 2];
            valid = false;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst1 = testCase.estFrequencyMax(out(:,1),rx.SamplingRate);
            freqEst2 = testCase.estFrequencyMax(out(:,2),rx.SamplingRate);
%             freqEst1 = meanfreq(double(real(out(:,1))),rx.SamplingRate);
%             freqEst2 = meanfreq(double(real(out(:,2))),rx.SamplingRate);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst1,toneFreq1,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            testCase.verifyEqual(freqEst2,toneFreq2,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
        function testAD9081RxWithTxData(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; frequency = 40e6;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = 1e9;
            y = swv1();
            
            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc] = tx.GetDataPathConfiguration();
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx(y);
            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);

            rx.EnabledChannels = 1;
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
%             plot(real(out));
            freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
        
        function testAD9081RxWithTxDataTwoChan(testCase)
            % Test Tx DMA data output
            amplitude = 2^15; toneFreq1 = 40e6;
            swv1 = dsp.SineWave(amplitude, toneFreq1);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = 1e9;
            y1 = swv1();
            
            amplitude = 2^15; toneFreq2 = 180e6;
            swv1 = dsp.SineWave(amplitude, toneFreq2);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = 1e9;
            y2 = swv1();
            
            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc] = tx.GetDataPathConfiguration();
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx.EnabledChannels = [1,2];
            tx([y1,y2]);
            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = [1,2];
            for k=1:10
                [out, valid] = rx();
            end
            rx.release();
            
            plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst1 = testCase.estFrequencyMax(out(:,1),rx.SamplingRate);
            freqEst2 = testCase.estFrequencyMax(out(:,2),rx.SamplingRate);
%             freqEst = meanfreq(double(real(out)),rx.SamplingRate);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst1,toneFreq1,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            testCase.verifyEqual(freqEst2,toneFreq2,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
    end
    
end

