classdef analyze < handle
    % Analysis class for analysis of x-band development kit measurement data. This class
    % does post processing for a variety of system characterization tests.
    %

    properties
        dca; % dca object for FFT
        codeFmt; % code format for FFT
        axisFmt; % axis format for FFT
        axisType; % axis type for FFT
        window; % window initialized
        nfft = 4096; % FFT size for FFT
        navg = 1; % number of averages for FFT
        qres = 16; % bit resolution for FFT
        qresGrow = 20; % bit resolution for bit growth for FFT
        fz = 12;
        subfz = 11;
    end

    methods
        function obj = analyze()
            %ANALYZE Constructor for the analyze class
            genalyzer.load();
            obj.dca = genalyzer;
            obj.codeFmt    = obj.dca.CodeFormatTwosComplement;
            obj.axisFmt    = obj.dca.FreqAxisFormatFreq;
            obj.axisType   = obj.dca.FreqAxisTypeDcCenter;
            obj.window      = obj.dca.WindowNoWindow;

            analyze.updateAnalyzeCount(true);
        end

        function [fftResults,fftADCCodeDb] = FFT(obj, complexData, array, toneNum)
            %FFT FFT on ADC sample domain waveform data using Genalyzer
            %   input complexData waveforms received
            %   input array set to true or false
            %   input toneNum set to 'onetone' or 'twotone'
            %   output fftResults is map element of fft values
            %   output fftADCCodeDb is fft dB values


            chanNum = size(complexData,2); %Determines amount of channels measured
            numSets = size(complexData,3); % Determines number of data sets

            for d = 1:numSets
                for i=1:chanNum %Iterate for each channel measured
                    if array == true
                        qres1 = obj.qresGrow; %Account for bit growth
                    else
                        qres1 = obj.qres; %Do not need to account for bit growth
                    end

                    adcCode = complexData(:,i,d); %Assign adcCode to be measured complex data for iteration value through set
                    switch lower(toneNum)
                        case "twotone"
                            file = 'rx_2tone_800MSPS.json';
                        case "onetone"
                            file = 'rx_1tone_800MSPS.json';
                        otherwise
                            error('toneNum type unsupported. onetone or twotone are acceptable types.')
                    end

                    % Do FFT analysis
                    fftADCCode = obj.dca.fft(int64(real(adcCode))', int64(imag(adcCode))', qres1, obj.navg, obj.nfft, obj.window); %Performs fft on ADC data
                    fftADCCodeDb_hold = obj.dca.db(fftADCCode); %Put into dB scale
                    fftADCCodeDb_hold = obj.dca.fftshift(fftADCCodeDb_hold); %save frequency domain data to matrix
                    fftResults_hold = obj.dca.fft_analysis(file, fftADCCode, obj.nfft, obj.axisType); %Runs FFT analysis
                    if i==1 && d ==1 %if first iteration, initialize fft data based on size
                        fftADCCodeDb_length=length(fftADCCodeDb_hold); %find length of ADC code
                        fftADCCodeDb=zeros(chanNum,fftADCCodeDb_length); %initialize matrix for ADC code
                        fftResults=cell(chanNum,numSets); %initialize cell array
                    end
                    fftADCCodeDb(i,:,d)=fftADCCodeDb_hold; %Assign FFT for given channel
                    fftResults{i,d}=fftResults_hold; %Assign fftResults for given channel in cell array
                end
            end
        end

        function plotFFT(obj,fftADCCodeDb, overlay)
            %PLOTFFT Plots fft data recorded in fftADCCodeDb vairable
            %   input fftADCCodeDb from dB values returned from FFT method
            %   input overlay indicates whether the plots should be overlayed into
            %   one single plot (1), or separate subplots (0)

            obj.readableplots(); %Makes plot readable
            axis_type = obj.dca.FreqAxisTypeDcCenter; %Determines the axis type for the plot
            axis_fmt = obj.dca.FreqAxisFormatFreq; %Formats frequency for axis
            freq_axis = obj.dca.freq_axis(obj.nfft, axis_type, obj.fsRxIQ, axis_fmt); %Determines frequency axis
            Legend_text=cell(obj.numChannels,1); %Initializes legend text cell
            %figure();
            for i = 1:1:size(fftADCCodeDb,1) %Iterate through each channel
                if overlay==0 %Seperate subplots
                    subplot(obj.numChannels/4,4,i); %Set up subplots into 4 columns
                    plot(freq_axis/10^6,fftADCCodeDb(i,:)); %Plot FFT data
                    hold on; %Wait for next channel to be plotted
                    [y_max x_max]=max(fftADCCodeDb(i,:)); %Find maximum of FFT
                    plot(freq_axis(x_max)/10^6,y_max,'o','MarkerFaceColor','red'); %Plot red dot on each maximum
                    chan=num2str(i); %Channel number put to string
                    chan_lab=append('FFT Channel ',chan);%Labeling for FFT plot
                    title(chan_lab) %Title given
                    ylim([-110 0]) %Limits of plotting between -100 and 0 dBFS
                    xlim([-1*(obj.fsRxIQ)/2e6 obj.fsRxIQ/2e6]) %Plots up to +/- half the sampling frequency
                    grid on; %Grid for plotting
                    if mod(i,4)==1
                        ylabel('Magnitude (dBFS)')
                    end
                    if (i-obj.numChannels)>=(-3)&&(i-obj.numChannels)<=(0)
                        xlabel('Frequency (MHz)')
                    end
                end
                if overlay==1 %Single plot for all FFTs
                    plot(freq_axis/10^6,fftADCCodeDb(i,:)); %Plot FFT data
                    hold on; %Wait for next channel to be plotted
                    chan=num2str(i); %Channel # iterated over to string
                    chan_lab=append('Channel ',chan);%Labeling for FFT plot
                    Legend_txt{i}=chan_lab; %Legend updated for each channel measured
                    title('FFT Results') %Title given
                    ylim([-110 0]) %Limits of plotting between -100 and 0 dBFS
                    xlim([-1*(obj.fsRxIQ)/2e6 obj.fsRxIQ/2e6]) %Plots up to +/- half the sampling frequency
                    grid on; %Turn grid on
                    ylabel('Magnitude (dBFS)') %Ylabel for Magnitude
                    xlabel('Frequency (MHz)') %Xlabel for frequency
