classdef AD9081Tests < matlab.unittest.TestCase
    
    properties
        EnableVisuals = true;
    end
    
    methods (Static)
        function freq = estFrequency(data,fs)
            nSamp = length(data);
            FFTRxData = fftshift(10*log10(abs(fft(data))));
            df = fs/nSamp;  freqRangeRx = (-fs/2:df:fs/2-df).';
            %             plot(freqRangeRx, FFTRxData);
            v = max(FFTRxData);
            ind = FFTRxData>0.9*v;
            freq = freqRangeRx(ind);
        end
        
        function [IRR, out_level] = measureIIR(input_data, Freq_bin, plot_enable )
            % Assume a complex data input that is coherent.  Measure the fund_level,
            % image_level, and IRR
            Nfft = length( input_data );
            win = kaiser(Nfft,100);
            win = win/sum(win);
            win = win*Nfft;
            input_data = input_data.*win;
            
            spec = fft( input_data ) / Nfft;
            
            spec_db = 20*log10(abs(spec)+10^-20);
            
            fund_level = spec_db( Freq_bin + 1 );
            image_level = spec_db( Nfft - Freq_bin + 1 );
            
            if(fund_level>image_level)
                IRR = image_level - fund_level;
                out_level = fund_level;
            else
                IRR = fund_level - image_level;
                out_level = image_level;
            end
            
            if plot_enable
                plot(spec_db)
            end 
        end
        
    end
    
    methods (Test)
        
        function testAD9081Converter(testCase)
            
            adc = adi.sim.common.ADC9081;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = adc.SampleRate;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(adc.Bits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test ADC
            logs = [];
            for k=1:10
                data = zeros(1e5,1);
                o = adc(data);
                sa(o);
                if sa.isNewDataReady
                    m = getMeasurementsData(sa);
                    logs = [logs;m.CursorMeasurements.Power]; %#ok<AGROW>
                end
            end
            
            %% Verify
            % Reduce target by 3dB since we are measuring complex spectrum
            testCase.verifyEqual(mean(logs),adc.ConverterNSD-3,'AbsTol',1,...
                'Incorrect noise floor')
        end
        
        function testAD9081NyquistMode(testCase)
            
            rx = adi.sim.AD9081.Rx;
            ConverterNSD = -150;
            ADCOutputBits = 12;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = rx.SampleRate;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(ADCOutputBits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            for k=1:10
                data = zeros(1e5,1);
                o = rx(data,data,data,data);
                sa(o);
                if sa.isNewDataReady
                    m = getMeasurementsData(sa);
                    logs = [logs;m.CursorMeasurements.Power]; %#ok<AGROW>
                end
            end
            
            %% Verify
            % Reduce target by 3dB since we are measuring complex spectrum
            testCase.verifyEqual(mean(logs),ConverterNSD-3,'AbsTol',1,...
                'Incorrect noise floor')
        end
        
        function testAD9081CDDCDec(testCase)
            
            rx = adi.sim.AD9081.Rx;
            rx.MainDataPathDecimation = 4;
            ConverterNSD = -150;
            ADCOutputBits = 12;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = rx.SampleRate/rx.MainDataPathDecimation;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(ADCOutputBits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            for k=1:10
                data = zeros(1e5,1);
                o = rx(data,data,data,data);
                sa(o);
                if sa.isNewDataReady
                    m = getMeasurementsData(sa);
                    logs = [logs;m.CursorMeasurements.Power]; %#ok<AGROW>
                end
            end
            
            %% Verify
            % Reduce target by 3dB since we are measuring complex spectrum
            testCase.verifyEqual(mean(logs),ConverterNSD-3,'AbsTol',1,...
                'Incorrect noise floor')
        end
        
        function testAD9081FDDCDec(testCase)
            
            rx = adi.sim.AD9081.Rx;
            rx.ChannelizerPathDecimation = 4;
            ConverterNSD = -150;
            ADCOutputBits = 12;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = rx.SampleRate/rx.ChannelizerPathDecimation;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(ADCOutputBits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            for k=1:10
                data = zeros(1e4,1);
                o = rx(data,data,data,data);
                sa(o);
                if sa.isNewDataReady
                    m = getMeasurementsData(sa);
                    logs = [logs;m.CursorMeasurements.Power]; %#ok<AGROW>
                end
            end
            
            %% Verify
            testCase.verifyEqual(mean(logs),ConverterNSD-6,'AbsTol',3,...
                'Incorrect noise floor')
        end
        
        function testAD9081RxTonesWithCDDCNCO(testCase)
            rx = adi.sim.AD9081.Rx;
            rx.CDDCNCOFrequencies = [1e9, 1e9, -0.5e9, 3e8];
            rx.CDDCNCOEnable = [1, 1, 1, 1];
            
            %% Generate sinwave;
            sw = dsp.SineWave;
            sw.Amplitude = 1;
            sw.Frequency = 100e6;
            sw.SampleRate = rx.SampleRate;
            sw.SamplesPerFrame = 1e4;
            
            if testCase.EnableVisuals
                sa = dsp.SpectrumAnalyzer;
                sa.SampleRate = sw.SampleRate;
                sa.YLimits = [-150 10];
                sa.SpectralAverages = 100;
                sa.SpectrumType = 'Power density';
                sa.SpectrumUnits = 'dBFS';
            end
            
            %% Test MxFE
            for k=1:4
                % Pass through chip
                o1 = rx(sw(),sw(),sw(),sw());
                % From dBFS to dBm
                o1 = int16(o1);
                if testCase.EnableVisuals
                    sa(o1);
                end
            end
            
            freqEst = testCase.estFrequency(double(o1),rx.SampleRate);
            truePos = rx.CDDCNCOFrequencies(1) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);
            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            
        end
        
        function testAD9081RxTonesWithFDDCNCO(testCase)
            rx = adi.sim.AD9081.Rx;
            rx.FDDCNCOFrequencies = [1e9, 1e9, -0.5e9, 3e8, 0, 0, 0, 0];
            rx.FDDCNCOEnable = [1, 1, 1, 1, 0, 0, 0, 0];
            
            %% Generate sinwave
            sw = dsp.SineWave;
            sw.Amplitude = 1;
            sw.Frequency = 100e6;
            sw.SampleRate = rx.SampleRate;
            sw.SamplesPerFrame = 1e4;
            
            if testCase.EnableVisuals
                sa = dsp.SpectrumAnalyzer;
                sa.SampleRate = sw.SampleRate;
                sa.YLimits = [-150 10];
                sa.SpectralAverages = 100;
                sa.SpectrumType = 'Power density';
                sa.SpectrumUnits = 'dBFS';
            end
            
            %% Test MxFE
            for k=1:4
                % Pass through chip
                o1 = rx(sw(),sw(),sw(),sw());
                if testCase.EnableVisuals
                    sa(int16(o1));
                end
            end
            
            freqEst = testCase.estFrequency(double(o1),rx.SampleRate);
            truePos = rx.FDDCNCOFrequencies(1) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);
            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')
            
        end
        
        function testAD9081PFiltAloneMatrix(testCase)
            
            fs = 250e6;
            
            %% Get data from testcase file
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Coeff";
            opts.DataRange = "A3:N50";
            % Specify column names and types
            opts.VariableNames = ["A", "B", "C", "D", "VarName5", "A1", "B1", "C1", "D1", "VarName10", "A2", "B2", "C2", "D2"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFiltS1 = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Input";
            opts.DataRange = "A4:N69";
            % Specify column names and types
            opts.VariableNames = ["Impairments1", "VarName2", "VarName3", "VarName4", "VarName5", "Impairments2", "VarName7", "VarName8", "VarName9", "VarName10", "Impairments3", "VarName12", "VarName13", "VarName14"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFilt = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            
            %% Create filter
            tapsInt16 = 2^15.*[pFiltS1.A.';pFiltS1.C.';pFiltS1.B.';pFiltS1.D.'];
            N = 48;
            [config,qt] = findBestBitArrangement(tapsInt16(1,:),N);
            [config1,qt1] = findBestBitArrangement(tapsInt16(2,:),N);
            [config2,qt2] = findBestBitArrangement(tapsInt16(3,:),N);
            [config3,qt3] = findBestBitArrangement(tapsInt16(4,:),N);
            
            % Set taps
            rx = adi.sim.common.PFilter;
            rx.Mode = 'Matrix';
            rx.Taps = [qt;qt1;qt2;qt3]./(2^15);
            rx.TapsWidthsPerQuad = [config;config1;config2;config3];
            rx.Gains = [12,12,12,12];
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = fs;
            sa.SpectralAverages = 100;
            sa.YLimits = [-150 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 2;
            sa.CursorMeasurements.Enable = true;

            
            %% Test MxFE
            freqsInterest = pFilt.Impairments1;
            amps = pFilt.VarName2;
            gainImb = pFilt.VarName3;
            phase = pFilt.VarName4;
            
            [IIRO_F, IIRI_F, AmplO_F, AmplI_F] = deal(zeros(length(freqsInterest),1));
            
            for freqIndx = 1:length(freqsInterest)
            
                N = 1e4;
                fc = freqsInterest(freqIndx);
                
                t = 0:(1/fs):(N-1)/fs;
                amp = 10^((amps(freqIndx))/20);
                amp_Q = 10^((amps(freqIndx) + gainImb(freqIndx))/20);
                I = amp * cos(2*pi*fc.*t ).';
                Q = amp_Q * sin(2*pi*fc.*t + (phase(freqIndx)* pi/180) ).';
                inputSig = I+1i.*Q;
                
                noiseAmp = 10^(-20/20);
                
                K = 5;
                [IIRO, IIRI, AmplO, AmplI] = deal(zeros(K,1));
                for k = 1:K
                    
                    Noise = noiseAmp/sqrt(2).*complex(randn(N,1),randn(N,1));
                    
                    inputSigFilter = (inputSig + Noise).*2^12;
                    inputSigFilter = int16(inputSigFilter);
                    
                    r = real(inputSigFilter);
                    i = imag(inputSigFilter);
                    
                    [o1,o2] = rx(r,i);
                    o = double(complex(o1,o2));

                    % Measure IRR
                    bin = round(abs(fc)*length(o)/fs);
                    [IIRO(k),AmplO(k)] = testCase.measureIIR( o, bin, false );
                    [IIRI(k),AmplI(k)] = testCase.measureIIR( double(inputSigFilter), bin, false );
                end
                
                IIRO_F(freqIndx) = mean(IIRO);
                IIRI_F(freqIndx) = mean(IIRI);
                AmplO_F(freqIndx) = mean(AmplO);
                AmplI_F(freqIndx) = mean(AmplI);
            end
            
            if testCase.EnableVisuals
                figure;
                plot(freqsInterest,IIRO_F,freqsInterest,IIRI_F);
                xlabel('Frequency Hz');
                ylabel('IRR (dB)');
                legend('Output IRR','Input IRR');
                grid on;
                figure;
                plot(freqsInterest,AmplO_F,freqsInterest,AmplI_F);
                xlabel('Frequency Hz');
                ylabel('Response (dB)');
                legend('Output IRR','Input Response');
                grid on;
            end
            
            clear rx;
            
            %% Verify
            % Flatness
            AmplO_F = AmplO_F - mean(AmplO_F);
            testCase.verifyEqual(abs(mean(AmplO_F)),0,'AbsTol',0.1,...
                'Invalid spectral flatness')
            % IRR
            testCase.verifyLessThan(mean(IIRO_F),-50,'Invalid IRR')
        end

        function testAD9081PFiltMatrix(testCase)
            
            %% This test evaluates the PFIR being used as an image rejection filter and a channel equalizer
            
            %% Get data from testcase file
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Coeff";
            opts.DataRange = "A3:N50";
            % Specify column names and types
            opts.VariableNames = ["A", "B", "C", "D", "VarName5", "A1", "B1", "C1", "D1", "VarName10", "A2", "B2", "C2", "D2"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFiltS1 = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Input";
            opts.DataRange = "A4:N69";
            % Specify column names and types
            opts.VariableNames = ["Impairments1", "VarName2", "VarName3", "VarName4", "VarName5", "Impairments2", "VarName7", "VarName8", "VarName9", "VarName10", "Impairments3", "VarName12", "VarName13", "VarName14"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFilt = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            
            %% Create filter
            tapsInt16 = 2^15.*[pFiltS1.A.';pFiltS1.C.';pFiltS1.B.';pFiltS1.D.'];
            N = 48;
            [config,qt] = findBestBitArrangement(tapsInt16(1,:),N);
            [config1,qt1] = findBestBitArrangement(tapsInt16(2,:),N);
            [config2,qt2] = findBestBitArrangement(tapsInt16(3,:),N);
            [config3,qt3] = findBestBitArrangement(tapsInt16(4,:),N);
            
            % Set taps
            rx = adi.sim.AD9081.Rx;
            rx.PFIREnable = true;
            rx.PFilter1Mode = 'Matrix';
            rx.PFilter1Taps = [qt;qt1;qt2;qt3]./(2^15);
            rx.PFilter1TapsWidthsPerQuad = [config;config1;config2;config3];
            rx.PFilter1Gains = [12,12,12,12];
            rx.PFilter2Mode = 'NoFilter';
            
            fs = rx.SampleRate;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = fs;
            sa.SpectralAverages = 100;
            sa.YLimits = [-150 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 2;
            sa.CursorMeasurements.Enable = true;

            
            %% Test MxFE
            freqsInterest = pFilt.Impairments1;
            fsData = 250e6;
            scale = fs/fsData;
            freqsInterest = freqsInterest.*scale;
            
            amps = pFilt.VarName2;
            gainImb = pFilt.VarName3;
            phase = pFilt.VarName4;
            
            [IIRO_F, IIRI_F, AmplO_F, AmplI_F] = deal(zeros(length(freqsInterest),1));
            
            for freqIndx = 1:length(freqsInterest)
            
                N = 1e4;
                fc = freqsInterest(freqIndx);
                
                t = 0:(1/fs):(N-1)/fs;
                amp = 10^((amps(freqIndx))/20);
                amp_Q = 10^((amps(freqIndx) + gainImb(freqIndx))/20);
                I = amp * cos(2*pi*fc.*t ).';
                Q = amp_Q * sin(2*pi*fc.*t + (phase(freqIndx)* pi/180) ).';
                inputSig = I+1i.*Q;
                
                noiseAmp = 10^(-20/20);
                
                K = 5;
                [IIRO, IIRI, AmplO, AmplI] = deal(zeros(K,1));
                for k = 1:K
                    
                    Noise = noiseAmp/sqrt(2).*complex(randn(N,1),randn(N,1));
                    
                    inputSigFilter = (inputSig + Noise);
                    
                    r = real(inputSigFilter);
                    i = imag(inputSigFilter);
                    
                    [oR,oI] = rx(r,i,r,i);
                    o = double(complex(real(oR),real(oI)));

                    % Measure IRR
                    bin = round(abs(fc)*length(o)/fs);
                    [IIRO(k),AmplO(k)] = testCase.measureIIR( o, bin, false );
                    [IIRI(k),AmplI(k)] = testCase.measureIIR( double(inputSigFilter), bin, false );
                end
                
                IIRO_F(freqIndx) = mean(IIRO);
                IIRI_F(freqIndx) = mean(IIRI);
                AmplO_F(freqIndx) = mean(AmplO);
                AmplI_F(freqIndx) = mean(AmplI);
            end
            
            if testCase.EnableVisuals
                figure;
                plot(freqsInterest,IIRO_F,freqsInterest,IIRI_F);
                xlabel('Frequency Hz');
                ylabel('IRR (dB)');
                legend('Output IRR','Input IRR');
                grid on;
                figure;
                plot(freqsInterest,AmplO_F,freqsInterest,AmplI_F);
                xlabel('Frequency Hz');
                ylabel('Response (dB)');
                legend('Output IRR','Input Response');
                grid on;
            end
            
            clear rx;
            
            %% Verify
            % Flatness
            AmplO_F = AmplO_F - mean(AmplO_F);
            testCase.verifyEqual(abs(mean(AmplO_F)),0,'AbsTol',0.1,...
                'Invalid spectral flatness')
            % IRR
            testCase.verifyLessThan(mean(IIRO_F),-50,'Invalid IRR')
        end
        
        function testAD9081PFiltEQMatrix(testCase)
            
            %% This test evaluates the PFIR being used as a channel equalization filter
            
            %% Get data from testcase file
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Coeff";
            opts.DataRange = "A3:N50";
            % Specify column names and types
            opts.VariableNames = ["A", "B", "C", "D", "VarName5", "A1", "B1", "C1", "D1", "VarName10", "A2", "B2", "C2", "D2"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFiltS1 = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Input";
            opts.DataRange = "A4:N69";
            % Specify column names and types
            opts.VariableNames = ["Impairments1", "VarName2", "VarName3", "VarName4", "VarName5", "Impairments2", "VarName7", "VarName8", "VarName9", "VarName10", "Impairments3", "VarName12", "VarName13", "VarName14"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFilt = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            
            %% Create filter
            tapsInt16 = 2^15.*[pFiltS1.A1.';pFiltS1.C1.';pFiltS1.B1.';pFiltS1.D1.'];
            N = 48;
            [config,qt] = findBestBitArrangement(tapsInt16(1,:),N);
            [config1,qt1] = findBestBitArrangement(tapsInt16(2,:),N);
            [config2,qt2] = findBestBitArrangement(tapsInt16(3,:),N);
            [config3,qt3] = findBestBitArrangement(tapsInt16(4,:),N);
            
            % Set taps
            rx = adi.sim.AD9081.Rx;
            rx.PFIREnable = true;
            rx.PFilter1Mode = 'Matrix';
            rx.PFilter1Taps = [qt;qt1;qt2;qt3]./(2^15);
            rx.PFilter1TapsWidthsPerQuad = [config;config1;config2;config3];
            rx.PFilter1Gains = [12,12,12,12];
            rx.PFilter2Mode = 'NoFilter';
            
            fs = rx.SampleRate;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = fs;
            sa.SpectralAverages = 100;
            sa.YLimits = [-150 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 2;
            sa.CursorMeasurements.Enable = true;

            
            %% Test MxFE
            freqsInterest = pFilt.Impairments1;
            fsData = 250e6;
            scale = fs/fsData;
            freqsInterest = freqsInterest.*scale;
            
            amps = pFilt.VarName7;
            gainImb = pFilt.VarName8;
            phase = pFilt.VarName9;
            
            [IIRO_F, IIRI_F, AmplO_F, AmplI_F] = deal(zeros(length(freqsInterest),1));
            
            for freqIndx = 1:length(freqsInterest)
            
                N = 1e4;
                fc = freqsInterest(freqIndx);
                
                t = 0:(1/fs):(N-1)/fs;
                amp = 10^((amps(freqIndx))/20);
                amp_Q = 10^((amps(freqIndx) + gainImb(freqIndx))/20);
                I = amp * cos(2*pi*fc.*t ).';
                Q = amp_Q * sin(2*pi*fc.*t + (phase(freqIndx)* pi/180) ).';
                inputSig = I+1i.*Q;
                
                noiseAmp = 10^(-20/20);
                
                K = 5;
                [IIRO, IIRI, AmplO, AmplI] = deal(zeros(K,1));
                for k = 1:K
                    
                    Noise = noiseAmp/sqrt(2).*complex(randn(N,1),randn(N,1));
                    
                    inputSigFilter = (inputSig + Noise);
                    
                    r = real(inputSigFilter);
                    i = imag(inputSigFilter);
                    
                    [oR,oI] = rx(r,i,r,i);
                    o = double(complex(real(oR),real(oI)));

                    % Measure IRR
                    bin = round(abs(fc)*length(o)/fs);
                    [IIRO(k),AmplO(k)] = testCase.measureIIR( o, bin, false );
                    [IIRI(k),AmplI(k)] = testCase.measureIIR( double(inputSigFilter), bin, false );
                end
                
                IIRO_F(freqIndx) = mean(IIRO);
                IIRI_F(freqIndx) = mean(IIRI);
                AmplO_F(freqIndx) = mean(AmplO);
                AmplI_F(freqIndx) = mean(AmplI);
            end
            
            if testCase.EnableVisuals
                figure;
                plot(freqsInterest,IIRO_F,freqsInterest,IIRI_F);
                xlabel('Frequency Hz');
                ylabel('IRR (dB)');
                legend('Output IRR','Input IRR');
                grid on;
                figure;
                plot(freqsInterest,AmplO_F,freqsInterest,AmplI_F);
                xlabel('Frequency Hz');
                ylabel('Response (dB)');
                legend('Output IRR','Input Response');
                grid on;
            end
            
            clear rx;
            
            %% Verify
            % Flatness
            AmplO_F = AmplO_F - mean(AmplO_F);
            testCase.verifyEqual(abs(mean(AmplO_F)),0,'AbsTol',0.1,...
                'Invalid spectral flatness')
        end
        
        function testAD9081PFiltIRRMatrix(testCase)
            
            %% This test evaluates the PFIR being used as an image rejection filter
            
            %% Get data from testcase file
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Coeff";
            opts.DataRange = "A3:N50";
            % Specify column names and types
            opts.VariableNames = ["A", "B", "C", "D", "VarName5", "A1", "B1", "C1", "D1", "VarName10", "A2", "B2", "C2", "D2"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFiltS1 = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            % Setup the Import Options
            opts = spreadsheetImportOptions("NumVariables", 14);
            % Specify sheet and range
            opts.Sheet = "Input";
            opts.DataRange = "A4:N69";
            % Specify column names and types
            opts.VariableNames = ["Impairments1", "VarName2", "VarName3", "VarName4", "VarName5", "Impairments2", "VarName7", "VarName8", "VarName9", "VarName10", "Impairments3", "VarName12", "VarName13", "VarName14"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "double", "double", "double", "double", "string", "double", "double", "double", "double"];
            opts = setvaropts(opts, [5, 10], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 10], "EmptyFieldRule", "auto");
            % Import the data
            pFilt = readtable("pFilt.xls", opts, "UseExcel", false);
            clear opts
            
            %% Create filter
            tapsInt16 = 2^15.*[pFiltS1.A2.';pFiltS1.C2.';pFiltS1.B2.';pFiltS1.D2.'];
            N = 48;
            [config,qt] = findBestBitArrangement(tapsInt16(1,:),N);
            [config1,qt1] = findBestBitArrangement(tapsInt16(2,:),N);
            [config2,qt2] = findBestBitArrangement(tapsInt16(3,:),N);
            [config3,qt3] = findBestBitArrangement(tapsInt16(4,:),N);
            
            % Set taps
            rx = adi.sim.AD9081.Rx;
            rx.PFIREnable = true;
            rx.PFilter1Mode = 'Matrix';
            rx.PFilter1Taps = [qt;qt1;qt2;qt3]./(2^15);
            rx.PFilter1TapsWidthsPerQuad = [config;config1;config2;config3];
            rx.PFilter1Gains = [12,12,12,12];
            rx.PFilter2Mode = 'NoFilter';
            
            fs = rx.SampleRate;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = fs;
            sa.SpectralAverages = 100;
            sa.YLimits = [-150 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power density';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 2;
            sa.CursorMeasurements.Enable = true;

            
            %% Test MxFE
            freqsInterest = pFilt.Impairments1;
            fsData = 250e6;
            scale = fs/fsData;
            freqsInterest = freqsInterest.*scale;
            
            amps = pFilt.VarName12;
            gainImb = pFilt.VarName13;
            phase = pFilt.VarName14;
            
            [IIRO_F, IIRI_F, AmplO_F, AmplI_F] = deal(zeros(length(freqsInterest),1));
            
            for freqIndx = 1:length(freqsInterest)
            
                N = 1e4;
                fc = freqsInterest(freqIndx);
                
                t = 0:(1/fs):(N-1)/fs;
                amp = 10^((amps(freqIndx))/20);
                amp_Q = 10^((amps(freqIndx) + gainImb(freqIndx))/20);
                I = amp * cos(2*pi*fc.*t ).';
                Q = amp_Q * sin(2*pi*fc.*t + (phase(freqIndx)* pi/180) ).';
                inputSig = I+1i.*Q;
                
                noiseAmp = 10^(-20/20);
                
                K = 5;
                [IIRO, IIRI, AmplO, AmplI] = deal(zeros(K,1));
                for k = 1:K
                    
                    Noise = noiseAmp/sqrt(2).*complex(randn(N,1),randn(N,1));
                    
                    inputSigFilter = (inputSig + Noise);
                    
                    r = real(inputSigFilter);
                    i = imag(inputSigFilter);
                    
                    [oR,oI] = rx(r,i,r,i);
                    o = double(complex(real(oR),real(oI)));

                    % Measure IRR
                    bin = round(abs(fc)*length(o)/fs);
                    [IIRO(k),AmplO(k)] = testCase.measureIIR( o, bin, false );
                    [IIRI(k),AmplI(k)] = testCase.measureIIR( double(inputSigFilter), bin, false );
                end
                
                IIRO_F(freqIndx) = mean(IIRO);
                IIRI_F(freqIndx) = mean(IIRI);
                AmplO_F(freqIndx) = mean(AmplO);
                AmplI_F(freqIndx) = mean(AmplI);
            end
            
            if testCase.EnableVisuals
                figure;
                plot(freqsInterest,IIRO_F,freqsInterest,IIRI_F);
                xlabel('Frequency Hz');
                ylabel('IRR (dB)');
                legend('Output IRR','Input IRR');
                grid on;
                figure;
                plot(freqsInterest,AmplO_F,freqsInterest,AmplI_F);
                xlabel('Frequency Hz');
                ylabel('Response (dB)');
                legend('Output IRR','Input Response');
                grid on;
            end
                        
            clear rx;
            
            %% Verify
            % IRR
            testCase.verifyLessThan(mean(IIRO_F),-50,'Invalid IRR')
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        
        function testAD9081NyquistDAC(testCase)
            
            dac = adi.sim.common.DAC9081;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = dac.SampleRate;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(dac.Bits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            data = fi(2^15.*ones(1e4,1),1,16,0); % Full scale
            for k=1:100
                o = dac(data);
                sa(o);
                if sa.isNewDataReady
                    sa.CursorMeasurements.XLocation = [0 2e9];
                    m = getMeasurementsData(sa);
                    logs = [logs;diff(m.CursorMeasurements.Power)]; %#ok<AGROW>
                end
            end
            logs(1) = [];
            %% Verify
            testCase.verifyEqual(mean(logs),dac.ConverterNSD,'AbsTol',2,...
                'Incorrect noise floor')
        end
        
        
         function testAD9081NyquistTX(testCase)
            
            tx = adi.sim.AD9081.Tx;
            dac = adi.sim.common.DAC9081;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = tx.SampleRate;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(dac.Bits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            data = fi(2^15.*ones(1e4,1),1,16,0);% Full scale
            for k=1:100
                o = tx(data,data,data,data,data,data,data,data);
                sa(o);
                if sa.isNewDataReady
                    sa.CursorMeasurements.XLocation = [0 2e9];
                    m = getMeasurementsData(sa);
                    logs = [logs;diff(m.CursorMeasurements.Power)]; %#ok<AGROW>
                end
            end
            logs(1) = [];
            %% Verify
            testCase.verifyEqual(mean(logs),dac.ConverterNSD,'AbsTol',2,...
                'Incorrect noise floor')
         end
        
         function testAD9081TXFDUCInt(testCase)
            
            tx = adi.sim.AD9081.Tx;
            tx.ChannelizerPathInterpolation = 2;
            dac = adi.sim.common.DAC9081;
            
            %% Measurement
            sa = dsp.SpectrumAnalyzer;
            sa.SampleRate = tx.SampleRate;
            sa.YLimits = [-180 10];
            sa.SpectralAverages = 100;
            sa.SpectrumType = 'Power';
            sa.SpectrumUnits = 'dBFS';
            sa.NumInputPorts = 1;
            sa.FullScaleSource = 'Property';
            sa.FullScale = 2^(dac.Bits-1);
            sa.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            logs = [];
            for k=1:30
                data = complex(fi(2^15.*ones(1e4,1),1,16,0));
                o = tx(data,data,data,data,data,data,data,data);
                sa(o);
                if sa.isNewDataReady
                    sa.CursorMeasurements.XLocation = [0 2e9];
                    m = getMeasurementsData(sa);
                    logs = [logs;diff(m.CursorMeasurements.Power)]; %#ok<AGROW>
                end
            end
            logs(1:10) = [];
            %% Verify
            testCase.verifyEqual(mean(logs),dac.ConverterNSD,'AbsTol',2,...
                'Incorrect noise floor')
         end
        
        
         function testAD9081TXCDUCNCO(testCase)
            
            tx = adi.sim.AD9081.Tx;
            tx.MainDataPathInterpolation = 4;
            tx.CDUCNCOFrequencies = [3e9, 2e9, 0, 0];
            tx.CDUCNCOEnable = [1, 1, 0, 0];
            
            %% Generate sinwave;
            sw = dsp.SineWave;
            sw.Amplitude = 2^14;
            sw.Frequency = 1.001e9;
            sw.SampleRate = tx.SampleRate/tx.MainDataPathInterpolation;
            sw.SamplesPerFrame = 1e4;
            
            if testCase.EnableVisuals
                sa = dsp.SpectrumAnalyzer;
                sa.SampleRate = tx.SampleRate;
                sa.YLimits = [-180 10];
                sa.SpectralAverages = 100;
                sa.SpectrumType = 'Power';
                sa.SpectrumUnits = 'dBFS';
                sa.NumInputPorts = 1;
                sa.FullScaleSource = 'Property';
                sa.FullScale = 2^(16-1);
                sa.CursorMeasurements.Enable = true;
            end
            
                sa2 = dsp.SpectrumAnalyzer;
                sa2.SampleRate = tx.SampleRate;
                sa2.YLimits = [-180 10];
                sa2.SpectralAverages = 100;
                sa2.SpectrumType = 'Power';
                sa2.SpectrumUnits = 'dBFS';
                sa2.NumInputPorts = 1;
                sa2.FullScaleSource = 'Property';
                sa2.FullScale = 2^(16-1);
                sa2.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            for k=1:20
                % Pass through chip
                s = sw();
                s = fi(s,1,16,0);
                [o1,o2] = tx(s,s,s,s,s,s,s,s);
                if testCase.EnableVisuals
                    sa(o1);
                    sa2(o2);
                end
            end
            
            freqEst = testCase.estFrequency(double(o1),tx.SampleRate);
            truePos = tx.CDUCNCOFrequencies(1) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

            freqEst = testCase.estFrequency(double(o2),tx.SampleRate);
            truePos = tx.CDUCNCOFrequencies(2) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

         end
         
         function testAD9081TXFDUCNCO(testCase)
            
            tx = adi.sim.AD9081.Tx;
            tx.ChannelizerPathInterpolation = 4;
            tx.FDUCNCOFrequencies = [3e9, 2e9, 0, 0, 0, 0, 0, 0];
            tx.FDUCNCOEnable = [1, 1, 0, 0, 0, 0, 0, 0];
            
            %% Generate sinwave;
            sw = dsp.SineWave;
            sw.Amplitude = 2^14;
            sw.Frequency = 1.001e9;
            sw.SampleRate = tx.SampleRate/tx.ChannelizerPathInterpolation;
            sw.SamplesPerFrame = 1e4;
            
            if testCase.EnableVisuals
                sa = dsp.SpectrumAnalyzer;
                sa.SampleRate = tx.SampleRate;
                sa.YLimits = [-180 10];
                sa.SpectralAverages = 100;
                sa.SpectrumType = 'Power';
                sa.SpectrumUnits = 'dBFS';
                sa.NumInputPorts = 1;
                sa.FullScaleSource = 'Property';
                sa.FullScale = 2^(16-1);
                sa.CursorMeasurements.Enable = true;
            end
            
                sa2 = dsp.SpectrumAnalyzer;
                sa2.SampleRate = tx.SampleRate;
                sa2.YLimits = [-180 10];
                sa2.SpectralAverages = 100;
                sa2.SpectrumType = 'Power';
                sa2.SpectrumUnits = 'dBFS';
                sa2.NumInputPorts = 1;
                sa2.FullScaleSource = 'Property';
                sa2.FullScale = 2^(16-1);
                sa2.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            for k=1:20
                % Pass through chip
                s = sw();
                s = fi(s,1,16,0);
                [o1,o2] = tx(s,s,s,s,s,s,s,s);
                if testCase.EnableVisuals
                    sa(o1);
                    sa2(o2);
                end
            end
            
            freqEst = testCase.estFrequency(double(o1),tx.SampleRate);
            truePos = tx.FDUCNCOFrequencies(1) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

            freqEst = testCase.estFrequency(double(o2),tx.SampleRate);
            truePos = tx.FDUCNCOFrequencies(2) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

         end
         
         function testAD9081TXCDUCFDUCNCO(testCase)
            
            tx = adi.sim.AD9081.Tx;
            tx.ChannelizerPathInterpolation = 2;
            tx.MainDataPathInterpolation = 2;
            tx.FDUCNCOFrequencies = [2e9, 1.5e9, 0, 0, 0, 0, 0, 0];
            tx.FDUCNCOEnable = [1, 1, 0, 0, 0, 0, 0, 0];
            tx.CDUCNCOFrequencies = [1e9, 1e9, 0, 0];
            tx.CDUCNCOEnable = [1, 1, 0, 0];
            
            %% Generate sinwave;
            sw = dsp.SineWave;
            sw.Amplitude = 2^14;
            sw.Frequency = 1.001e9;
            sw.SampleRate = tx.SampleRate/...
                (tx.MainDataPathInterpolation*...
                tx.ChannelizerPathInterpolation);
            sw.SamplesPerFrame = 1e4;
            sw.ComplexOutput = true;
            
            if testCase.EnableVisuals
                sa = dsp.SpectrumAnalyzer;
                sa.SampleRate = tx.SampleRate;
                sa.YLimits = [-180 10];
                sa.SpectralAverages = 100;
                sa.SpectrumType = 'Power';
                sa.SpectrumUnits = 'dBFS';
                sa.NumInputPorts = 1;
                sa.FullScaleSource = 'Property';
                sa.FullScale = 2^(16-1);
                sa.CursorMeasurements.Enable = true;
            end
            
            sa2 = dsp.SpectrumAnalyzer;
            sa2.SampleRate = tx.SampleRate;
            sa2.YLimits = [-180 10];
            sa2.SpectralAverages = 100;
            sa2.SpectrumType = 'Power';
            sa2.SpectrumUnits = 'dBFS';
            sa2.NumInputPorts = 1;
            sa2.FullScaleSource = 'Property';
            sa2.FullScale = 2^(16-1);
            sa2.CursorMeasurements.Enable = true;
            
            %% Test MxFE
            for k=1:20
                % Pass through chip
                s = sw();
                s = fi(s,1,16,0);
                [o1,o2] = tx(s,s,s,s,s,s,s,s);
                if testCase.EnableVisuals
                    sa(o1);
                    sa2(o2);
                end
            end
            
            freqEst = testCase.estFrequency(double(o1),tx.SampleRate);
            truePos = tx.CDUCNCOFrequencies(1) + tx.FDUCNCOFrequencies(1) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

            freqEst = testCase.estFrequency(double(o2),tx.SampleRate);
            truePos = tx.CDUCNCOFrequencies(2) + tx.FDUCNCOFrequencies(2) + sw.Frequency;
            [~,loc] = min(truePos - freqEst);
            freqEst = freqEst(loc);            
            testCase.verifyEqual(freqEst,truePos,'RelTol',0.01,...
                'Frequency of DDS tone unexpected')

         end
         function testAD9081TXCDUCFDUCNCOPDP(testCase)
            
            tx = adi.sim.AD9081.Tx;
            tx.SHORT_PA_ENABLE = [0, 1, 0, 1];
            tx.SHORT_PA_AVG_TIME = [0, 0, 0, 0];
%            tx.SHORT_PA_POWER = [0, 0, 0, 0];
            tx.SHORT_PA_THRESHOLD = [1, 1, 1, 1]*3500;
            tx.LONG_PA_ENABLE = [0, 0, 1, 1];
            tx.LONG_PA_AVG_TIME = [1, 1, 1, 1];
%            tx.LONG_PA_POWER = [0, 0, 0, 0];
            tx.LONG_PA_THRESHOLD = [1, 1, 1, 1]*2000;
            tx.BE_GAIN_RAMP_RATE = [0, 0, 0, 0];
            tx.PA_OFF_TIME = [32, 32, 32, 32];
            tx.ChannelizerPathInterpolation = 2;
            tx.MainDataPathInterpolation = 4;
            tx.FDUCNCOFrequencies = [1, 1, 1, 1, 1, 1, 1, 1]*1e7;
            tx.FDUCNCOEnable = [1, 1, 1, 1, 1, 1, 1, 1];
            tx.CDUCNCOFrequencies = [1, 1, 1, 1]*1e9;
            tx.CDUCNCOEnable = [1, 1, 1, 1];
            tx.Crossbar8x8Mux =...
                [1, 1, 0, 0, 0, 0, 0, 0;
                 0, 0, 1, 1, 0, 0, 0, 0;
                 0, 0, 0, 0, 1, 1, 0, 0;
                 0, 0, 0, 0, 0, 0, 1, 1];
            
            %% Generate sinwave;
            sw = dsp.SineWave;
            sw.Amplitude = ones(1,8)*2^14;
            sw.Frequency = [-1 1 -1 1 -1 1 -1 1]*1e5;
            sw.SampleRate = tx.SampleRate/...
                (tx.MainDataPathInterpolation*...
                tx.ChannelizerPathInterpolation);
            sw.SamplesPerFrame = 1e4;
            sw.ComplexOutput = true;
            
            if testCase.EnableVisuals
                scope = dsp.TimeScope;
                scope.NumInputPorts = 4;
                scope.SampleRate = tx.SampleRate*[1, 1, 1, 1];
                scope.TimeSpan = sw.SamplesPerFrame/sw.SampleRate;
                scope.YLimits = [-1, 1]*2^15;
                scope.LayoutDimensions = [4,1];
            end
            
            
            %% Test MxFE
            for k=1:1
                % Pass through chip
                s = sw();
                s = fi(s,1,16,0);
                [o1,o2,o3,o4] = tx(s(:,1),s(:,2),s(:,3),s(:,4),s(:,5),s(:,6),s(:,7),s(:,8));
                if testCase.EnableVisuals
                    scope(o1, o2, o3, o4);
                    pause;
                end
            end
         end         
    end
    
end

