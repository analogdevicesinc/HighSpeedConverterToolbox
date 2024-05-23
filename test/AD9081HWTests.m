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
        function estFrequency(data,fs,saveNoShow,figname)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
%             df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).'/1000;
%             plot(freqRangeRx, FFTRxData);
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).'/1000;
            if nargin < 3
                saveNoShow = false;
            end
            if nargin < 4
                figname = 'freq_plot';
            end
            if saveNoShow
                f = figure('visible','off');
            end
            plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end,:));
            if saveNoShow
                saveas(f,figname,'png')
                saveas(f,figname,'fig')
            end
        end
        
        function freq = estFrequencyMax(data,fs,saveNoShow,figname)
            nSamp = length(data);
            FFTRxData  = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (0:df:fs/2-df).';
            [~,ind] = max(FFTRxData(end-length(freqRangeRx)+1:end,:));
            freq = freqRangeRx(ind);
            if nargin < 3
                saveNoShow = false;
            end
            if nargin < 4
                figname = 'freq_plot';
            end
            if saveNoShow
                f = figure('visible','off');
            end
            plot(freqRangeRx, FFTRxData(end-length(freqRangeRx)+1:end,:));
            if saveNoShow
                saveas(f,figname,'png')
                saveas(f,figname,'fig')
            end
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
            [cdc, fdc, dc, srTx] = tx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc*2);
            tx.DataSource = 'DDS';

            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc, srRx] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = 1;
            valid = false;

            toneFreq = rand(1) * srRx / 2;
%             tx.DDSFrequencies = repmat(toneFreq,2,2);
%             tx.DDSScales = repmat(0.9,2,2);
            tx.DDSSingleTone(toneFreq, 0.1, 1);
%             tx.NCOEnables(:) = 1;
            tx();
            pause(1);
            
            for k=1:10
                [out, valid] = rx();
            end
            % sr = rx.SamplingRate;
            rx.release();
            tx.release();
            
%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst = meanfreq(double(real(out)),srRx);

            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,toneFreq,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
        end
        
        function testAD9081RxWithTxDDSTwoChan(testCase)
            % Test DDS output
            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc, srTx] = tx.GetDataPathConfiguration();
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc*2);
            tx.DataSource = 'DDS';

            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc, srRx] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = [1 2];
            valid = false;

            toneFreqs = rand(2) * srRx / 2;
            toneFreq1 = toneFreqs(1);
            toneFreq2 = toneFreqs(2);
%             tx.DDSFrequencies = [toneFreq1,toneFreq1,toneFreq2,toneFreq2;...
%                 0,0,0,0];
%             tx.DDSScales = [1,1,1,1;0,0,0,0].*0.029;
            tx.DDSPhases = [90000,0,90000,0; 0,0,0,0];
            tx.DDSFrequencies = repmat(horzcat([toneFreq1,toneFreq1], ...
				            [toneFreq2,toneFreq2]),2,1);
            tx.DDSScales = repmat([1,1;0,0].*0.029,1,2);
            tx();
            pause(1);

            for k=1:10
                [out, valid] = rx();
            end
            % sr = rx.SamplingRate;
            rx.release();
            tx.release();
            
%             plot(real(out));
%             testCase.estFrequency(out,sr);
            freqEst1 = testCase.estFrequencyMax(out(:,1),srRx,true,'TwoChanDDS_Chan1');
            freqEst2 = testCase.estFrequencyMax(out(:,2),srRx,true,'TwoChanDDS_Chan2');
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

            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc, srTx] = tx.GetDataPathConfiguration();

            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc, srRx] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = 1;

            % Test Tx DMA data output
            amplitude = 2^15; frequency = rand(1) * srRx / 2;
            swv1 = dsp.SineWave(amplitude, frequency);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = srTx;
            y = swv1();
            
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc*2);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx(y);

            for k=1:10
                [out, valid] = rx();
            end
            % sr = rx.SamplingRate;
            rx.release();
            tx.release();
            
%             plot(real(out));
            freqEst = testCase.estFrequencyMax(double(real(out)),srRx);
            
            testCase.verifyTrue(valid);
            testCase.verifyGreaterThan(sum(abs(double(out))),0);
            testCase.verifyEqual(freqEst,frequency,'RelTol',0.01,...
                'Frequency of ML tone unexpected')
        end
        
        function testAD9081RxWithTxDataTwoChan(testCase)

            tx = adi.AD9081.Tx('uri',testCase.uri);
            [cdc, fdc, dc, srTx] = tx.GetDataPathConfiguration();

            rx = adi.AD9081.Rx('uri',testCase.uri);
            [cdc, fdc, dc, srRx] = rx.GetDataPathConfiguration();
            testCase.log(sprintf('cdc: %d, fdc: %d, dc: %d',cdc, fdc, dc))
            rx = adi.AD9081.Rx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc);
            rx.EnabledChannels = [1,2];


            % Test Tx DMA data output
            toneFreqs = rand(2) * srRx / 2;
            amplitude = 2^15; toneFreq1 = toneFreqs(1);
            swv1 = dsp.SineWave(amplitude, toneFreq1);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = srTx;
            y1 = swv1();
            
            amplitude = 2^15; toneFreq2 = toneFreqs(2);
            swv1 = dsp.SineWave(amplitude, toneFreq2);
            swv1.ComplexOutput = false;
            swv1.SamplesPerFrame = 2^20;
            swv1.SampleRate = srTx;
            y2 = swv1();
            
            tx = adi.AD9081.Tx(...
                'uri',testCase.uri,...
                'num_data_channels', dc, ...
                'num_coarse_attr_channels', cdc, ...
                'num_fine_attr_channels', fdc, ...
                'num_dds_channels', fdc*2);
            tx.DataSource = 'DMA';
            tx.EnableCyclicBuffers = true;
            tx.EnabledChannels = [1,2];
            tx([y1,y2]);

            for k=1:10
                [out, valid] = rx();
            end
            % sr = rx.SamplingRate;
            rx.release();
            tx.release();
            
%             plot(real(out));
%             testCase.estFrequency(out,rx.SamplingRate);
            freqEst1 = testCase.estFrequencyMax(out(:,1),srRx,true,'TwoChanData_Chan1');
            freqEst2 = testCase.estFrequencyMax(out(:,2),srRx,true,'TwoChanData_Chan2');
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