%                     if i==obj.numChannels
%                         legend(Legend_txt) %Establish legend
%                     end
                end
            end
        end

        function plotSamples(obj,data, overlay,xLimits,yLimits)
            %PLOTSAMPLES Plots sample domain data recorded in obj.rx() data
            %   capture
            %   input data from dB values returned from obj.rx()
            %   input overlay indicates whether the plots should be overlayed into
            %   one single plot (1), or separate subplots (0)

            if ~exist('xLimits','var')
                xLimits = [1 size(data,1)];
            end

            if ~exist('yLimits','var')
                yLimits = [-2^15 2^15];
            end

            obj.readableplots(); %Makes plot readable
            legendText=cell(obj.numChannels,1); %Initializes legend text cell
            %figure();

            for i = 1:1:size(data,2) %Iterate through each channel
                if overlay==0 %Seperate subplots
                    subplot(obj.numChannels/4,4,i); %Set up subplots into 4 columns
                    plot(real(data(:,i))); %Plot sample data
                    hold on; %Wait for next channel to be plotted
                    chan=num2str(i); %Channel number put to string
                    chanLab=append('Channel ',chan);%Labeling for Samples plot
                    title(chanLab) %Title given
                    ylim(yLimits) % y-axis limits
                    xlim(xLimits) % x-axis limits
                    grid on; %Grid for plotting
                    if mod(i,4)==1
                        ylabel('ADC Codes')
                    end
                    if (i-obj.numChannels)>=(-3)&&(i-obj.numChannels)<=(0)
                        xlabel('Samples')
                    end
                end
                if overlay==1 %Single plot for all FFTs
                    plot(real(data(:,i))); %Plot FFT data
                    hold on; %Wait for next channel to be plotted
                    chan=num2str(i); %Channel # iterated over to string
                    chanLab=append('Channel ',chan);%Labeling for FFT plot
                    legendText{i}=chanLab; %Legend updated for each channel measured
                    title('Sample Domain') %Title given
                    ylim(yLimits) % y-axis limits
                    xlim(xLimits) % x-axis limits
                    grid on; %Turn grid on
                    ylabel('ADC Codes') %Ylabel for Magnitude
                    xlabel('Samples') %Xlabel for frequency
                    if i==obj.numChannels
                        legend(legendText) %Establish legend
                    end
                end
            end
        end

        function plotFFTMetrics(obj,xAxis,data,metric,channel,sweepType)
            %PLOTFFTMETRICS Plots FFT metrics from data captures and post
            %   processing
            %
            %   input parameters
            %       xAxis: type = double
            %          Mx1 vector
            %       data: type = double
            %           MxNxZ matrix
            %       metric: type = string
            %           mag = magnitude
            %           nsd = noise spectral density
            %           snr = signal to noise ration
            %           sfdr = spurious free dynamic range
            %           imd3 = 3rd order intermodulation product
            %           oip3 = output 3rd order intercept
            %       channel: type = double
            %           1xN vector
            %       sweepType: type = string
            %           freq = frequency sweep
            %           power = power sweep

            if ~exist('metric','var')
                metric = 'mag'; %default to magnitude
            end

            if ~exist('channel','var')
                channel = 1:obj.numChannels;
            end

            if ~exist('sweepType','var')
                sweepType = 'freq';
            end

            switch lower(metric)
                case 'mag'
                    metricIdx = 2;
                    yAxisLabel = 'Magnitude [dBFS]';
                case 'nsd'
                    metricIdx = 5;
                    yAxisLabel = 'NSD [dBFS/Hz]';
                case 'snr'
                    metricIdx = 6;
                    yAxisLabel = 'Magnitude [dBFS]';
                case 'sfdr'
                    metricIdx = 7;
                    yAxisLabel = 'SFDR [dB]';
                case 'imd3'
                    metricIdx = 5;
                    yAxisLabel = 'IMD3 [dBc]';
                case 'oip3'
                    metricIdx = 6;
                    yAxisLabel = 'OIP3 [dBFS]';
            end

            switch lower(sweepType)
                case 'freq'
                    figure
                    plot(xAxis/1e9,squeeze(data(channel,metricIdx,1:length(xAxis))))
                    xlabel('Frequency [GHz]')
                    ylabel(yAxisLabel)
                    grid on
                case 'power'
                    figure
                    plot(xAxis,squeeze(data(channel,metricIdx,1:length(xAxis))))
                    xlabel('Power [dBm]')
                    ylabel(yAxisLabel)
                    grid on
            end

        end

        function plotPulseTrain(obj,pulseData)

            numPlots = size(pulseData,3);
            numSubPlot = size(pulseData,2);
            numData = size(pulseData,1);
            for pl = 1:numPlots
                figure(pl*30)
                for subPl = 1:numSubPlot
                    subplot(numSubPlot,1,subPl)
                    plot(real(pulseData(:,subPl,pl)))
                    xlim([0 300])
                end
            end
        end

        function [sumArrayFFTMagDB,deltaAzimFFTMagDB,deltaElevFFTMagDB] = otaFFT(obj, adc1, adc2, adc3, adc4)
            %OTAFFT  Analyzes the array data via FFT and returns
            %   magnitude information for sum array, delta az, and delta el
            %   Help: input raw adc data into method

            sumArray = adc1 + adc2 + adc3 + adc4;
            deltaAzimuth = (adc4 + adc2) - (adc1 + adc3);
            deltaElevation = (adc4 + adc3) - (adc2 + adc1);
            sumArrayFFTMagDB = zeros(size(sumArray, 1), size(sumArray, 2));
            deltaAzimFFTMagDB = zeros(size(sumArray, 1), size(sumArray, 2));
            deltaElevFFTMagDB = zeros(size(sumArray, 1), size(sumArray, 2));

            for elevationAngle = 1:size(sumArray, 1)
                for azimuthAngle = 1:size(sumArray, 2)
                    [sumArrayResultsFFT, ~] = obj.FFT(reshape(sumArray(elevationAngle, azimuthAngle, :), [4096, 1]),true,'onetone');
                    sumArrayFFTMagDB(elevationAngle, azimuthAngle) = sumArrayResultsFFT('A:mag_dbfs'); %sum array FFT
                    [deltaAzimResultsFFT, ~] = obj.FFT(reshape(deltaAzimuth(elevationAngle, azimuthAngle, :), [4096, 1]),true,'onetone');
                    deltaAzimFFTMagDB(elevationAngle, azimuthAngle) = deltaAzimResultsFFT('A:mag_dbfs'); %delta Azimuth FFT
                    [deltaElevResultsFFT, ~] = obj.FFT(reshape(deltaElevation(elevationAngle, azimuthAngle, :), [4096, 1]),true,'onetone');
                    deltaElevFFTMagDB(elevationAngle, azimuthAngle) = deltaElevResultsFFT('A:mag_dbfs'); %delta Elevation FFT
                end
            end
        end

        function [elemFFTMagDB,elemFFTPhaseRad,elemFFTComplex] = otaElemFFT(obj, adcData)
            %OTAELEMFFT Analyzes the per element data via FFT and returns
            %   magnitude and phase information
            %   Help:
            elemFFTMagDB = zeros(size(adcData, 1), size(adcData, 2)); %initialize FFT dB magnitude vector
            elemFFTPhaseRad = zeros(size(adcData, 1), size(adcData, 2)); %initialize FFT dB phase vector

            for measAngle = 1:size(adcData, 1)
                for numElem = 1:size(adcData, 2)
                    %individual element FFT
                    [elemResultsFFT, ~] = obj.FFT(reshape(adcData(measAngle, numElem, :), [4096, 1]),false,'onetone');
                    elemFFTMagDB(measAngle, numElem) = elemResultsFFT('A:mag_dbfs');
                    elemFFTPhaseRad(measAngle, numElem) = elemResultsFFT('A:phase');
                end
            end
            elemFFTComplex = 10.^(elemFFTMagDB/20).*exp(1j*elemFFTPhaseRad); %find FFT complex linear value
        end

        function monopulseFFT(obj, adc1, adc2, adc3, adc4)
            sumArray = adc1 + adc2 + adc3 + adc4;
            deltaAzimuth = (adc4 + adc2) - (adc1 + adc3);
            deltaElevation = (adc4 + adc3) - (adc2 + adc1);
        end

        function [beamWidth3DB, mainBeamAngle, maxMag] = beamWidth(obj,beamPattern,steeringAngles,cutType)
            %BEAMWIDTH  Measures the 3 dB beamwidth of a 2D beampattern
            %   Help: returns max beam position & 3 dB beamwidth in degrees

            [maxMag, idx] = max(beamPattern); %max value
            mainBeamAngle = steeringAngles(idx); %steering angle of max value

            [~,closestIdxLower] = min(abs(results(1:idx) - (results(idx)-3))); %find lower 3dB index
            [~,closestIdxUpper] = min(abs(results(idx:end) - (results(idx)-3))); %find upper 3dB index
            closestIdxUpper = idx + closestIdxUpper; %add idx
            beamWidth3DB = steeringAngles(closestIdxUpper) - steeringAngles(closestIdxLower); %3dB Beamwidth

        end

        function delete(obj)
            count = analyze.updateAnalyzeCount(false);

            if count == 0
                genalyzer.unload();
            end
        end

        function plotTxSFDR(obj, ncoFreq, cellArraySFDR, input)
            % ncoFreq = NCO frequencies where measurements are taken
            % cellArraySFDR = Multichannel and Single channel SFDR measurements
            % for the three spans combined into a single cell array
            % Input = 'All', Graph will display all channels for all spans
            % Input = 'Avg', Graph will display averages of each span for
            % single channel measurements
            % Input = Empty, Graph will show results for both All & Avg


            mcS1 = cellArraySFDR{1,1};
            mcS2 = cellArraySFDR{1,2};
            mcS3 = cellArraySFDR{1,3};
            scS1 = cellArraySFDR{1,4};
            scS2 = cellArraySFDR{1,5};
            scS3 = cellArraySFDR{1,6};
            Z = 1;
            if exist('input', 'var')
                Z = 0;
            end

            if  Z == 1 | input == 'All'
                a = 3;
                plotFreqVal = ncoFreq/1000000000;
                plotFreqValS23 = [9 10 11]';
                figure('Name','SFDR vs Frequency; All Channels');
                hold on
                plot(plotFreqVal, scS1, 'LineWidth',1, 'Color', 'red')
                plot(plotFreqValS23, scS2, 'LineWidth',1, 'Color', [0.4660 0.6740 0.1880])
                plot(plotFreqValS23, scS3, 'LineWidth',1, 'Color', [0.9290 0.6940 0.1250])
                plot(plotFreqVal, mcS1,'LineWidth',1, 'Color', 'blue')
                plot(plotFreqValS23, mcS2, 'LineWidth',1, 'Color', 'black')
                plot(plotFreqValS23, mcS3, 'LineWidth',1, 'Color', 'magenta')
                title('SFDR vs Frequency [All Single & Multi Channel]')
                xlabel('Frequency [GHz]')
                ylabel('SFDR [dB]')
                ylim([0 75]);
                legend({'Single Channel Span 1','','','','','','','','','','','','','','','', 'Single Channel Span 2','','','','','','','','','','','','','','','' 'Single Channel Span 3','','','','','','','','','','','','','','','', 'Multi Channel Span 1', ' Multi Channel Span 2', 'Multi Channel Span 3'},'Location','southwest')
                set(gca,'FontSize',obj.fz)
                note = sprintf('[Span 1 = 6 - 14 GHz; Span 2 = 20 MHz; Span 3 = 1 MHz]');
                subtitle(note,'FontSize',obj.subfz)
                grid on;

            end

            if  Z == 1 | input == 'Avg'
                plotFreqVal = ncoFreq/1000000000;
                plotFreqValS23 = [9 10 11]';

                for i = 1:41
                    scSFDRAvgS1(i,1) = mean(scS1(i,:));
                end

                for i = 1:3
                    scSFDRAvgS2(i,1) = mean(scS2(i,:));
                    scSFDRAvgS3(i,1) = mean(scS3(i,:));
                end

                figure('Name','SFDR vs Frequency; Single Channels Averaged');
                hold on
                plot(plotFreqVal, scSFDRAvgS1, 'LineWidth',1, 'Color', 'red')
                plot(plotFreqValS23, scSFDRAvgS2, 'LineWidth',1, 'Color', [0.4660 0.6740 0.1880])
                plot(plotFreqValS23, scSFDRAvgS3, 'LineWidth',1, 'Color', [0.9290 0.6940 0.1250])
                plot(plotFreqVal, mcS1,'LineWidth',1, 'Color', 'blue')
                plot(plotFreqValS23, mcS2, 'LineWidth',1, 'Color', 'black')
                plot(plotFreqValS23, mcS3, 'LineWidth',1, 'Color', 'magenta')
                title('SFDR vs Frequency [Averaged Single & Multi Channel]')
                xlabel('Frequency [GHz]')
                ylabel('SFDR [dB]')
                ylim([0 75]);
                legend({'Single Channel Span 1', 'Single Channel Span 2', 'Single Channel Span 3', 'Multi Channel Span 1', ' Multi Channel Span 2', 'Multi Channel Span 3'},'Location','southwest')
                set(gca,'FontSize',obj.fz)
                note = sprintf('[Span 1 = 6 - 14 GHz; Span 2 = 20 MHz; Span 3 = 1 MHz]');
                subtitle(note,'FontSize',obj.subfz)
                grid on

            end
        end



        function plotTxPowerOut(obj, ncoFreq, cellArrayMag, input)
            % ncoFreq = NCO frequencies where measurements are taken
            % cellArraySFDR = Multichannel and Single channel output measurements
            % for the three spans combined into a single cell array
            % Input = 'All', Graph will display all channels for all spans
            % Input = 'Avg', Graph will display averages of each span for
            % single channel measurements
            % Input = Empty, Graph will show results for both All & Avg

            mcS1 = cellArrayMag{1,1};
            mcS2 = cellArrayMag{1,2};
            mcS3 = cellArrayMag{1,3};
            scS1 = cellArrayMag{1,4};
            scS2 = cellArrayMag{1,5};
            scS3 = cellArrayMag{1,6};
            Z = 1;
            if exist('input', 'var')
                Z = 0;
            end
            if  Z == 1 | input == 'All'
                plotFreqVal = ncoFreq/1000000000;
                plotFreqValS23 = [9 10 11]';
                figure('Name','All Single Channel vs Multi Channel Power Measurements; All Spans');
                hold on
                grid on;
                plot(plotFreqVal, scS1, 'LineWidth',1, 'Color', 'red')
                plot(plotFreqValS23, scS2, 'LineWidth',1, 'Color', [0.4660 0.6740 0.1880])
                plot(plotFreqValS23, scS3, 'LineWidth',1, 'Color', [0.9290 0.6940 0.1250])
                plot(plotFreqVal, mcS1,'LineWidth',1, 'Color', 'blue')
                plot(plotFreqValS23, mcS2, 'LineWidth',1, 'Color', 'black')
                plot(plotFreqValS23, mcS3, 'LineWidth',1, 'Color', 'magenta')
                title('Tx Output Power vs Frequency [All Single & Multi Channel]')
                xlabel('Frequency [GHz]')
                ylabel('Output Power [dBm]')
                ylim([-70 0]);
                legend({'Single Channel Span 1','','','','','','','','','','','','','','','', 'Single Channel Span 2','','','','','','','','','','','','','','','' 'Single Channel Span 3','','','','','','','','','','','','','','','', 'Multi Channel Span 1', ' Multi Channel Span 2', 'Multi Channel Span 3'},'Location','southwest')
                set(gca,'FontSize',obj.fz)
                note = sprintf('[Span 1 = 6 - 14 GHz; Span 2 = 20 MHz; Span 3 = 1 MHz]');
                subtitle(note,'FontSize',obj.subfz)
            end

            if Z == 1 | input == 'Avg'
                plotFreqVal = ncoFreq/1000000000;
                plotFreqValS23 = [9 10 11]';

                for i = 1:41
                    scMagAvgS1(i,1) = mean(scS1(i,:));
                end

                for i = 1:3
                    scMagAvgS2(i,1) = mean(scS2(i,:));
                    scMagAvgS3(i,1) = mean(scS3(i,:));
                end

                figure('Name','Averaged Single Channel vs Multi Channel Power Measurements; All Spans');
                set(gca,'FontSize',12)
                hold on
                grid on
                plot(plotFreqVal, scMagAvgS1, 'LineWidth',1, 'Color', 'red')
                plot(plotFreqValS23, scMagAvgS2, 'LineWidth',1, 'Color', [0.4660 0.6740 0.1880])
                plot(plotFreqValS23, scMagAvgS3, 'LineWidth',1, 'Color', [0.9290 0.6940 0.1250])
                plot(plotFreqVal, mcS1,'LineWidth',1, 'Color', 'blue')
                plot(plotFreqValS23, mcS2, 'LineWidth',1, 'Color', 'black')
                plot(plotFreqValS23, mcS3, 'LineWidth',1, 'Color', 'magenta')
                title('Tx Output Power vs Frequency [Averaged Single & Multi Channel]')
                xlabel('Frequency [GHz]')
                ylabel('Power [dBm]')
                ylim([-70 0]);
                legend({'Single Channel Span 1', 'Single Channel Span 2', 'Single Channel Span 3', 'Multi Channel Span 1', ' Multi Channel Span 2', 'Multi Channel Span 3'},'Location','southwest')
                set(gca,'FontSize',obj.fz)
                note = sprintf('[Span 1 = 6 - 14 GHz; Span 2 = 20 MHz; Span 3 = 1 MHz]');
                subtitle(note,'FontSize',obj.subfz)
            end
        end

        function plotTxTones(obj, ncoFreq, specAnFreq, cellArrayDAC, basebandFreq, input)
            % ncoFreq = NCO frequencies where measurements are taken
            % cellArrayDAC = Multi & single channel single tone data
            % captures at each NCO frequency for each span
            % specAnFreq = Frequency set pulled from spec An
            % Input = 'S1' is span 1 (6 - 14 GHz)
            % Input = 'S2' is span 2 (20 MHz)
            % Input = 'S3' is span 3 (1 MHz)

            mcS1 = cellArrayDAC{1,1};
            mcS2 = cellArrayDAC{1,2};
            mcS3 = cellArrayDAC{1,3};
            scS1 = cellArrayDAC{1,4};
            scS2 = cellArrayDAC{1,5};
            scS3 = cellArrayDAC{1,6};
            Z = 1;
            if exist('input', 'var')
                Z = 0;
            end

            if Z == 1 | input == 'S1'
                for i = 1:size(ncoFreq)
                    f = ncoFreq(i,1);
                    f = f/1000000000;
                    figure('Name',['Tx Multi Channel ' num2str(f) ' GHz; 6 - 14 GHz Span']);
                    set(gca,'FontSize',12)
                    plotFreqValS1 = specAnFreq(:,1)/1000000000;
                    plot(plotFreqValS1,mcS1(:,:,i))
                    title(['16 Combined Channels Tx Output Power'])
                    xlabel('Frequency [GHz]')
                    ylabel('Output Power [dBm]')
                    ylim([-130 0]);
                    grid on;
                    set(gca,'FontSize',obj.fz)
                    note = sprintf('[8 GHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)

                    figure('Name', ['Tx Single Channels ' num2str(f) ' GHz; 6 - 14 GHz Span']);
                    hold on;
                    for j = 1:16

                        plot(plotFreqValS1, scS1(:,j,i))
                        grid on;
                        title(['16 Single Channels Tx Output Power'])
                        xlabel('Frequency [GHz]')
                        ylabel('Output Power [dBm]')
                        ylim([-130 0]);

                    end
                    set(gca,'FontSize',obj.fz)
                    note = sprintf('[8 GHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)
                    hold off
                end
            end

            if Z == 1 | input == 'S2'
                for i = 1:3
                    centerFreq = [9; 10; 11];
                    f = centerFreq(i,1);
                    figure('Name',['Tx Multi Channel ' num2str(f) ' GHz; 20 MHz Span']);
                    plotFreqValS2 = specAnFreq(:,i+1)/1000000000;
                    plot(plotFreqValS2,mcS2(:,:,i))
                    title(['16 Combined Channels Tx Output Power'])
                    xf1 = f + (basebandFreq/1000)- (20/2000);
                    xf2 = f + (basebandFreq/1000);
                    xf3 = f + (basebandFreq/1000) + (20/2000);
                    xf1Lim = xf1 - 0.000001;
                    xf3Lim = xf3 + 0.000001;
                    xticks([xf1, xf2, xf3])
                    xlabel('Frequency [GHz]')
                    ylabel('Output Power [dBm]')
                    ylim([-130 0]);
                    xlim([xf1Lim xf3Lim])
                    grid on;
                    set(gca,'FontSize',obj.fz)
                    note = sprintf('[20 MHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)

                    figure('Name', ['Tx Single Channels ' num2str(f) ' GHz; 20 MHz Span']);
                    hold on;
                    for j = 1:16

                        plot(plotFreqValS2, scS2(:,j,i))
                        grid on;
                        title(['16 Single Channels Tx Output Power'])
                        xlabel('Frequency [GHz]')
                        ylabel('Output Power [dBm]')
                        xticks([xf1, xf2, xf3])
                        ylim([-130 0]);
                        xlim([xf1Lim xf3Lim])
                    end
                    set(gca,'FontSize',obj.fz)
                    note = sprintf('[20 MHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)
                    hold off
                end
            end
            if Z == 1 | input == 'S3'
                for i = 1:3
                    centerFreq = [9; 10; 11];
                    f = centerFreq(i,1);
                    figure('Name',['Tx Multi Channel ' num2str(f) ' GHz; 1 MHz Span']);
                    plotFreqValS3 = specAnFreq(:,i+4)/1000000000;
                    plot(plotFreqValS3,mcS3(:,:,i))
                    title(['16 Combined Channels Tx Output Power'])
                    xlabel('Frequency [GHz]')
                    xf1 = f + (basebandFreq/1000)-(1/2000);
                    xf2 = f + (basebandFreq/1000);
                    xf3 = f + (basebandFreq/1000)+(1/2000);
                    xf1Lim = xf1 - 0.000001;
                    xf3Lim = xf3 + 0.000001;
                    xticks([xf1, xf2, xf3])
                    ylabel('Output Power [dBm]')
                    ylim([-130 0]);
                    xlim([xf1Lim xf3Lim])
                    grid on;
                    set(gca,'FontSize',12)
                    note = sprintf('[1 MHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)

                    figure('Name', ['Tx Single Channels ' num2str(f) ' GHz; 1 MHz Span']);
                    hold on;
                    for j = 1:16

                        plot(plotFreqValS3, scS3(:,j,i))
                        grid on;
                        title(['16 Single Channels Tx Output Power'])
                        xlabel('Frequency [GHz]')
                        xticks([xf1, xf2, xf3])
                        ylabel('Output Power [dBm]')
                        ylim([-130 0]);
                        xlim([xf1Lim xf3Lim])
                    end
                    set(gca,'FontSize',obj.fz)
                    note = sprintf('[1 MHz Span; NCO Frequency = %.2f GHz]', f);
                    subtitle(note,'FontSize',obj.subfz)
                    hold off
                end
            end
        end

        function plotPhaseNoise(obj, freq, phase_data, testType, i)
            low_span = 100;
            high_span = 10000000;
            side = ["east", "west"];
            figure;
            semilogx(freq,phase_data)
            spot_noise = transpose(phase_data((freq == 100)|(freq == 1000)|(freq == 10000)|(freq == 100000)|(freq == 1000000)|(freq == 10000000)));
            spot_noise_freq = [100,1000,10000,100000,1000000,10000000];
            grid("on")
            if testType == "T1"
                title(['Apollo ' num2str(i) ' A1 Residual Phase Noise'])
            end
            if testType == "T2"
                title(['Apollo ' num2str(i) ' A1 + CLK Residual Phase Noise'])
            end
            if testType == "T3"
                title('Power Supply Residual')
            end
            if testType == "T4"
                title(['Apollo ' num2str(i) ' Absolute PN Combined 4 Channels'])
            end
            if testType == "T5"
                title(['Apollo ' side(:,i) ' Absolute PN Combined 8 Channels'])
            end
            if testType == "T6"
                title('All Apollos Absolute PN Combined 16 Channel')
            end
            ylabel('Phase Noise Power (dBc/Hz)')
            xlim([low_span,high_span])
            ylim([(min(phase_data)-10) max(phase_data+10)])
            xlabel('Frequency Offset From Carrier')
            xticks([10.^(log10(low_span):log10(high_span))])
            xticklabels({'100 Hz','1 kHz','10 kHz','100 kHz','1 MHz','10 MHz'})


        end
    end

    methods(Static)
        function T = metricsFFT(dataFFT,dataType,toneType)
            %METRICSFFT extracts the pertinent FFT information using the
            %   Genalyzer engine.
            %
            %   parameters:
            %       dataFFT: type = cell
            %           Genalyzer analysis of FFT
            %       dataType (optional):   type = string
            %           'Table' data output is in table form (default).
            %           Only valid for 1 2D dataset
            %           'Matrix' data output is in matrix form. Ideal for
            %           3D datasets where 3rd dim is carrier frequency
            %       toneType (optional):   type = string
            %           'One' data output is in table form (default)
            %           'Two' data output is in matrix form

            if ~exist('dataType','var')
                dataType = 'table';
            end

            if ~exist('toneType','var')
                toneType = 'one';
            end

            chan = (1:size(dataFFT,1))'; % number of channels
            numSets = size(dataFFT,2); % number of datasets
            for d = 1:numSets
                for c = 1:length(chan)

                    mag(c,d) = dataFFT{c,d}('A:mag_dbfs');

                    if strcmpi(toneType,'twotone')
                        freqHi(c,d) = dataFFT{c,d}('B:freq');
                        magHi(c,d) = dataFFT{c,d}('B:mag_dbfs');
                        toneHi(c,d) = dataFFT{c,d}('2B-A:mag_dbfs');
                        toneLo(c,d) = dataFFT{c,d}('2A-B:mag_dbfs');
                        imd3Lo(c,d) = mag(c,d) - toneLo(c,d);
                        % oip3Lo(c,d) = mag(c,d) + (mag(c,d) - imd3Lo(c,d))/2;
                        oip3Lo(c,d) = mag(c,d) + (imd3Lo(c,d)/2);
                        imd3Hi(c,d) = magHi(c,d) - toneHi(c,d);
                        %oip3Hi(c,d) = magHi(c,d) + (magHi(c,d) - imd3Hi(c,d))/2;
                        oip3Hi(c,d) = magHi(c,d) + (imd3Hi(c,d)/2);
                    end
                    
                    if strcmpi(toneType,'two')
                        magHi(c,d) = dataFFT{c,d}('B:mag_dbfs');
                        toneLo(c,d) = dataFFT{c,d}('2A-B:mag_dbfs');
                        toneHi(c,d) = dataFFT{c,d}('2B-A:mag_dbfs');
                        imd3Lo(c,d) = mag(c,d) - toneLo(c,d);
                        oip3(c,d) = mag(c,d) + imd3Lo(c,d);
                    else
                    mag(c,d) = dataFFT{c,d}('A:mag_dbfs');
                    freq(c,d) = dataFFT{c,d}('A:freq');
                    phase(c,d) = dataFFT{c,d}('A:phase');
                    nsd(c,d) = dataFFT{c,d}('nsd');
                    snr(c,d) = dataFFT{c,d}('snr');
                    sfdr(c,d) = dataFFT{c,d}('sfdr');
                    end

                end
            end

            if strcmpi(dataType,'matrix')
                if strcmp(toneType,'onetone')
                    T(:,1,:) = chan.*ones(c,d);
                    T(:,2,:) = mag;
                    T(:,3,:) = freq;
                    T(:,4,:) = phase;
                    T(:,5,:) = nsd;
                    T(:,6,:) = snr;
                    T(:,7,:) = sfdr;
                else
                    T(:,1,:) = chan.*ones(c,d);
                    T(:,2,:) = mag;
                    T(:,3,:) = toneLo;
                    T(:,4,:) = freq;
                    T(:,5,:) = imd3Lo;
                    T(:,6,:) = oip3Lo;
                    T(:,7,:) = magHi;
                    T(:,8,:) = toneHi;
                    T(:,9,:) = freqHi;
                    T(:,10,:) = imd3Hi;
                    T(:,11,:) = oip3Hi;
                end
            else %if table
                if strcmp(toneType,'onetone')
                    T = table(chan,mag,freq,phase,nsd,snr,sfdr);
                    T.Properties.VariableNames = {'Channel' 'Mag' 'Freq' 'Phase' 'NSD' 'SNR' 'SFDR'};
                else
                    T = table(chan,mag,toneLo,freq,imd3Lo,oip3Lo,magHi,toneHi,freqHi,imd3Hi,oip3Hi);
                    T.Properties.VariableNames = {'Channel' 'Mag_Lo' 'Tone_Lo' 'Freq_Lo' 'IMD3_Lo' 'OIP3_Lo' 'Mag_Hi' 'Tone_Hi' 'Freq_Hi' 'IMD3_Hi' 'OIP3_Hi'};
                end
            end

            
        end



        %% Pulse Offset
        function phaseValues = pulseOffset(pulsedData,numChannels)
            %PULSEOFFSET Returns the phase values in a numChannels x 1
            %   row vector using the Spectrum Analyzer IQ Demodulator.

            if numChannels ~= 4 && numChannels ~= 2
                error('numChannels arugment must be integer value of 2 or 4')
            end

            minCodeValue = 0.005;
            % Align All Tx Channels
            % Now Find The Pulse Corresponding To Tx0
            if (abs(real(pulsedData(1,1)))>minCodeValue || abs(imag(pulsedData(1,1)))>minCodeValue || ...
                    abs(real(pulsedData(50,1)))>minCodeValue || abs(imag(pulsedData(50,1)))>minCodeValue) %Check if signal is present at start of capture
                [separation,initialCross,finalCross,nextCross,midLev] = ...
                    pulsesep(double(abs(real(pulsedData(:,1)))>minCodeValue));
                [maxVal, maxLoc] = max(separation);
                channel0Start = ceil(nextCross(maxLoc)); %The Tx0 pulse location
            else %Correct if signal is zero at start of capture
                [period,initialCross,finalCross,nextCross,midLev] = ...
                    pulseperiod(double(abs(real(pulsedData(:,1)))>minCodeValue));
                channel0Start = ceil(initialCross(1));
            end
            timeZeroAlignedFirstRx = circshift(pulsedData(:,1),-channel0Start);
            timeZeroAligned = circshift(pulsedData,-channel0Start);
            % Now Determine the Phase Offsets for Each Tx Channel
            for i=1:1:numChannels
                phaseValues(i,1) = angle(timeZeroAlignedFirstRx(15+(i-1)*50))*180/pi;
            end
            %             phaseValues = wrapTo180(txPhaseOffsets - txPhaseOffsets(size(txPhaseOffsets,2),1))';
        end
        %% Coherent Integrator
        function [dataAligned, dataSum] = coherentIntegrator(data)
            %COHERENTINTEGRATOR takes a dataset and performs a cross
            %   correlation function to time align. Multiple correlated
            %   pulses are then summed to increase the SNR.
            %   Input var, data, is assumed to be in a MxNxZ format. M is number of
            %   samples, N is number of channels, and Z is number of pulses
            %   dataAligned is the data matrix time aligned, if correlated in a MxNxZ matrix
            %   dataSum is the summed pulses, in a MxN matrix

            numChan = size(data,2); % number of channels
            numPulse = size(data,3); % number of pulses

            %if num pulses less than 2, then exit. don't want autocorr
            %             if numPulse < 2
            %                 disp('Need more than one pulse to use function properly');
            %                 return; % return to invoking function
            %             end

            %memory allocation
            dataAligned = zeros(size(data));
            r = zeros(2*size(data,1)-1,size(data,2),size(data,3)); % Size: (2*num Samples-1), num channels, num pulses
            lag = zeros(size(r)); % Size:  num channels, num pulses
            idx = zeros(size(data,3),size(data,2)); % Size: (2*num Samples-1), num channels, num pulses

            for n = 1:numChan % loop thru num channels
                for z = 1:numPulse % loop thru num pulses
                    if z == 1
                        dataAligned(:,n,z) = data(:,n,z); % data(:,n,1) is reference to align all other channels
                    else
                        [r(:,n,z),lag(:,n,z)] = xcorr(data(:,n,z),data(:,n,1)); % xcorr wrt pulse 1
                        [~,idx(z,n)] = max(r(:,n,z)); % find max xcorr factor for time align
                        dataAligned(:,n,z) = circshift(data(:,n,z),-1*lag(idx(z,n),n,z)); % shift by num samples to align to pulse 1
                    end
                end
            end

            dataSum = sum(dataAligned,3); % pulses summed per channel, return is a MxN matrix

        end
        %% Find P1dB Function
        function [inputP1dB, outputP1dB] = getP1dB(powInputs, powOutputs)
            %GETP1DB Returns the output and input P1dB values for power data
            %   Assumes a sweep size of at least 15 points.
            %   powInputs are array of power values put into the device. It
            %   should be one row by the number of input powers.
            %   powOutputs are an array actual measured power outputs from device
            %   under test at different frequencies. Each row is a freq, each
            %   column corresponds to an input power.
            %   doplot is {true., false}. True will plot power data versus ideal
            %   curve.

            % Allocate space for each freqency p1dB
            outputP1dB = zeros(size(powOutputs, 1), 1);
            inputP1dB = zeros(size(powOutputs, 1), 1);

            for freqIndx = 1:size(powOutputs, 1)
                % Flag in case sweep was not wide enough
                foundP1dB = false;

                %Apply a rolling average to remove noise
                smoothPowOutputs = movmean(powOutputs(freqIndx,:), 5);

                % Get the ideal linear curve, as well as the index the data
                % stops being linear
                [slope, intercept, endLinearRegion] = analyze.getLinearIdeal(powInputs, smoothPowOutputs);

                for inputIndx = endLinearRegion:numel(powInputs)-1 %Ignore last point due to noise
                    % Calculate how far off the output is from the ideal
                    diffFromIdeal = (powInputs(inputIndx)*slope + intercept) - smoothPowOutputs(inputIndx);

                    if diffFromIdeal >= 1
                        outputP1dB(freqIndx) = smoothPowOutputs(inputIndx);
                        inputP1dB(freqIndx) = powInputs(inputIndx);
                        foundP1dB = true;
                        break
                    end
                end

                if ~foundP1dB
                    fprintf("Sweep failed to find p1dB at #%d test freqency. Widen sweep and make sure initial measurements are not in noise floor.\n", freqIndx);
                end
            end
        end

        %% Find Psat
        function outPsat = getPsat(powInputs, powOutputs)
            %GETPSAT Find the beginning of saturation (where the slope is roughly zero)
            %   xVals is a 1xn array of x coordinates (power inputs)
            %   yVals is a mxn array of y coordinates (power outputs), one row
            %   per frequency

            outPsat = zeros(size(powOutputs, 1), 1);

            for freqIndx = 1:size(powOutputs, 1)
                satPts = analyze.findLinearPts(powInputs, powOutputs(freqIndx,:), 0, 0.2);
                outPsat(freqIndx) = mean(powOutputs(freqIndx,satPts));
            end
        end

        %% Find Linear Ideal Curve Functions
        function [slope, intercept, stop] = getLinearIdeal(powInputs, powOutputs)
            %GETLINEARIDEAL finds the linear ideal behavior of the device, as described by
            %   output = slope*input + intercept. Also returns the index of the
            %   last piece of data used to create the ideal linear curve.
            %   xVals is a 1xn array of x coordinates (power inputs)
            %   yVals is a 1xn array of y coordinates (power outputs)

            % Points should roughly fit a line with a slope of 1
            points = analyze.findLinearPts(powInputs, powOutputs, 1, 0.2);

            % Create ideal line based off of data
            idealLine = [ones(numel(points), 1) powInputs(points).']\powOutputs(points).';
            slope = idealLine(2);
            intercept = idealLine(1);
            stop = points(end);
        end

        function points = findLinearPts(xVals, yVals, targSlope, tolerance)
            %FINDLINEARPTS finds points that roughly fit a line with a target slope.
            %   xVals is a 1xn array of x coordinates (power inputs)
            %   yVals is a 1xn array of y coordinates (power outputs)
            %   targSlope is the slope of the line to fit to.
            %   tolerance is how far off a given slope can be and still be
            %   included.

            points = [];

            for i = 1:numel(xVals)-1
                diffFromTarg = (yVals(i+1)-yVals(i))/(xVals(i+1)-xVals(i)) - targSlope;
                if abs(diffFromTarg) < tolerance
                    points = [points i];
                end
            end

            if numel(points) < 2
                error("Not enough linear points found for slope %d.\n", targSlope);
            end
        end

        function currentCount = updateAnalyzeCount(isAddition)
            persistent count;

            if isempty(count)
                count = 0;
            end

            if isAddition
                count = count + 1;
            else
                count = count - 1;
            end

            currentCount = count;
        end

        %% Tx SFDR
        function [maxFreq,maxMag,SFDR] = findSFDR(freqSpectrum,magSpectrum,range)
            %FINDSFDR finds the spurious free dynamic range of a spectrum.
            %   Inputs are frequency and magnitude values of the spectrum.
            %   Returns the top 10 magnitudes and correpsonding frequencies
            %   in both absolute values and relative to max value.

            if exist('range','var')
                [~,closestIndexMin] = min(abs(freqSpectrum - range(1))); %subtract for minimum
                [~,closestIndexMax] = min(abs(freqSpectrum - range(2))); %subtract for maximum

                freqSpectrum = freqSpectrum(closestIndexMin:closestIndexMax); %frequency spectrum value
                magSpectrum = magSpectrum(closestIndexMin:closestIndexMax); %magnitude spectrum value
            end

            [maxMag,maxIdx] = maxk(magSpectrum,10);
            maxFreq = freqSpectrum(maxIdx); %find max frquency

            maxMag = maxMag; %set maximum magnitude
            maxFreq = maxFreq; %set max frequency
            magDBC = max(maxMag) - maxMag; %find max dbc
            magDBCSorted = sort(magDBC);
            SFDR = magDBCSorted(2,1);
            maxMag = max(maxMag);

        end
        %% Spur Killer
        function [bestSpectrum,bestMag,magDBC, idx] = findSpurKiller(freqSpectrum,magSpectrum,spurFreq)
            %FINDSPURKILLER finds the spurious free dynamic range of a spectrum.
            %   Inputs are frequency and magnitude values of the spectrum.
            %   Returns the top 10 magnitudes and correpsonding frequencies
            %   in both absolute values and relative to max value.

            for k = 1:size(freqSpectrum,2)
                [~,closestIndexSpur(k)] = min(abs(freqSpectrum(:,k) - spurFreq));
                spurMag(k) = magSpectrum(closestIndexSpur(k),k);
                carrierMag(k) = max(magSpectrum(:,k));
            end

            [~,idx] = min(spurMag); %find min spur value
            bestSpectrum = freqSpectrum(:,idx);
            bestMag = magSpectrum(:,idx);
            magDBC = carrierMag(idx) - spurMag(idx);
        end
        %% Readable Plots
        function readableplots(obj)
            %READABLEPLOTS Makes figures increasingly readable, increases font size
            %   and makes font LATEX

            fontsize=12; %Readable font size
            %             set(0, 'defaultfigurecolor', [1,1,1]); %White Background
            set(0,'defaultAxesFontSize', fontsize); %Set font size to larger
            set(0,'defaultlinelinewidth', 1); %Thicker line width for plotting
            set(0, 'defaultLegendInterpreter', 'latex') %Latex legend text
            set(0, 'defaultTextInterpreter', 'latex') %Latex text in general
        end
    end
end
