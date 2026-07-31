classdef quadApollo < handle & analyze
    %QUADAPOLLO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fsRxIQ = 400e6; % Instantaneous bandwidth [Hz]
        basebandFreq = 25e6; % Baseband frequency [Hz]
        txDBFS = -1; % Transmit Amplitude [dBFS]
        samplesPerFrameRx = 2^14; % Number of ADC samples to capture per frame
        samplesPerFrameTx = 2^13; % Number of DAC samples to capture per frame
        numChannels = 16; % Number of Tx/Rx channels in system
        kernelBuffersCount = 1;
        JTxSwing = hex2dec('90'); % FPGA GTY Post/Pre Emphasis
        uri = 'ip:192.168.2.1'; % Describes context location
        lpfSet = 15; % ADMV8913 Low Pass Filter Setting
        hpfSet = 5; % ADMV8913 High Pass Filter Setting
        bitRes = 16; % Bit Resolution for ADC
        rx; % rx object for quadApollo
        tx; % tx object for quadApollo
        t; % time cector based on data rate
        dacWaveform; % waveform for DAC DMA
        subFrame; % One subframe is equal to one 1/basebandFreq period of baseband freq
        numPulsePeriods = 8; % Number of 1/basebandFreq period pulses within pulse width
        numZeroPulsePeriods = 8; % Number Of 1/basebandFreq periods between pulse widths
        twoToneSpacing = 10e6; % Two-Tone Spacing, centered about baseband frequency
        

        
    end
    
    methods
        
        function obj = quadApollo(obj, uri)
            %QUADAPOLLO constructor for this class
            %
            %   input parameters
            %       uri: type = string
            %           example format 'ip:192.168.2.x'
            %
            %   output parameters
            %       obj: type = object
            
            if ~exist('uri','var')
                uri = obj.uri;
            end
            
            obj.rx = adi.QuadAD9084.Rx;
            obj.rx.uri = uri;
            obj.tx = adi.QuadAD9084.Tx;
            obj.tx.uri = uri;
            
        end
        
        function initialize(obj)
            %INITIALIZE initializes the quadApollo class
            obj.basebandFreq = obj.fsRxIQ/32;
            obj.enableMode('All');
            obj.enableRxChannels([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]);
            obj.enableTxChannels([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]);
            obj.setTxNCOFreq('Main', 10e9*ones(1,obj.numChannels));
            obj.setRxNCOFreq('Main',-2.8e9*ones(1,obj.numChannels))
            obj.setTxNCOPhase('Main', zeros(1,obj.numChannels));
            obj.setRxNCOPhase('Main', zeros(1,obj.numChannels));
            obj.setSamplesPerFrame(obj.samplesPerFrameRx,obj.samplesPerFrameTx);
            obj.setKernelBuffersCount(obj.kernelBuffersCount);
            obj.setDataSource('DMA');
            obj.setCyclicBuffers(1);
            obj.enableNCO(1);
            obj.setChannelNCOGainScale(0.5);
            obj.rx();
            %obj.setRxAtten(zeros(1, 4));
            obj.setFilter(obj.lpfSet, obj.hpfSet);
            % obj.calBrdExternalSMA; % configure cal board
            obj.qres = obj.numChannels; % bits for FFT
            obj.qresGrow = obj.numChannels + sqrt(obj.numChannels); % bits for FFT, bit growth
        end
        
        function enableMode(obj,option)
            %ENABLEMODE enables channels for modes Rx, Tx, or both.
            %   options specifies 'Rx', 'Tx', or 'All'
            %
            %   input parameters
            %       option: type = string
            %           option is either 'Rx', 'Tx', or 'All'
                        
            if strcmpi(option, 'Rx') %enable all RX
                obj.rx.EnableDevice0 = true;
                obj.rx.EnableDevice1 = true;
                obj.rx.EnableDevice2 = true;
                obj.rx.EnableDevice3 = true;
                
            elseif strcmpi(option, 'Tx') %enable all TX
                obj.tx.EnableDevice0 = true;
                obj.tx.EnableDevice1 = true;
                obj.tx.EnableDevice2 = true;
                obj.tx.EnableDevice3 = true;
                
            elseif strcmpi(option, 'All') %enable all TX and RX
                obj.rx.EnableDevice0 = true;
                obj.rx.EnableDevice1 = true;
                obj.rx.EnableDevice2 = true;
                obj.rx.EnableDevice3 = true;
                obj.tx.EnableDevice0 = true;
                obj.tx.EnableDevice1 = true;
                obj.tx.EnableDevice2 = true;
                obj.tx.EnableDevice3 = true;
                
            else
                fprintf('Incorrect input argument, Mode must be "Rx", "Tx", or "All" \n')
            end
        end
        
        function enableRxChannels(obj, channels)
            %ENABLERXCHANNELS sets the Rx ADCs to enable
            %
            %   input parameters
            %       channels: type = double
            %           1xN vector of channels
            %           vector values are linear indexed from 1:N
            
            obj.rx.EnabledChannels = channels;
        end
        
        function enableTxChannels(obj, channels)
            %ENABLETXCHANNELS sets the Tx DACs to enable
            %
            %   input parameters
            %       channels: type = double
            %           1xN vector of channels
            %           vector values are linear indexed from 1:N
            
            obj.tx.EnabledChannels = channels;
        end
        
        function setTxNCOFreq(obj,type,freq)
            %SETTXNCOFREQ sets Tx NCO frequency for each DAC
            %
            %   input parameters
            %       type: type = string
            %           type is either 'Main' or 'Channel'
            %           'Main' sets NCO frequency for the Main NCOs (coarse)
            %           'Channel' sets NCO frequency for the Channel NCOs (fine)
            %       freq: type = double
            %           1xN vector of frequency values in units of Hertz
            %           
            
             %freq=obj.reMapTx(freq); % maps values to proper DAC
            
            if strcmpi(type, 'Main') %sets main TX frequency for each chip
                obj.tx.MainNCOFrequenciesChipA = freq(:, (1:4));
                obj.tx.MainNCOFrequenciesChipB = freq(:, (5:8));
                obj.tx.MainNCOFrequenciesChipC = freq(:, (9:12));
                obj.tx.MainNCOFrequenciesChipD = freq(:, (13:16));
                
            elseif strcmpi(type, 'Channel') %sets channel TX frequency for each chip
                obj.tx.ChannelNCOFrequenciesChipA = freq(:, (1:4));
                obj.tx.ChannelNCOFrequenciesChipB = freq(:, (5:8));
                obj.tx.ChannelNCOFrequenciesChipC = freq(:, (9:12));
                obj.tx.ChannelNCOFrequenciesChipD = freq(:, (13:16));
                
            else
                fprintf('Incorrect input argument, type must be "Main" or "Channel" \n')
            end
        end
        
        function setRxNCOFreq(obj,type,freq)
            %SETRXNCOFREQ sets Rx NCO frequency for each ADC
            %
            %   input parameters
            %       type: type = string
            %           type is either 'Main' or 'Channel'
            %           'Main' sets NCO frequency for the Main NCOs (coarse)
            %           'Channel' sets NCO frequency for the Channel NCOs (fine)
            %       freq: type = double
            %           1xN vector of frequency values in units of Hertz
            %           values range from 
            
             
            
            if strcmpi(type, 'Main') %sets main RX frequency for each chip
                %freq=obj.reMapRx(freq); % maps values to proper ADC
                obj.rx.MainNCOFrequenciesChipA = freq(:, (1:4));
                obj.rx.MainNCOFrequenciesChipB = freq(:, (5:8));
                obj.rx.MainNCOFrequenciesChipC = freq(:, (9:12));
                obj.rx.MainNCOFrequenciesChipD = freq(:, (13:16));
                
            elseif strcmpi(type, 'Channel') %sets channel RX frequency for each chip
                %freq = obj.reMapRxNCOFreq(freq);
                obj.rx.ChannelNCOFrequenciesChipA = freq(:, (1:4));
                obj.rx.ChannelNCOFrequenciesChipB = freq(:, (5:8));
                obj.rx.ChannelNCOFrequenciesChipC = freq(:, (9:12));
                obj.rx.ChannelNCOFrequenciesChipD = freq(:, (13:16));
                
            else
                fprintf('Incorrect input argument, type must be "Main" or "Channel" \n')
            end
        end
        
        function setTxNCOPhase(obj, type, phases)
            %SETTXNCOPHASE sets the Tx phases for main and channel NCOs
            %
            %   input parameters
            %       type: type = string
            %           type is either 'Main' or 'Channel'
            %           'Main' sets NCO phases for the Main NCOs (coarse)
            %           'Channel' sets NCO phases for the Channel NCOs (fine)
            %       phases: type = double
            %           1xN vector of phase values in units of millidegrees
            %           values range from -180e3 to +180e3
            
             phases=obj.reMapTx(phases); % maps values to proper DAC
            
            if strcmpi(type, 'Main') %sets main TX phase for each chip
                obj.tx.MainNCOPhasesChipA = phases(:, (1:4));
                obj.tx.MainNCOPhasesChipB = phases(:, (5:8));
                obj.tx.MainNCOPhasesChipC = phases(:, (9:12));
                obj.tx.MainNCOPhasesChipD = phases(:, (13:16));
                
            elseif strcmpi(type, 'Channel') %sets channel TX phase for each chip
                obj.tx.ChannelNCOPhasesChipA = phases(:, (1:4));
                obj.tx.ChannelNCOPhasesChipB = phases(:, (5:8));
                obj.tx.ChannelNCOPhasesChipC = phases(:, (9:12));
                obj.tx.ChannelNCOPhasesChipD = phases(:, (13:16));
                
            else
                fprintf('Incorrect input argument, type must be "Main" or "Channel" \n')
            end
        end
        
        function setRxNCOPhase(obj, type, phases)
            %SETRXNCOPHASE sets the Rx phases for main and channel NCOs
            %
            %   input parameters
            %       type: type = string
            %           type is either 'Main' or 'Channel'
            %           'Main' sets NCO phases for the Main NCOs (coarse)
            %           'Channel' sets NCO phases for the Channel NCOs (fine)
            %       phases: type = double
            %           1xN vector of phase values in units of millidegrees
            %           values range from -180e3 to +180e3 
            
             phases=obj.reMapRx(phases); % maps values to proper ADC
            
            if strcmpi(type, 'Main') %sets main RX phase for each chip
                obj.rx.MainNCOPhasesChipA = phases(:, (1:4));
                obj.rx.MainNCOPhasesChipB = phases(:, (5:8));
                obj.rx.MainNCOPhasesChipC = phases(:, (9:12));
                obj.rx.MainNCOPhasesChipD = phases(:, (13:16));
                
            elseif strcmpi(type, 'Channel') %sets channel RX phase for each chip
                obj.rx.ChannelNCOPhasesChipA = phases(:, (1:4));
                obj.rx.ChannelNCOPhasesChipB = phases(:, (5:8));
                obj.rx.ChannelNCOPhasesChipC = phases(:, (9:12));
                obj.rx.ChannelNCOPhasesChipD = phases(:, (13:16));
                
            else
                fprintf('Incorrect input argument, type must be "Main" or "Channel" \n')
            end
        end
        
        function setSamplesPerFrame(obj, rxVal, txVal)
            %SETSAMPLESPERFRAME sets the samples per frame for the ADC/DAC
            %   value specifies the number of samples per frame
            %
            %   input parameters
            %       rxVal: type = double
            %           rxVal is a base 2 number. max is 2^15
            %       txVal: type = double
            %           txVal is a base 2 number. max is 2^15
            
            obj.nfft = rxVal; % sets fft number of samples to match data capture
            obj.rx.SamplesPerFrame = rxVal;
            obj.tx.SamplesPerFrame = txVal;
        end
        
        function setKernelBuffersCount(obj, value)
            %SETKERNALBUFFERSCOUNT sets the count of kernal buffers
            % value specifies the count of kernal buffers
            %
            %   input parameters
            %       value: type = double
            
            obj.rx.kernelBuffersCount = value;
        end
        
        function setRxAtten(obj, value)
            %SETRXATTEN sets the Rx DSA attenuation value for each
            %   respective data converter group. 
            %   Range is 0 to -31.5 in 0.5 dB steps.
            %   
            %   input parameters
            %       value: type = double
            %           1xN vector of attenuation values in units of dB

            if size(value,2) < 4
                fprintf('DSA set value size must 1x4 vector\n')
                return
            end

            if all(and(value<= 0, value >= -31.5))
                obj.rx.DSAChipA = value(1);
                obj.rx.DSAChipB = value(2);
                obj.rx.DSAChipC = value(3);
                obj.rx.DSAChipD = value(4);
            else
                fprintf('DSA set value out of range. Must be between -31.5 and 0\n')
                return
            end
        end
        
        function setDataSource(obj, type)
            %SETDATASOURCE sets the Tx data source
            %
            %   input parameters
            %       type: type = string
            %           type is either 'DMA' or 'DDS'
            %           'DMA' uses DMA buffer waveforms
            %           'DDS' uses Apollo on-chip DDS
            
            if strcmpi(type, 'DMA')
                obj.tx.DataSource = 'DMA';
                
            elseif strcmpi(type, 'DDS')
                obj.tx.DataSoruce = 'DDS';
                
            else
                fprintf('Incorrect input argument, type must be "DMA" or "DDS" \n')
            end
        end
        
        function setCyclicBuffers(obj, value)
            %SETCYCLICBUFFERS sets whether or not Tx waveform is cycled
            %   value set to 1 cycles Tx waveform
            %   value set to 0 does not cycle Tx waveform
            %
            %   input parameters
            %       value: type = boolean
            %           boolean to enable/disable DAC NCOs
            %           value set to 0 does not cycle buffers for DAC DMA
            %           value set to 1 cycles buffers for DAC DMA
            
            if value == 1
                obj.tx.EnableCyclicBuffers = 1;
                
            elseif value == 0
                obj.tx.EnableCyclicBuffers = 0;
                
            else
                fprintf('Incorrect input argument, value must be 0 or 1 \n')
            end
        end
        
        function enableNCO(obj, value)
            %ENABLENCO enables channel NCO across all chips
            %   value sets whether or not NCO is enabled (1 or 0)
            %
            %   input parameters
            %       value: type = boolean
            %           boolean to enable/disable DAC NCOs
            %           value set to 0 disables NCOs
            %           value set to 1 enables NCOs
            
            if value == 1 %enable TX NCOs for each chip
                obj.tx.NCOEnablesChipA = ones(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipB = ones(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipC = ones(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipD = ones(1,obj.tx.num_fine_attr_channels);
                
            elseif value == 0 %disable TX NCOs for each chip
                obj.tx.NCOEnablesChipA = zeros(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipB = zeros(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipC = zeros(1,obj.tx.num_fine_attr_channels);
                obj.tx.NCOEnablesChipD = zeros(1,obj.tx.num_fine_attr_channels);
                
            else
                fprintf('Incorrect input argument, value must be 0 or 1 \n')
            end
        end
        
        function setChannelNCOGainScale(obj, value)
            %SETCHANNELNCOGAINSCALE sets the gain scale for all channel NCOs
            %   value sets the gain scale (number between 0 and 1)
            %
            %   input parameters
            %       value: type = double
            %           value for setting NCO gain scale
            %           ranges from 0 to 1
            
            if (value >= 0 && value <= 1)
                obj.tx.ChannelNCOGainScalesChipA  = ones(1,obj.tx.num_fine_attr_channels).*value;
                obj.tx.ChannelNCOGainScalesChipB  = ones(1,obj.tx.num_fine_attr_channels).*value;
                obj.tx.ChannelNCOGainScalesChipC  = ones(1,obj.tx.num_fine_attr_channels).*value;
                obj.tx.ChannelNCOGainScalesChipD  = ones(1,obj.tx.num_fine_attr_channels).*value;
                
            else
                fprintf('Incorrect input argument, value cannot be greater than 1 or less than 0 \n')
            end
        end
        
        function setFilter(obj, lpfSet, hpfSet)
            %SETFILTER sets the ADMV8913 low and high pass filter settings
            %
            %   input parameters
            %       lpfSet: type = int
            %           integer value for low pass filter setting
            %       hpfSet: type = int
            %           integer value for high pass filter setting
            
%             system(['iio_attr -u ',obj.uri, ' -d lpf-ctrl mux_select ', num2str(lpfSet)]);
%             system(['iio_attr -u ',obj.uri, ' -d hpf-ctrl mux_select ', num2str(hpfSet)]);

            obj.rx.LPF = lpfSet;
            obj.rx.HPF = hpfSet;

        end
        
        function RxPlotSetup(obj)
            %RXPLOTSETUP sets up variables t and nfft to enable ADC plotting
            
            obj.nfftQuadApollo = obj.samplesPerFrameRx; %sets nfft based on samples of RX
            obj.t = 0:1/obj.fsRxIQ:(obj.nfftQuadApollo-1)/obj.fsRxIQ; % Create Time Vector Based on Data Rate
        end
        
        function mappedArray = reMapRx(obj,array)
            %REMAPRX addresses array for the Apollo chips to be called appropriately
            %   input is initials array addressing channels 1-16
            %   outputs correct mappedArray
            %
            %   input parameters
            %       array: type = double
            %           1xN vector
            %
            %   output parameters
            %       mappedArray: type = double
            %           1xN vector
            
            mappedArray = array; %initializes array for remapping
            mappedArray(3) = array(4);  %flips spots 3 and 4
            mappedArray(4) = array(3); %flips spots 4 and 3
            mappedArray(7) = array(8); %flips spots 7 and 8
            mappedArray(8) = array(7); %flips spots 8 and 7
            mappedArray(11) = array(12); %flips spots 11 and 12
            mappedArray(12) = array(11); %flips spots 12 and 11
            mappedArray(15) = array(16); %flips spots 15 and 16
            mappedArray(16) = array(15); %flips spots 16 and 15
            
        end
        
        function mappedArray = reMapTx(obj,array)
            %REMAPTX addresses array for the Apollo chips to be called appropriately
            %   input is initial array addressing channels 1-16
            %   outputs correct mappedArray
            %
            %   input parameters
            %       array: type = double
            %           1xN vector
            %
            %   output parameters
            %       mappedArray: type = double
            %           1xN vector
            
            mappedArray = array; %initializes array for remapping
            mappedArray(1) = array(2);  %flips spots 1 and 2
            mappedArray(2) = array(1); %flips spots 2 and 1
            mappedArray(5) = array(6); %flips spots 5 and 6
            mappedArray(6) = array(5); %flips spots 6 and 5
            mappedArray(9) = array(10); %flips spots 9 and 10
            mappedArray(10) = array(9); %flips spots 10 and 9
            mappedArray(13) = array(14); %flips spots 13 and 14
            mappedArray(14) = array(13); %flips spots 14 and 13
            
        end

        function mappedArray = reMapRxNCOFreq(obj,array)
            %REMAPTX addresses array for the Apollo chips to be called appropriately
            %   input is initial array addressing channels 1-16
            %   outputs correct mappedArray
            %
            %   input parameters
            %       array: type = double
            %           1xN vector
            %
            %   output parameters
            %       mappedArray: type = double
            %           1xN vector
            
            mappedArray = array; %initializes array for remapping
            mappedArray(3) = array(4);  %flips spots 1 and 2
            mappedArray(4) = array(3); %flips spots 2 and 1
            mappedArray(7) = array(8); %flips spots 5 and 6
            mappedArray(8) = array(7); %flips spots 6 and 5
            mappedArray(11) = array(12); %flips spots 9 and 10
            mappedArray(12) = array(11); %flips spots 10 and 9
            mappedArray(15) = array(16); %flips spots 13 and 14
            mappedArray(16) = array(15); %flips spots 14 and 13
            
        end
        
        %         function [phaseOffset, passFail] =rxCal(obj,numberFrames)
        %             %RXCAL aligns the phases of the Rx channels
        %             %output passFail indicates whether algorithm ran successfully (1)
        %
        %             passFail=0; %initializes passFail variable
        %             phaseHold=zeros(obj.numChannels,1); %initialize array of phase (radians) values
        %             phaseChange=zeros(obj.numChannels,1); %initialize array of phase (radians) changes needed
        %             phaseOffset=zeros(obj.numChannels,1); %initialize array of phase (degrees) changes needed
        %
        %             if numberFrames > 1 % capture single frame
        %                 rxData(:,:) = obj.rx();
        %             else % capture multiple frames
        %                 for k = 1:numberFrames %
        %                     rxData(:,:,k) = obj.rx();
        %                 end
        %             end
        %
        %             for i=1:obj.numChannels
        %                 data1=rxData(:,i); %establish data being looked at
        %                 fftRes=fftshift(fft(data1)); %fft of data considered
        %                 absSpec=abs(fftRes); %absolute value of fft
        %                 [~, xMax]=max(absSpec); %find maximum value of fft
        %                 phaseHold(i)=angle(fftRes(xMax)); %hold phase for angle at carrier
        %                 phaseChange(i)=phaseHold(i)-phaseHold(1); %change in phase compared to reference waveform
        %                 phaseOffset(i)=wrapTo180(180/pi*phaseChange(i)); %change to degrees
        %             end
        %
        %             obj.setRxNCOPhase('Main', 1e3*phaseOffset'); %Sets phase changes for RX
        %
        %             if 1
        %                 passFail=1; %output if all is successful with calibration
        %             end
        %         end
        
        function phaseOffset = nullPowerCal(obj,mode, numChan, refChan, phaseStart, phaseStop, phaseStep)
            %NULLPOWERCAL executes null power method calibration based on
            %   Tx or Rx input. The method involves keeping a reference
            %   signal at a fixed phase. The target signal phase is rotated
            %   from 0 to 360 degrees while magnitude is recorded for each
            %   phase step. 180 degrees is added to the phase value
            %   at which the magnitude of the two sinusoids cancel and
            %   create a null.
            %
            %   input parameters
            %       mode: type = string
            %           mode is 'rx' or 'tx'
            %       numChan: type = double
            %           number of channels to calibrate, single value
            %       refChan: type = double
            %           specify which channel number to use as reference
            %       phaseStart: type = double
            %           phase sweep start value in units degrees
            %       phaseStope: type = double
            %           phase sweep stop value in units degrees
            %       phaseStep: type = double
            %           phase step size value in units degrees
            %
            %   output parameters
            %       phaseOffset: type = double
            %           1xN vector of phase offsets per channel relative to
            %           specified reference channel
            
            if ~exist('mode','var')
                mode = 'rx';
            end
            if ~exist('numChan','var')
                numChan = obj.numChannels;
            end
            if ~exist('refChan','var')
                refChan = 1;
            end
            if ~exist('phaseStart','var')
                phaseStart = -180;
            end
            if ~exist('phaseStep','var')
                phaseStep = 10; % degrees
            end
            if ~exist('phaseStop','var')
                phaseStop = 180 - phaseStep;
            end
            
            phaseSweep = phaseStart:phaseStep:phaseStop; % define phase sweep
            phaseOffset = zeros(1,numChan);  % allocate memory
            mag = zeros(length(phaseSweep),numChan);  % allocate memory
            cwWave = obj.createWaveform('cw'); %create CW DMA waveform
            obj.tx(cwWave); % transmit DMA waveform
            obj.calBrdCombinedLoopback; % combine all DACs and loopback to ADCs
            
            if strcmpi(mode,'rx') % rx mode
                obj.setRxNCOPhase('Main',zeros(1,obj.numChannels)); % set all Rx NCO phases to zero
                preCalData = obj.rx(); % data capture pre calibration
                refData = preCalData(:,refChan); % reference channel data
                for p = 1:length(phaseSweep) % rotate phase across sweep vals
                    data = preCalData*exp(1j*phaseSweep(p)*pi/180); % phase shifted data
                    data = data+refData; % add phase shift data and reference data
                    [FFTMetrics, ~] = obj.FFT(data,false,'onetone'); % perform FFT
                    for c = 1:numChan
                        mag(p,c) = FFTMetrics{c}('A:mag_dbfs'); % extract mag for each channel
                    end
                end
                
            else % tx mode
                %cwWave = obj.createWaveform('cw'); %create DMA waveform
                %refWave = cwWave(:,1); % reference waveform
                
                targChan = 1:numChan; % create list channels
                targChan(refChan) = []; % remove ref channel
                testWave = obj.createWaveform('cw',-1,obj.basebandFreq);
                

                for c = 1:length(targChan)
                    txNCO = zeros(1,16);
                    obj.setTxNCOPhase('Main',zeros(1,obj.numChannels)); % set all Tx NCO phases to zero
                    obj.txWaveform(testWave,[refChan,targChan(c)]);
                    
                    phaseSweepAll = zeros(length(phaseSweep),numChan); % create matrix for all channels
                    phaseSweepAll(:,refChan) = zeros(length(phaseSweep),1); % set ref chan phase to zero
                    
                    for p = 1:length(phaseSweep)
                        txNCO(targChan(c)) = phaseSweep(p);
                        obj.setTxNCOPhase('Main',wrapTo180(txNCO)*1e3); % set TX NCO phase
                        preCalData(:,:,p) = obj.rx(); %ADC data capture
                    end
                        [FFTMetrics, ~] = obj.FFT(preCalData,false,'onetone'); % perform FFT
                        FFTdata = obj.metricsFFT(FFTMetrics,'matrix','onetone'); % extract FFT magnitude
                        mag(:,targChan(c)) = FFTdata(1,2,:);
                end
            end
            
            [~, minPhaseIdx] = min(mag,[],1); % find min mag index for each channel
            phaseOffset = wrapTo180(phaseSweep(minPhaseIdx)+180); % extract phase offset
            phaseOffset(refChan) = 0; % set ref channel to 0 degree phase
            
            %x.setTxNCOPhase('Main',(wrapTo180(phaseOffset))*1e3);
%             wave = obj.createWaveform('cw',-1,obj.basebandFreq);
%             obj.txWaveform(wave);
%             obj.calBrdExternalSMA
            

            
        end
        
        function phaseOffset = xCorrCal(obj,mode, numChan, refChan)
            %XCORRRCAL executes cross correlation calibration based on
            %   Tx or Rx input. The method involves keeping a reference
            %   signal at a fixed phase. The target signal phase cross
            %   correlated with the reference signal determining the
            %   complex phase difference.
            %
            %   input parameters
            %       mode: type = string
            %           mode is 'rx' or 'tx'
            %       numChan: type = double
            %           number of channels to calibrate, single value
            %       refChan: type = double
            %           specify which channel number to use as reference
            %
            %   output parameters
            %       phaseOffset: type = double
            %           1xN vector of phase offsets per channel relative to
            %           specified reference channel            
            
            if ~exist('mode','var')
                mode = 'rx';
            end
            if ~exist('numChan','var')
                numChan = obj.numChannels;
            end
            if ~exist('refChan','var')
                refChan = 1;
            end
            
            phaseOffset = zeros(1,numChan); % allocate memory
            targChan = 1:numChan; % create list of target channels
            targChan(refChan) = []; % remove reference channel
            
            cwWave = obj.createWaveform('cw'); %create CW DMA waveform
            refWave = cwWave(:,1); % reference waveform
            obj.tx(cwWave); % transmit DMA waveform
            
            if strcmpi(mode,'rx') % rx mode
                obj.calBrdCombinedLoopback; % combine all DACs and loopback to ADCs
                obj.setRxNCOPhase('Main',zeros(1,obj.numChannels)); % set all Rx NCO phases to zero
            else   % tx mode
                obj.setTxNCOPhase('Main',zeros(1,obj.numChannels)); % set all Rx NCO phases to zero
                obj.calBrdCombinedLoopback; % DAC adjacent loopback to corresponding ADC
            end
            
            preCalData = obj.rx(); % data capture pre calibration
            
            for c = 1:length(targChan)
                [r0(:,c),lags(:,c)] = xcorr(preCalData(:,refChan),preCalData(:,targChan(c)));
                [pk0(c),idx0(c)] = max(real((r0(:,c)))); % find max xcorr factor for time align
                phaseOffset(targetChan(c)) = wrapTo180(angle(r0(idx0(c),c))*180/pi);
            end
            
            
        end
        
        function [txPhaseOffset, rxPhaseOffset] =systemCal(obj,mode)
            %SYSTEMCAL calibrates using pulsed waveform through phase allignment
            %   and plot the ideally phase alligned TX pulses
            %
            %   input parameters
            %       mode: type=string
            %          'combine' or 'external' based on calibration board
            %           mode
            %
            %   output parameters
            %       txPhaseOffset: type = double
            %           1xN relative phase offsets for DAC NCO phase shifters
            %       rxPhaseOffset: type = double
            %           1xN relative phase offsets for ADC NCO phase shifters
            
            if ~exist('mode','var')
                mode = 'combine';
            end
            
            if strcmpi(mode,'combine')
                obj.calBrdCombinedLoopback;
            elseif strcmpi(mode,'external')
                obj.calBrdExternalSMA;
            end
            
            [waveform] = obj.createWaveform('pulsed', -1,obj.basebandFreq, true); %creates pulsed waveform for the system
            obj.txWaveform(waveform);
            
            obj.setTxNCOPhase('Main',zeros(1,16));
            obj.setRxNCOPhase('Main',zeros(1,16));
            obj.setTxNCOPhase('Channel', zeros(1,16));
            obj.setRxNCOPhase('Channel', zeros(1,16));
            
            for k = 1:10 % capture multiple frames for coherent integration
                data(:,:,k) = obj.rx();
            end
            
            [dataCoh, dataSum] = obj.coherentIntegrator(data); % time align & sum multiple data frames
            
            [dataSumAlign, phaseXCORR] = obj.zeroAlignXCORR(dataSum,waveform(:,1));
            
            [verifiedIds, badIds] = obj.pulseAlignCheck(dataSumAlign); % Checks pulse trains to be sure there is atleast one aligned to sample zero, store which pulse trains are which
                                
            [dataSumAlign, phaseXCORR, verifiedIds] = obj.reCal(badIds, dataSumAlign, phaseXCORR); % Will rerun data captures until it has atleast one pulse train aligned to zero

            for a = 1:size(dataSumAlign,2) %iterate through all channels
                for d=1:obj.numChannels %iterate through all DAC pulses
                    pulseIdx(d)=obj.subFrame*(obj.numPulsePeriods-2) + (d-1)*(obj.numZeroPulsePeriods*obj.subFrame+obj.subFrame*(obj.numPulsePeriods)); % separation between pulses, num samples
                    %txPulsePhase(d,a) = angle(dataSumAlign(pulseIdx(d),a))*180/pi; %align phase using sample period separation between pulses
                    %txPulsePhase(d,a) = (angle(dataSumAlign(pulseIdx(d),a)) - angle(waveform(pulseIdx(d),a)))*180/pi;
                    txPulsePhase(d,a) = wrapTo180((angle(dataSumAlign(pulseIdx(d),a)) - (angle(dataSumAlign(pulseIdx(1),a))))*180/pi);
                end
            end

            txPhaseOffset = -1*wrapTo180(txPulsePhase(:,verifiedIds(1,1))-txPulsePhase(1,verifiedIds(1,1)))';
            rxPhaseOffset = -1*wrapTo180(phaseXCORR(:,verifiedIds(1,1))-phaseXCORR(1,verifiedIds(1,1)))';
            %rxPhaseOffset = -1*wrapTo180(phaseXCORR-phaseXCORR(1));
            
            
%             obj.setTxNCOPhase('Main', (wrapTo180(txPhaseOffset))*1e3);
%             wave = obj.createWaveform('cw',-1,obj.basebandFreq);
%             obj.txWaveform(wave);
%             obj.calBrdExternalSMA
            
            %%
            %methodology to autocorrelate all other pulses and pick off
            %phase offsets. Wasn't able to pull accurate phase using this
            %method. in debug mode
            %
            %             %time align other pulses
            %             factor = obj.samplesPerFrameRx/obj.samplesPerFrameTx; % factor to determine total number of pulses
            %             for c=1:obj.numChannels % num Channels
            %                 % max peaks for positive correlation
            %                 [rMax(:,c),lags1(:,c)] = xcorr(circshift((waveform(:,2)),-1*(obj.numPulsePeriods+obj.numZeroPulsePeriods)*obj.subFrame),dataSumAlign(:,c),'none'); % xcorr for other pulses
            % %                 [rMax(:,c),lags1(:,c)] = xcorr(waveform(:,1),dataSumAlign(:,c),'none'); %xcorr for other pulses
            %
            %                 [pks1,locs1] = findpeaks(real(rMax(:,c)),'MinPeakDistance',50); % separate search by 50 samples
            %                 [maxPks(:,c),maxPksIdx(:,c)] = maxk(pks1,obj.numChannels*factor); % top N unordered max peaks, real
            %                 maxPksLoc = ismember(real(rMax(:,c)),maxPks(:,c)); % ordered max peaks index
            %                 maxPksOrd(:,c) = rMax(maxPksLoc,c); % max peaks in pulse order
            %                 maxPksOrdLag(:,c) = lags1(maxPksLoc,c); % max peaks in pulse order
            %
            %                 % min peaks for negative correlation
            %                 rMin(:,c) = -1*rMax(:,c);
            %                 [pks2,locs2] = findpeaks(real(rMin(:,c)),'MinPeakDistance',50); % separate search by 50 samples
            %                 [minPks(:,c),minPksIdx(:,c)] = maxk(pks2,obj.numChannels*factor); % top N unordered min peaks, real
            %                 minPksLoc = ismember(real(rMin(:,c)),minPks(:,c)); % ordered min peaks index
            %                 minPksOrd(:,c) = rMin(minPksLoc,c); % min peaks in pulse order
            %                 minPksOrdLag(:,c) = lags1(minPksLoc,c); % min peaks in pulse order
            %
            %                 %search for abs peak & index
            %                 for m = 1:length(maxPksOrd)
            %                     if real(maxPksOrd(m,c)) > real(minPksOrd(m,c))
            %                         absPksOrd(m,c) = maxPksOrd(m,c);
            %                         absPksOrdLag(m,c) = maxPksOrdLag(m,c);
            %                     else
            %                         absPksOrd(m,c) = -1*minPksOrd(m,c);
            %                         absPksOrdLag(m,c) = minPksOrdLag(m,c);
            %                     end
            %                 end
            %
            %                 absPksOrd(:,c) = flip(absPksOrd(:,c)); % reverse order, pulse 1 to pulse N
            %                 absPksOrdLag(:,c) = flip(absPksOrdLag(:,c)); % reverse order, pulse 1 to pulse N
            %
            %                 for d=1:obj.numChannels % num pulses,
            %                     %testWave(:,d,c) = circshift(dataSumAlign(:,c),maxPksOffset(d,c));
            %                     if d == 1
            %                         testWave(:,d,c) = dataSumAlign(:,c); % copy over, do nothing since already aligned to sample 0
            %                     else
            %                         testWave(:,d,c) = circshift(dataSumAlign(:,c),absPksOrdLag(d,c));
            %                         phaseXCORR(d,c) = wrapTo180(angle(absPksOrd(d,c))*180/pi);
            %                     end
            %                 end
            %             end
            
            %             txPhaseOffsetB = wrapTo180(phaseXCORR - phaseXCORR(1,:));
            %             txPhaseOffset =  txPhaseOffsetB(:,1)';
            %             rxPhaseOffsetB = wrapTo180(phaseXCORR - phaseXCORR(:,1)); % sets angles to be applied for RX phase offsets
            %             rxPhaseOffset = rxPhaseOffsetB(1,:);
            
        end
        
        function [goodCalIds, badCalIds] = pulseAlignCheck(obj, pulseData)
            % This function will identify and select good/bad pulse trains
            % for further processing
                badCalIds(1,1) = 17;
                goodCalIds(1,1) = 17;
                N = 1;
                M = 1;
                for i = 1:16
                    for j = 1:25
                        if real(pulseData(j,i)) > 450 || real(pulseData(j,i)) < -450
                            goodCalIds(N,1) = i;
                            N = N + 1;
                            break
                        end
                    end
                    if goodCalIds(1,1) == 17
                        badCalIds(M,1) = i;
                        M = M + 1;
                    end    
                end
        end

        function [txRawCal, rxRawCal, verifiedIds] = reCal(obj, badCalIds, dataAlign, xcorr)
            % This will evaluate if the data taken is properly aligned to
            % sample zero and decide if a recapture of data is necessary
            % badCalIds: generated by function pulseAlignCheck and it
            % identifies individual pulse trains that are not aligned
            % dataAlign: data from original data capture that will be
            % passed through if a properly shifted pulse train is detected
            % xcorr: data from original data capture that will be
            % passed through if a properly shifted pulse train is detected
            % txRawCal: replacement for dataAlign if all 16 pulses are
            % misaligned
            % rxRawCal: replacement for xcorr if all 16 pulses are
            % misaligned


            txRawCal = dataAlign;
            rxRawCal = xcorr;
            
            b = obj.tx.MainNCOFrequenciesChipA(1,1);
            c = b/1e9;
            while length(badCalIds) == 16
                
                status = (['Recalibrating for ' num2str(c) ' GHz...']);
                disp(status)
                
                [waveform] = obj.createWaveform('pulsed', -1,obj.basebandFreq, true); %creates pulsed waveform for the system
                obj.txWaveform(waveform);

                for k = 1:10 % capture multiple frames for coherent integration
                    data(:,:,k) = obj.rx();
                end

                [dataCoh, dataSum] = obj.coherentIntegrator(data); % time align & sum multiple data frames

                [txRawCal, rxRawCal] = obj.zeroAlignXCORR(dataSum,waveform(:,1));

                [~, badCalIds] = obj.pulseAlignCheck(txRawCal);

            end
                
                status = (['Calibration for ' num2str(c) ' GHz verified!']);
                disp(status);
            
                [verifiedIds, ~] = obj.pulseAlignCheck(txRawCal);

        end

        function [passFail, combineGain] = validateCal(obj,mode,numChan)
            %VALIDATECAL captures data to validate the calibration
            %   This method assumes the proper amplitude and phase offsets
            %   have been applied prior to executing. To validate the Tx
            %   calibration, the cal board mode will be set to combined
            %   loopback and data captured from a single ADC. The FFT mag for
            %   a single DAC output and combined DAC output will be compared.
            %   To validate the Rx calibration, the cal board will be set to
            %   combined loopback. The captured ADC data will be summed and
            %   an FFT will be performed. The FFT mag for a single ADC and
            %   combined ADC will be compared. In both cases, the magnitude
            %   increse should be close to 20*log10(numChannels).
            %
            %   input parameters
            %       mode: type=string
            %           'rx' or 'tx'
            %       numChan: type=double
            %           numChan is a single value
            %
            %   output parameters
            %       passFail: type = boolean
            %           pass/fail critera based on combining gain
            %       combineGain: type = double
            %           combined gain value based on calibration efficacy
            
            
            if ~exist('mode','var')
                mode = 'rx';
            end
            if ~exist('numChan','var')
                numChan = obj.numChannels;
            end
            
            cwWave = obj.createWaveform('cw'); %create CW DMA waveform
            
            if strcmpi(mode,'rx') % rx mode
                
                obj.txWaveform(cwWave); % transmit waveform out of all DACs
                data = obj.rx(); % single channel ADC data
                dataSum = sum(data(:,1:numChan),2); % combined ADC data
                
            else % tx mode
                obj.txWaveform(cwWave,1); % transmit waveform out of only DAC1
                data = obj.rx(); % capture single channel
                obj.txWaveform(cwWave,numChan); % transmit waveform out of desired number of DACs
                dataSum = obj.rx(); % capture multiple channels combined
            end
            
            [chFFTMetrics, ~] = obj.FFT(data,false,'onetone'); % perform FFT
            singleChMag = chFFTMetrics{1}('A:mag_dbfs'); % extract mag for each channel
            [sumFFTMetrics, ~] = obj.FFT(dataSum,true,'onetone'); % perform FFT for combined data
            sumChMag = sumFFTMetrics{1}('A:mag_dbfs'); % extract mag for each channel
            
            combineGain = sumChMag - singleChMag; % combined channels minus single channel
            passFail = combineGain > (20*log10(numChan)-0.7);
            
        end
        
        function dataAlign = zeroAlignThreshold(obj, dataNoAlign, codeThresh)
            %ZEROALIGNTHRESHOLD aligns a pulse train to ADC code threshold using a circ
            %   shift function. This enables the ability to discern which
            %   DAC corresponds to its respective pulse for calibration
            %
            %   input parameters
            %       dataNoAlign: type = complex double
            %           MxN matrix to align to threshold. 
            %           M is number of samples and N is number of channels
            %       codeThresh: type = double
            %       ADC code value for alignment threshold
            %       
            %   output parameters
            %       dataAlign: type = complex double
            %           MxN matrix time aligned to threshold value
            
            if ~exist('codeThresh','var')
                codeThresh = 400;
            end
            
            dataAlign = zeros(size(dataNoAlign));
            numChan = size(dataNoAlign,2);
            
            for k = 1:numChan
                if (abs(real(dataNoAlign(1,k)))>codeThresh || abs(imag(dataNoAlign(1,k)))>codeThresh || ...
                        abs(real(dataNoAlign(obj.pulseSamples,k)))>codeThresh || abs(imag(dataNoAlign(obj.pulseSamples,k)))>codeThresh) %Check if signal is present at start of capture
                    [separation,~,~,nextCross,~] = pulsesep(double(abs(real(dataNoAlign(:,k)))>codeThresh));
                    [~, maxLoc] = max(separation);
                    channel0Start = ceil(nextCross(maxLoc)); %The Tx0 pulse location
                else %Correct if signal is zero at start of capture
                    [~,initialCross,~,~,~] = pulseperiod(double(abs(real(dataNoAlign(:,k)))>codeThresh));
                    channel0Start = ceil(initialCross(1));
                end
                dataAlign(:,k) = circshift(dataNoAlign(:,k),-channel0Start); %allign the signal received
            end
        end
        
        function [dataAlign, phaseDelta] = zeroAlignXCORR(obj, dataNoAlign, targetData)
            %ZEROALIGNXCORR aligns a pulse train to a reference waveform
            %   using the XCORR function and circshift. circ
            %   This enables the ability to discern which
            %   DAC corresponds to its respective pulse in the narrow band
            %   calibration.
            %   
            %   input parameters
            %       dataNoAlign: type = complex double
            %           MxN matrix to xcorr. M is number of samples and N
            %           is number of channels
            %       targetData: type = complex double
            %       Mx1 column vector to use as reference for xcorr. M is
            %       number of samples
            %
            %   output parameters
            %       dataAlign: type = complex double
            %           MxN matrix time aligned to reference vector
            %       phase delta: type = double
            %           phase delta between reference vector and MxN matrix
            
            if ~exist('targetData','var')
                targetData = dataNoAlign(:,1);
            end
            
            dataAlign = zeros(size(dataNoAlign));
            numChan = size(dataNoAlign,2);

            for h = 1:numChan
                for k = 1:numChan
                    [r0(:,k),lags0(:,k)] = xcorr(targetData,dataNoAlign(:,k),'none');
                    [pk0(k),idx0(k)] = max(((r0(:,k)))); % find max xcorr factor for time align
                    dataAlign(:,k) = circshift(dataNoAlign(:,k),1*lags0(idx0(k),k)); % shift by num samples to align to data
                    phaseDelta(k,h) = wrapTo180(angle(r0(idx0(h),k))*180/pi);
                    %phaseDelta(1,k) = wrapTo180(angle(r0(idx0(k),k))*180/pi);
                end
            end
        end
        
        function status = loadVCUCode(xsctpath, tclpath)
            %LOADVCUCODE loads FPGA and MicroBlaze images to VCU118
            %
            %   input parameters
            %       xsctpath: type = string
            %           file path for the xsct.bat file
            %       tclpath: type = string
            %           file path for the TCL file
            %   output parameters
            %       status: type = double
            %           returns 0 if load is successful
            %           returns -1 if file doesn't exist
            %           returns xsct return value otherwise
            
            % Default argument values
            if nargin < 2
                % Making my life easier
                xsctpath = "C:\Xilinx\Vitis\2020.2\bin\xsct.bat";
                tclpath = "run.tcl";
            end
            
            % Check paths exist
            if ~isfile(xsctpath) || ~isfile(tclpath)
                status = -1;
                return;
            end
            
            % Change MATLAB working directory to location of TCL script
            [filepath, name, ext] = fileparts(tclpath);
            % oldfolder = cd(filepath);
            
            % Run system call to command XSCT to source run.tcl
            % This TCL script loads the FPGA bitstream and boots Linux
            status = system(strcat(xsctpath, " ", name, ext));
            
            % Return MATLAB working directory to original location
            cd(oldfolder);
        end
        
        function calBrdAdjacentLoopback(obj)
            %CALBRDADJACENTLOOPBACK sets the calibration board into
            %   adjacent loopback mode
            %
            %   5045_V2 set to 0
            %   5045_V1 set to 1
            %   CTRL_IND set to 0
            %   CTRL_RX_COMBINED set to 0
            
            % 5045_V2 set to 0
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage1 raw 0']);
            % 5045_V1 set to 1
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage0 raw 1']);
            % CTRL_IND set to 0
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage2 raw 0']);
            % CTRL_RX_COMBINED set to 0
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage3 raw 0']);
        end
        
        function calBrdCombinedLoopback(obj)
            %CALBRDCOMBINEDLOOPBACK sets the calibration board into
            %   combined loopback mode which combines all DAC channels and
            %   splits to all ADC channels
            %
            %   5045_V2 set to 1
            %   5045_V1 set to 1
            %   CTRL_IND set to 1
            %   CTRL_RX_COMBINED set to 0
            
            % 5045_V2 set to 1
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage1 raw 1']);
            % 5045_V1 set to 1
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage0 raw 1']);
            % CTRL_IND set to 1
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage2 raw 1']);
            % CTRL_RX_COMBINED set to 0
            [~,~] = system(['iio_attr -u ip:192.168.2.1 -c one-bit-adc-dac voltage3 raw 0']);
        end
        
        function calBrdExternalSMA(obj)
            %CALBRDEXTERNALSMA sets the calibration board to route the
            %   combined DAC channels mode to out of the external Tx SMA port or
            %   split a received signal to all ADC channels
            %
            %   5045_V2 set to 1
            %   5045_V1 set to 0
            %   CTRL_IND set to 1
            %   CTRL_RX_COMBINED set to 1
            
            % 5045_V2 set to 1
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage1 raw 1']);
            %obj.rx.setDeviceAttributeRAW('voltage1', '1', obj.cal)
            % 5045_V1 set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage0 raw 0']);
            %obj.rx.setDeviceAttributeRAW('voltage0', '0', obj.cal)
            % CTRL_IND set to 1
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage2 raw 1']);
            %obj.rx.setDeviceAttributeRAW('voltage2', '1', obj.cal)
            % CTRL_RX_COMBINED set to 1
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage3 raw 1']);
            %obj.rx.setDeviceAttributeRAW('voltage3', '1', obj.cal)
            
        end
        
        function calBrdPowerDetector(obj)
            %CALBRDPOWERDETECTOR sets the calibration board to take the
            %   combined DAC signal and direct it to the on board power
            %   detector
            %
            %   5045_V2 set to 0
            %   5045_V1 set to 0
            %   CTRL_IND set to 1
            %   CTRL_RX_COMBINED set to 0
            
            % 5045_V2 set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage1 raw 0']);
            % 5045_V1 set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage0 raw 0']);
            % CTRL_IND set to 1
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage2 raw 1']);
            % CTRL_RX_COMBINED set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage3 raw 0']);
            
        end
        
        function calBrdOpen(obj)
            %CALBRDOFF sets the calibration board to take the
            %   combined ADC/DAC signal and direct it to the on board power
            %   detector
            %
            %   5045_V2 set to 0
            %   5045_V1 set to 0
            %   CTRL_IND set to 1
            %   CTRL_RX_COMBINED set to 0
            
            % 5045_V2 set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage1 raw 0']);
            % 5045_V1 set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage0 raw 0']);
            % CTRL_IND set to 1
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage2 raw 0']);
            % CTRL_RX_COMBINED set to 0
            [~,~] = system(['iio_attr -u ',obj.uri, ' -c one-bit-adc-dac voltage3 raw 0']);
            
        end
        
        function waveform = createWaveform(obj, type, amplitude, frequency, barkerEnable)
            %CREATEWAVEFORM creates waveform to be imported and used for TX
            %   for each channel
            %   plots created waveforms for all channels
            %
            %   input parameters
            %       type: type string
            %           'cw', 'pulsed', 'two-tone'
            %       amplitude: type = double
            %           (dBFS) scaled with DAC codes
            %       frequency: type = double
            %           ideally integer multiple of sampling frequency fsRxIQ
            %       barkerEnable: type = boolean
            %           true false
            %   output parameters
            %       waveform: type = complex double
            %           MxN matrix where M is samples, N is channels
            
            % Note: pulsed implementation does not work for basedband
            % frequencies below 25 MHz with sample size of 8192. Need more
            % samples to capture all 16 pulses in a dataframe at the lower
            % baseband frequencies.
            
            if ~exist('type','var')
                type = 'cw'; %defaults to CW waveform if no input variable
            end
            if ~exist('amplitude','var')
                amplitude = 2^15*db2mag(-1); %default amplitude with no input value
            else
                amplitude = 2^15*db2mag(amplitude); %sets amplitude based on input value
            end
            if ~exist('frequency','var')
                frequency = obj.basebandFreq; %if frequency variable does not exist, default to this setting
            end
            if ~exist('barkerEnable','var')
                barkerEnable = false; %barker code implementation
            end
            
            swv1 = dsp.SineWave(amplitude, frequency); %creates sine wave with determined amplitude and frequency for CW
            swv1.ComplexOutput = true; %turns on complex waveform
            swv1.SamplesPerFrame = obj.samplesPerFrameTx; %waveform based on samples for TX
            swv1.SampleRate = obj.fsRxIQ; %sample rate for RX waveform
            y = swv1(); %set waveform
            
            switch lower(type)
                case "cw"
                    waveform = y.*ones(obj.samplesPerFrameTx,obj.numChannels); %create waveform array
                case "two-tone"
                    swv2a = swv1; %creates copy of cw sine wave
                    release(swv2a);
                    swv2a.Frequency = obj.basebandFreq - obj.twoToneSpacing/2; % low side tone frequency set
                    swv2a.Amplitude = amplitude - 2^15*db2mag(-3); % adjust amplitude pre-combing to prevent clipping
                    swv2b = swv1; %creates copy of cw sine wave
                    release(swv2b);
                    swv2b.Frequency = obj.basebandFreq + obj.twoToneSpacing/2; % low side tone frequency set
                    swv2b.Amplitude = amplitude - 2^15*db2mag(-3); % adjust amplitude pre-combing to prevent clipping
                    waveform = (swv2a()+swv2b()).*ones(obj.samplesPerFrameTx,obj.numChannels); %create waveform array
                case "pulsed"
                    tSignal = 1/obj.fsRxIQ:1/obj.fsRxIQ:1/frequency; %time vector array for single pulse
                    obj.subFrame = length(tSignal); %subframe equal to one period of baseband freq pulse
                    
                    waveform = zeros(size(y,1),obj.numChannels); %initialize waveform to zeros
                    
                    %barker encoding
                    hBCodeFirst = comm.BarkerCode('SamplesPerFrame',obj.numPulsePeriods-0);
                    barkCodeFirst = hBCodeFirst(); % barker codes for first pulse, allows time align to first pulse
                    
                    hBCodeOther = comm.BarkerCode('SamplesPerFrame',obj.numPulsePeriods-4);
                    barkCodeOther = hBCodeOther(); % barker codes for all other pulses
                    
                    for k=1:1:obj.numChannels %iterate by channel number
                        waveform(1:obj.subFrame*obj.numPulsePeriods,k) = y(1:obj.subFrame*obj.numPulsePeriods); %load num pulses into channel waveform
                        if barkerEnable == true
                            if k == 1 % implement barker code for first pulse
                                barkerCode = barkCodeFirst;
                            else % implement other barker codes for pulses other than first
                                barkerCode = barkCodeOther;
                            end
                            
                            for bc = 1:length(barkerCode)
                                waveform(1+(bc-1)*obj.subFrame:obj.subFrame*bc,k) = y(1+(bc-1)*obj.subFrame:obj.subFrame*bc)*exp(1j*(pi)*barkerCode(bc)); %phase shift each subframe by barker code, 180 deg phase shift
                            end
                            
                        else
                            %do nothing
                        end
                        waveform(:,k) = circshift(waveform(:,k),(k-1)*(obj.numZeroPulsePeriods + obj.numPulsePeriods)*obj.subFrame); %circshift buffer to time interleave pulses wrt channel number
                    end
                otherwise
                    error('type unsupported. Acceptable options are CW and Pulsed') %returns error if issue with type
            end
            
            obj.dacWaveform = waveform; %sets object waveform to waveform generate
        end
        
        function txWaveform(obj,waveform,chan)
            %TXWAVEFORM transmits loaded waveform out of desired DACs
            %
            %   input parameters
            %       waveform: type=complex double
            %           waveform size must be MxN where M is number of samples
            %           and N is total number of DAC channels
            %       chan: type=double
            %           default = 1:16 vector
            %
            %   DACs must also be in DMA mode
            
            if ~exist('chan','var')
                chan = 1:16; %defaults to all channels if no input variable
            end
            
            chanList = 1:obj.numChannels; % list of channels
            idx = ismember(chanList,chan); % find which indices correspond to desired channels
            modifiedWave = zeros(obj.samplesPerFrameTx,obj.numChannels); % create zero matrix waveform
            modifiedWave(:,idx) = waveform(:,idx); % populate channels which want to transmit waveform
            
            release(obj.tx); %release tx object
            obj.tx(modifiedWave); %transmits waveform via tx class call, DMA Mode
        end
        
        function [data,valid,of] = rxCapture(obj,framesToCollect)
            %RXCAPTURE executes data collection for processing
            %   
            %   input parameters
            %       framesToCollect: type=int
            %           must be greater than or equal to 1
            %
            %   output parameters
            %       data: type = complex double
            %           return is MxN matrix where M corresponds to number 
            %           of samples and N is number of channels
            %       valid: type = 
            %
            %       of: type = 
            %
            %
    
            
            data=zeros(obj.samplesPerFrameRx,obj.numChannels,framesToCollect); %preallocate memory
            
            if ~exist('framesToCollect','var')
                framesToCollect = int8(1); %defaults to all channels if no input variable
            else
                framesToCollect = int8(framesToCollect);
            end
            
            for frame = 1:framesToCollect
                [d,valid,of] = obj.rx();
                %Collect data without overflow and is valid
                if ~valid
                    warning('Data Invalid')
                elseif of
                    warning('Overflow Occurred')
                else
                    data(:,:,frame) = d;
                end
            end
        end
        
        function value = getApolloTemp(obj)
            %GETAPOLLOTEMP reads the TMU readings of each Apollo
            %   data ordered in physical location from left to right
            %
            %   output parameters
            %       value: type = double
            %           return is 1x4 vector
            
            value = [obj.rx.TempA obj.rx.TempB obj.rx.TempC obj.rx.TempD];
        end
        
        
        function totalAdj = setADF4382Phase(obj, artemisName, phaseDeg)
            [~,reg32] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x032']); %Getting existing value for Reg 0x032
            reg32 = str2num(reg32); %Converting reg readout to number so it can be manipulated
            reg32 = bitand(reg32, 0b11101111);  %Turning off EN_AUTO_ALIGN Bit
            reg32 = bitor(reg32, 0b00100000);   %Turning on DEL_MODE bit
            system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x032 0x' dec2hex(reg32)]);   %Writing updated value back
            
            [~,reg15] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x015']); %Getting existing value for Reg 0x015
            reg15 = str2num(reg15); %Converting reg readout to number so it can be manipulated
            reg15 = bitand(reg15, 0b11111011);  %Turning off INT_MODE
            system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x015 0x' dec2hex(reg15)]);   %Writing updated value back
            
            %             phaseWord = round((phaseDeg/360)*(2^(12)));
            phaseWord = round((phaseDeg/360)*(2^(8)));
            
            system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x033 0x' dec2hex(phaseWord)]);   %Writing updated value back
            
            [~,reg34] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x034']); %Getting existing value for Reg 0x034
            reg34 = str2num(reg34); %Converting reg readout to number so it can be manipulated
            reg34 = bitor(reg34, 0b10000000);  %Setting phase adjust bit
            system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x034 0x' dec2hex(reg34)]);   %Writing updated value back
            
            [~,reg61] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x061']); %Getting CUM_ADJ[7:0] value
            reg61 = str2double(reg61);
            [~,reg62] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x062']); %Getting CUM_ADJ[15:8] value
            reg62 = str2double(reg62);
            reg62 = bitshift(reg62, 8);
            [~,reg63] = system(['iio_reg -u ' obj.uri ' ' artemisName ' 0x063']); %Getting CUM_ADJ[16] value
            reg63 = str2double(reg63);
            reg63 = bitshift(reg63, 16);
            
            totalAdj = bitor(bitor(reg61, reg62),reg63);
        end

        function setArtemisPhasenew(obj, ArtemisName, phasevalue)
            f_PFD = 400e6; %phase frequency detector frequency (REFCLK)
            RFOUT = 12.8e9; %Artemis output frequency
            [~,reg1F] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x01F']); %read register 1F 
            reg1F = str2num(reg1F); %convert to number
            %CP_I = bitand(reg1F, 15);
            CP_I = 11.1e-3; %default charge pump bit value is 15, which corresponds to 11.1e-3 A
            PHASE_ADJUSTMENT = ((phasevalue*511)/250e-6)*CP_I*(f_PFD/(360*RFOUT)); %calculating actual phase adjustment
            modreg1F = dec2hex(bitor(reg1F, bitshift(1,4))); %change bit 4 of register 1F to 1 
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x01F 0x' modreg1F]); %write the change to the register 

            [~, reg1E] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x01E']); %read register 1E
            reg1E = str2num(reg1E); %convert to number 
            modreg1E = dec2hex(bitor(reg1E, bitshift(1,7))); %change bit 7 of register 1E to 1 
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x01E 0x' modreg1E]); %write the change to the register 

            [~, reg32] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x032']); %read register 32 
            reg32 = str2num(reg32); %conert to number
            reg32 = uint8(reg32); %convert to an unsigned 8 bit integer 
            mask = uint8(~(bitshift(1, 4) | bitshift(1, 5))); %create a mask for changing bits 4 and 5 to 0
            %mask = uint8(~bitshift(1,5));
            modreg32 = bitand(reg32, mask); %use mask to change bits 4 and 5 to 0
            %modreg32 = dec2hex(bitor(reg32, bitshift(1,4)));
            modreg32 = dec2hex(modreg32); %get hex value of modified register value
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x032 0x' modreg32]); %write the change to the register 

            PHASE_ADJUSTMENT = dec2hex(round(PHASE_ADJUSTMENT)); %get hex value of actual phase adjustment 
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x033 0x' PHASE_ADJUSTMENT]); %write the phase adjustment to register 33

            [~, reg34] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x034']); %read register 34 
            reg34 = str2num(reg34); %convert to number
            modreg34 = dec2hex(bitor(reg34, bitshift(1,7))); %change bit 7 of register 34 to 1 
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x034 0x' modreg34]); %write the change to the register 

            [~, reg64] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x064']);
            [~, reg65] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x065']);
            %reg64 = str2num(reg64)
        end

        function ArtemisGoToMin(obj, ArtemisName, minIndex)
            stepsback = 360-minIndex;
            [~, reg32] = system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x032']); %read register 32 
            reg32 = str2num(reg32);
            reg32 = uint8(reg32);
            mask = uint8(~bitshift(1,3));
            modreg32 = bitand(reg32, mask);
            modreg32 = dec2hex(modreg32);
            system(['iio_reg -u ip:192.168.2.1 ' ArtemisName ' 0x032 0x' modreg32]);
            for q = 1:stepsback
                obj.setArtemisPhasenew(ArtemisName, 0.507748453);
            end
        end

        function GenerateChirp(obj)
            fs_RxIQ = 400e6;
            %fs_RxIQ = str2double(obj.tx.getAttributeRAW('voltage0_i','sampling_frequency',0,obj.tx.iioDev0));
            samplesperframe = (1/6.25e6*fs_RxIQ);
            amplitude = 3 * obj.samplesPerFrameTx;
            phaseRadians = 0*pi/180; 
            T = 1/fs_RxIQ;
            chirpBW = fs_RxIQ*1.0;
            basebandFreqChirp = 6.25e6;
            NumPoints = samplesperframe;;
            ActualToneOffset = round(NumPoints.*(basebandFreqChirp./fs_RxIQ)).*(fs_RxIQ./NumPoints);
            endTime = T*NumPoints-T;
            tau = T*samplesperframe; 
            t = -endTime/2:T:endTime/2;
            y1 = amplitude.*exp(1j*(2*pi*(ActualToneOffset + chirpBW/(2*tau).*t).*t + phaseRadians));
            newy1 = repmat(y1,1,128);
            obj.txWaveform(ones(obj.samplesPerFrameTx,size(obj.tx.EnabledChannels,2)).*newy1');
            
        end

% function design_and_program_Apollo_CFIR_Batch(obj, freqSweepAdcData, deviceName, ipAddress, N)
% % Design and program Apollo CFIRs for all channels and sweeps using full cfir_config block write (Network backend)
% 
% fprintf('Starting CFIR design for all channels and sweeps...\n');
% 
% n = 0:N-1;
% Fs = 12.8e9;
% numChannels = size(freqSweepAdcData, 2);
% numSweepPoints = size(freqSweepAdcData, 3);
% Nfft = size(freqSweepAdcData, 1);
% freqAxis = linspace(-pi, pi, Nfft);
% h_all = zeros(N, numChannels, numSweepPoints);
% 
% for t = 1:numSweepPoints
%     for ch = 1:numChannels
%         adcSamples = freqSweepAdcData(:, ch, t);
%         fftResult = fftshift(fft(adcSamples));
% 
%         numDesiredPoints = 10;
%         selectedBins = round(linspace(1, Nfft, numDesiredPoints));
%         wk = freqAxis(selectedBins);
%         Hk = fftResult(selectedBins);
% 
%         bPlot = (t == 1 && ch == 1);  % Only plot first channel/sweep
%         h = obj.least_squares_complex_fir_sampled_apollo(Hk, wk, n, 1e-8, bPlot);
% 
%         h_all(:, ch, t) = h;
%     end
% end
% 
% fprintf('CFIR design complete for all channels and sweeps.\n');
% 
% %% Step 2: Program All CFIRs using full cfir_config block write
% fprintf('Starting CFIR programming via network backend (%s)...\n', ipAddress);
% 
% scaleFactor = 2^15 - 1;
% 
% for t = 1:numSweepPoints
%     for ch = 1:numChannels
%         h_target = h_all(:, ch, t);
% 
%         % Quantize
%         coeffs_i = round(real(h_target) * scaleFactor);
%         coeffs_q = round(imag(h_target) * scaleFactor);
%         coeffs_i = max(min(coeffs_i, 32767), -32768);
%         coeffs_q = max(min(coeffs_q, 32767), -32768);
% 
%         % Build coefficient lines
%         coeffLines = strings(N,1);
%         for idx = 1:N
%             coeffLines(idx) = sprintf('%d %d', coeffs_i(idx), coeffs_q(idx));
%         end
% 
%         % Build CFIR config block header
%         headerLines = [
%             "dest: 0 0 0 0"
%             "gain: 0"
%             "complex_scalar: 1 0"
%             "bypass: 0"
%             "sparse_filt_en: 0"
%             sprintf('32taps_en: %d', (N == 32))
%             "coeff_transfer: 1"
%             "enable: 1 0"
%             "selection_mode: 0"
%         ];
% 
%         % Combine full config
%         cfirConfigFull = strjoin([headerLines; coeffLines], newline);
% 
%   
% % Save to temporary text file
% tempFile = tempname + ".txt";
% fid = fopen(tempFile, 'w');
% fprintf(fid, '%s\n', cfirConfigFull);
% fclose(fid);
% 
% % Use input redirection "<" instead of -F
% cmd = sprintf('iio_attr -u "ip:%s" -d %s cfir_config < "%s"', ipAddress, deviceName, tempFile);
% fprintf('Programming Channel %d, Sweep %d...\n', ch, t);
% status = system(cmd);
% if status ~= 0
%     warning('CFIR config programming failed for Ch %d, Sweep %d.', ch, t);
% end
% 
% delete(tempFile);
% 
% 
%         pause(0.05);  % Optional pause between channels
%     end
% end
% 
% fprintf('All CFIR programming complete.\n');
% 
% end


function design_and_program_Apollo_CFIR_Batch(obj, freqSweepAdcData, deviceName, ipAddress, N, sweepIndices)
% Design and program Apollo CFIRs for selected sweeps using SCP + SSH
%
% Inputs:
%   freqSweepAdcData - ADC data (samples x channels x sweeps)
%   deviceName       - IIO device name (e.g., 'iio:device34')
%   ipAddress        - Apollo board IP (e.g., '192.168.2.1')
%   N                - Number of CFIR taps (e.g., 16 or 32)
%   sweepIndices     - Vector of sweep indices to program (e.g., [10 20 30])
%

fprintf('Starting CFIR design for selected sweeps: %s\n', mat2str(sweepIndices));

n = 0:N-1;
numChannels = size(freqSweepAdcData, 2);
Nfft = size(freqSweepAdcData, 1);
freqAxis = linspace(-pi, pi, Nfft);

scaleFactor = 2^15 - 1;

for tIdx = 1:numel(sweepIndices)
    t = sweepIndices(tIdx);  % Actual sweep index (frequency index)

    fprintf('Processing Sweep %d...\n', t);

    % Step 1: Find lowest-magnitude channel for this sweep
    totalMagnitudes = zeros(1, numChannels);
    for chTemp = 1:numChannels
        fftChTemp = fftshift(fft(freqSweepAdcData(:, chTemp, t)));
        totalMagnitudes(chTemp) = sum(abs(fftChTemp));
    end
    [~, refCh] = min(totalMagnitudes);
    fprintf('Sweep %d: Using Channel %d as reference.\n', t, refCh);

    % Step 2: Reference FFT
    refSamples = freqSweepAdcData(:, refCh, t);
    fftRef = fftshift(fft(refSamples));
    numDesiredPoints = 64;
    selectedBins = round(linspace(1, Nfft, numDesiredPoints));
    wk = freqAxis(selectedBins);
    H_ref = fftRef(selectedBins);

    % Step 3: Design and program CFIR for each channel
    for ch = 1:numChannels
        adcSamples = freqSweepAdcData(:, ch, t);
        fftResult = fftshift(fft(adcSamples));
        Hk = fftResult(selectedBins);

        % Relative error
        H_error = H_ref ./ Hk;

        % Least squares FIR design
        bPlot = (tIdx == 1 && ch == 1);  % Optional: only plot first
        h = obj.least_squares_complex_fir_sampled_apollo(H_error, wk, n, 1e-8, bPlot);

        % Quantize to int16
        coeffs_i = round(real(h) * scaleFactor);
        coeffs_q = round(imag(h) * scaleFactor);
        coeffs_i = max(min(coeffs_i, 32767), -32768);
        coeffs_q = max(min(coeffs_q, 32767), -32768);

        % Build CFIR config file content
        coeffLines = strings(N,1);
        for idx = 1:N
            coeffLines(idx) = sprintf('%d %d', coeffs_i(idx), coeffs_q(idx));
        end

        headerLines = [
            "dest: rx cfir_all profile_1 datapath_all"
            "gain: 0"
            "complex_scalar: 32767 0"
            "enable: 1 profile_2"
            "selection_mode: direct_regmap"
            "coeff_transfer: 0"
            "bypass: 0"
        ];

        cfirConfigFull = strjoin([headerLines; coeffLines], newline);

        % Save to local temp file
        tempFile = tempname + ".txt";
        fid = fopen(tempFile, 'w');
        fprintf(fid, '%s\n', cfirConfigFull);
        fclose(fid);

        % SCP to Apollo temp path
        remoteTempFile = '/root/cfir_config_temp.txt';
        scpCmd = sprintf('scp "%s" root@%s:%s', tempFile, ipAddress, remoteTempFile);
        [status_scp, scp_output] = system(scpCmd);
        if status_scp ~= 0
            warning('SCP failed for Ch %d, Sweep %d.\nOutput: %s', ch, t, scp_output);
            delete(tempFile);
            continue;
        end

        % SSH: Program CFIR
        sysfsPath = sprintf('/sys/bus/iio/devices/%s/cfir_config', deviceName);
        sshCmd = sprintf('ssh root@%s "cat %s > %s"', ipAddress, remoteTempFile, sysfsPath);
        [status_ssh, ssh_output] = system(sshCmd);
        if status_ssh ~= 0
            warning('SSH CFIR programming failed for Ch %d, Sweep %d.\nOutput: %s', ch, t, ssh_output);
        end

        % SSH: Clean up temp file on Apollo
        cleanupCmd = sprintf('ssh root@%s "rm %s"', ipAddress, remoteTempFile);
        system(cleanupCmd);

        % Delete local temp file
        delete(tempFile);

        fprintf('CFIR programmed for Channel %d, Sweep %d.\n', ch, t);
        pause(0.05);
    end
end

fprintf('CFIR programming complete for selected sweeps: %s\n', mat2str(sweepIndices));

end



function h = least_squares_complex_fir_sampled_apollo(obj, Hk, wk, n, lambda, bPlot)
    if nargin < 5 || isempty(lambda)
        lambda = 1e-8;
    end
    if nargin < 6 || isempty(bPlot)
        bPlot = false;
    end

    K = length(Hk);
    N = length(n);
    Hk = Hk(:);
    wk = wk(:);
    n = n(:)';
    m = n';

    % Solve least squares
    LHS = zeros(N,1);
    RHS = zeros(N,N);
    for i = 1:K
        LHS = LHS + (1/K) * Hk(i) * exp(1j * wk(i) * m);
        RHS = RHS + (1/K) * exp(1j * wk(i) * (m - n));
    end
    h = (RHS + lambda * eye(N)) \ LHS;

    % Optional: Plot response vs target
    if bPlot
        figure;
        freqGrid = linspace(-pi, pi, 512);
        H_est = freqz(h, 1, freqGrid);
        plot(freqGrid, 20*log10(abs(H_est)));
        title('CFIR Frequency Response (dB)');
        xlabel('Frequency [rad/sample]');
        ylabel('Magnitude [dB]');
        grid on;
    end
end

function onlyRxCal(obj)
    % Step 1: Data capture
    testcap = obj.rx();  % [samples x 16 channels]

    % Step 2: Compute phase at sample 100
    sampleIQ = testcap(100, :);
    phase_deg = rad2deg(angle(sampleIQ));

    % Step 3: Phase error vs CH1
    refPhase = phase_deg(1);
    phase_error = phase_deg - refPhase;

    % Step 4: Wrap and convert to millidegrees
    rxNcoPhaseAdjustDeg = wrapTo180(phase_error) * 1e3;  % [1×16] in mdeg

    obj.setRxNCOPhase('Main', rxNcoPhaseAdjustDeg);

    % Step 6: Output
    fprintf('Applied RX NCO phase corrections (deg):\n');
    disp(rxNcoPhaseAdjustDeg / 1e3);  % Display in degrees
end


    end
end


