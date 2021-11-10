classdef Tx < adi.sim.AD9081.Base & matlab.system.mixin.SampleTime & matlab.system.mixin.Propagates
    %TX Transmitter path of AD9081 MxFE
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>
    
    properties(Nontunable)
        % Short window PA protection, each PDP can be configured seperately
        SHORT_PA_ENABLE(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_ENABLE,0),...
            mustBeLessThanOrEqual(SHORT_PA_ENABLE,1)} = [0, 0, 0, 0];
        SHORT_PA_AVG_TIME(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_AVG_TIME,0),...
            mustBeLessThanOrEqual(SHORT_PA_AVG_TIME,3)} = [0, 0, 0, 0];
%        SHORT_PA_POWER(1,4) {mustBeInteger,...
%            mustBeGreaterThanOrEqual(SHORT_PA_POWER,0),...
%            mustBeLessThan(SHORT_PA_POWER,8192)} = [0, 0, 0, 0];
        SHORT_PA_THRESHOLD(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(SHORT_PA_THRESHOLD,0),...
            mustBeLessThan(SHORT_PA_THRESHOLD,8192)} = [0, 0, 0, 0];
        % Long window PA protection
        LONG_PA_ENABLE(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_ENABLE,0),...
            mustBeLessThanOrEqual(LONG_PA_ENABLE,1)} = [0, 0, 0, 0];
        LONG_PA_AVG_TIME(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_AVG_TIME,0),...
            mustBeLessThanOrEqual(LONG_PA_AVG_TIME,15)} = [0, 0, 0, 0];
%        LONG_PA_POWER(1,4) {mustBeInteger,...
%            mustBeGreaterThanOrEqual(LONG_PA_POWER,0),...
%            mustBeLessThan(LONG_PA_POWER,8192)} = [0, 0, 0, 0];
        LONG_PA_THRESHOLD(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(LONG_PA_THRESHOLD,0),...
            mustBeLessThan(LONG_PA_THRESHOLD,8192)} = [0, 0, 0, 0];
        % Ramp rate
        BE_GAIN_RAMP_RATE(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(BE_GAIN_RAMP_RATE,0),...
            mustBeLessThan(BE_GAIN_RAMP_RATE,8)} = [0, 0, 0, 0];
        PA_OFF_TIME(1,4) {mustBeInteger,...
            mustBeGreaterThanOrEqual(PA_OFF_TIME,0),...
            mustBeLessThan(PA_OFF_TIME,1024)} = [0, 0, 0, 0];    %This variable is uncertain
        
        % CDUCNCOFrequencies CDUC NCO Frequencies
        %   1x4 Array of frequencies of NCOs in main data path
        CDUCNCOFrequencies = [1e6,1e6,1e6,1e6];
        % CDUCNCOEnable CDUC NCO Enable
        %   1x4 Array of booleans to enable NCOs in main data path
        CDUCNCOEnable = [false, false, false, false];
        % CDUCNGainAdjustDB CDUC Gain Adjust DB
        %   1x4 Array of doubles for each adjustable input gain. Values are
        %   in dB
        CDUCNGainAdjustDB = [0,0,0,0];
        % FDUCNCOFrequencies FDUC NCO Frequencies
        %   1x8 Array of frequencies of NCOs in channelizer path
        FDUCNCOFrequencies = [1e6,1e6,1e6,1e6,1e6,1e6,1e6,1e6];
        % FDUCNCOEnable FDUC NCO Enable
        %   1x8 Array of booleans to enable NCOs in channelizer path
        FDUCNCOEnable = [false, false, false, false, false, false, false, false];
        % FDUCNGainAdjustDB CDUC Gain Adjust DB
        %   1x8 Array of doubles for each adjustable input gain. Values are
        %   in dB
        FDUCNGainAdjustDB = [0,0,0,0,0,0,0,0];
        % MainDataPathInterpolation Main Data Path Interpolation
        %   Specify the decimation in the main data path which can be
        %   [1,2,3,4,6]
        MainDataPathInterpolation = 1;
        % ChannelizerPathInterpolation Channelizer Path Interpolation
        %   Specify the decimation in the channelizer path which can be
        %   [1,2,3,4,6,8,12,16,24]
        ChannelizerPathInterpolation = 1;
        % Crossbar8x8Mux Crossbar 8x8 Mux
        %   Logical 4x8 array of for MainDataPath input summers. Each row
        %   corresponds to each summmer [1-4] and each column corresponds
        %   to an input Channelizer path 1-8]. Set indexes to true to
        %   enable a given path to be added into summer's output.
        Crossbar8x8Mux = [1,0,0,0,0,0,0,0;0,1,0,0,0,0,0,0;0,0,1,0,0,0,0,0;0,0,0,1,0,0,0,0];
        % ModeSelectMux Mode Select Mux
        %   Scalar value than can be [0-3] with the following results:
        %   Mode 0: DAC0 = Real(CDUC0 NCO Out)
        %           DAC1 = Real(CDUC1 NCO Out)
        %           DAC2 = Real(CDUC2 NCO Out)
        %           DAC3 = Real(CDUC3 NCO Out)
        %   Mode 1: DAC0 = (Real(CDUC0) + Real(CDUC1))/2
        %           DAC1 = (Imag(CDUC0) + Imag(CDUC1))/2
        %           DAC2 = (Real(CDUC2) + Real(CDUC3))/2
        %           DAC3 = (Imag(CDUC3) + Imag(CDUC3))/2
        %   Mode 2: DAC0 = Real(CDUC0)
        %           DAC1 = Imag(CDUC0)
        %           DAC2 = Real(CDUC2)
        %           DAC3 = Imag(CDUC3)
        %   Mode 3: DAC0 = (Real(CDUC0 NCO Out) + Real(CDUC1 NCO Out))/2
        %           DAC1 = zeros
        %           DAC2 = (Real(CDUC2 NCO Out) + Real(CDUC3 NCO Out))/2
        %           DAC3 = zeros
        %   Modes are dependent on interpolation settings since certain
        %   modes require use of NCOs
        ModeSelectMux = 1;
    end
    
    properties
        % SampleRate Sample Rate of DACs
        %   Scalar in Hz
        SampleRate = 12e9;
    end
    
    properties(Hidden, Constant)
       DataPathWidth = 16; % Bits 
    end
    
    methods
        %% Constructor
        function obj = Tx(varargin)
            obj = obj@adi.sim.AD9081.Base(varargin{:});
            obj.setPDPConfigs()
        end
        function delete(obj)
            delete@adi.sim.AD9081.Base(obj);
        end
        
        % Check CDUCNCOFrequencies
        function set.CDUCNCOFrequencies(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '>=', -obj.SampleRate/2,'<=', obj.SampleRate/2}, ...
                '', 'CDUCNCOFrequencies');
            obj.CDUCNCOFrequencies = value;
            obj.setNCOFrequencies();
            assert(isequal(size(value),[1,4]),'CDUCNCOFrequencies must be a 1x4 vector');
        end
        % Check FDUCNCOFrequencies
        function set.FDUCNCOFrequencies(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '>=',...
                -obj.SampleRate/obj.MainDataPathInterpolation/2,'<=',...
                obj.SampleRate/obj.MainDataPathInterpolation/2}, ...
                '', 'FDUCNCOFrequencies');
            assert(isequal(size(value),[1,8]),'FDUCNCOFrequencies must be a 1x8 vector');
            obj.FDUCNCOFrequencies = value;
            obj.setNCOFrequencies();
        end
        % Check CDUCNGainAdjustDB
        function set.CDUCNGainAdjustDB(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '<=', 6.018}, ...
                '', 'CDUCNGainAdjustDB');
            obj.CDUCNGainAdjustDB = value;
            obj.setGains();
        end
        % Check CDUCNGainAdjustDB
        function set.FDUCNGainAdjustDB(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '<=', 6.018}, ...
                '', 'FDUCNGainAdjustDB');
            obj.FDUCNGainAdjustDB = value;
            obj.setGains();
        end
        % Check MainDataPathInterpolation
        function set.MainDataPathInterpolation(obj, value)
            obj.MainDataPathInterpolation = value;
            obj.setInterpolations();
            obj.setRates();
        end
        % Check ChannelizerPathInterpolation
        function set.ChannelizerPathInterpolation(obj, value)
            obj.ChannelizerPathInterpolation = value;
            obj.setInterpolations();
            obj.setRates();
        end
        % Check CDUCNCOEnable
        function set.CDUCNCOEnable(obj, value)
            obj.CDUCNCOEnable = value;
            obj.setNCOEnable();
        end
        % Check FDUCNCOEnable
        function set.FDUCNCOEnable(obj, value)
            obj.FDUCNCOEnable = value;
            obj.setNCOEnable();
        end
        % Check SampleRate
        function set.SampleRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 1.5e9,'<=', 12e9}, ...
                '', 'SampleRate');
            obj.SampleRate = value;
            obj.setRates();
        end
        
        % Check Crossbar8x8Mux
        function set.Crossbar8x8Mux(obj, value)
            % Cannot support certain configs
            assert(isequal(size(value),[4,8]),'Crossbar8x8Mux must be a [4x8] matrix');
            obj.Crossbar8x8Mux = value;
            obj.setRates();
        end
        % Check ModeSelectMux
        function set.ModeSelectMux(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '>=', 0,'<=', 3}, ...
                '', 'ModeSelectMux');
            
            switch value
                case 0
                    assert(obj.MainDataPathInterpolation>1,'For ModeSelectMux mode 0 MainDataPathInterpolation must be > 1'); %#ok<*MCSUP>
                case 1
                    %N/A
                case 2
                    %N/A
                otherwise
                    assert(obj.MainDataPathInterpolation>1,'For ModeSelectMux mode 3 MainDataPathInterpolation must be > 1'); %#ok<*MCSUP>
            end
            
            obj.ModeSelectMux = value;
            obj.setRates();
        end
    end
    
    methods(Access = protected)
        function setPDPConfigs(obj)
            for k=1:4
                obj.(['PDP',num2str(k)]).SHORT_PA_ENABLE = obj.SHORT_PA_ENABLE(k);
                obj.(['PDP',num2str(k)]).SHORT_PA_AVG_TIME = obj.SHORT_PA_AVG_TIME(k);
                obj.(['PDP',num2str(k)]).SHORT_PA_THRESHOLD = obj.SHORT_PA_THRESHOLD(k);
                obj.(['PDP',num2str(k)]).LONG_PA_ENABLE = obj.LONG_PA_ENABLE(k);
                obj.(['PDP',num2str(k)]).LONG_PA_AVG_TIME = obj.SHORT_PA_AVG_TIME(k);
                obj.(['PDP',num2str(k)]).LONG_PA_THRESHOLD = obj.SHORT_PA_THRESHOLD(k);
                obj.(['PDP',num2str(k)]).BE_GAIN_RAMP_RATE = obj.BE_GAIN_RAMP_RATE(k);
                obj.(['PDP',num2str(k)]).PA_OFF_TIME = obj.PA_OFF_TIME(k);
                obj.(['PDP',num2str(k)]).InterpX = obj.MainDataPathInterpolation;
            end
        end
        
        function setGains(obj)
            for k=1:4
                obj.(['CDUC',num2str(k)]).GainAdjustDB = obj.CDUCNGainAdjustDB(k);
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).GainAdjustDB = obj.FDUCNGainAdjustDB(k);
            end
        end
        
        function setNCOFrequencies(obj)
            for k=1:4
                obj.(['CDUC',num2str(k)]).NCODesiredFrequency = obj.CDUCNCOFrequencies(k);
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).NCODesiredFrequency = obj.FDUCNCOFrequencies(k);
            end
        end
        
        function setInterpolations(obj)
            for k=1:4
                obj.(['CDUC',num2str(k)]).Interpolation = obj.MainDataPathInterpolation;
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).Interpolation = obj.ChannelizerPathInterpolation;
            end
        end
        
        function setNCOEnable(obj)
            for k=1:4
                obj.(['CDUC',num2str(k)]).NCOEnable = obj.CDUCNCOEnable(k);
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).NCOEnable = obj.FDUCNCOEnable(k);
            end
        end
        
        function setRates(obj)
            % Output rates (Only useful for NCOs which are used after filters)
            for k=1:4
                obj.(['DAC',num2str(k-1)]).SampleRate = obj.SampleRate;
            end
            for k=1:4
                obj.(['CDUC',num2str(k)]).SampleRate = obj.SampleRate;
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).SampleRate = ...
                    obj.SampleRate/obj.MainDataPathInterpolation;
            end
        end
        
        function setNCOConfigs(obj,data)

            minSFDR = 102; % >= Spurious free dynamic range in dBc
            phOffset = 0;
            % Calculate number of quantized accumulator bits
            % required from the SFDR requirement
            Nqacc = ceil((minSFDR-12)/6);

            for k=1:4
                obj.(['CDUC',num2str(k)]).NCO.SamplesPerFrame = length(data);
                obj.(['CDUC',num2str(k)]).NCO.PhaseOffset = phOffset;
                obj.(['CDUC',num2str(k)]).NCO.NumDitherBits = 4; %% FIXME
                obj.(['CDUC',num2str(k)]).NCO.NumQuantizerAccumulatorBits = Nqacc;
                obj.(['CDUC',num2str(k)]).NCO.Waveform = 'Complex exponential';
                obj.(['CDUC',num2str(k)]).NCO.CustomAccumulatorDataType =  numerictype([],obj.(['CDUC',num2str(k)]).NCOFTWWidth);
                obj.(['CDUC',num2str(k)]).NCO.PhaseIncrementSource = 'Property';
                obj.(['CDUC',num2str(k)]).NCO.PhaseIncrement = int64(getDDSCounterModulus(obj.(['CDUC',num2str(k)]))); %% FIXME
                obj.(['CDUC',num2str(k)]).NCO.CustomOutputDataType =  numerictype([],17,16); %% FIXME
            end
        end
        
        function setupImpl(obj)
            % Set up all paths
            obj.setPDPConfigs()
            obj.setNCOFrequencies();
            obj.setInterpolations();
            obj.setRates();
        end

        function releaseImpl(obj)
            % Release resources, such as file handles
            for k=1:4
                obj.(['CDUC',num2str(k)]).release();
            end
            for k=1:8
                obj.(['FDUC',num2str(k)]).release();
            end
            for k=1:4
                obj.(['ADC',num2str(k-1)]).release();
            end
        end
        
        function [...
                DACOUT1,...
                DACOUT2,...
                DACOUT3,...
                DACOUT4...
                ] = stepImpl(obj,u0,u1,u2,u3,u4,u5,u6,u7)
            
            u = fi([u0,u1,u2,u3,u4,u5,u6,u7],1,obj.DataPathWidth,0);
            
            % FDUC stage
            l = size(u,1).*obj.ChannelizerPathInterpolation;
            channelizerPathOut = fi(complex(zeros(l,8)),1,obj.DataPathWidth,0);
            for k = 1:8
                channelizerPathOut(:,k) = obj.(['FDUC',num2str(k)])(u(:,k));
            end
            clear u;
            
            % Apply summer based on Crossbar8x8Mux mapping
            summerOut = complex(zeros(size(channelizerPathOut,1),4));
            for summerInIndx = 1:8
                for summerOutIndx = 1:4
                    if obj.Crossbar8x8Mux(summerOutIndx,summerInIndx)
                        summerOut(:,summerOutIndx) = ...
                            summerOut(:,summerOutIndx) + ...
                            double(channelizerPathOut(:,summerInIndx));
                    end
                end
            end
            summerOut = fi(summerOut,1,obj.DataPathWidth,0);
            clear channelizerPathOut;
            
            % CDUC stage
            l = size(summerOut,1).*obj.MainDataPathInterpolation;
            mainDataPathOut = fi(complex(zeros(l,4)),1,obj.DataPathWidth,0);
            for k = 1:4
                mainDataPathOut(:,k) = obj.(['CDUC',num2str(k)])(summerOut(:,k)).*obj.(['PDP',num2str(k)])(summerOut(:,k));
            end           
                        
            switch obj.ModeSelectMux
                case 0
                    r = real(mainDataPathOut(:,1));
                    DACOUT1 = obj.DAC0(r);
                    r = real(mainDataPathOut(:,2));
                    DACOUT2 = obj.DAC1(r);
                    r = real(mainDataPathOut(:,3));
                    DACOUT3 = obj.DAC2(r);
                    r = real(mainDataPathOut(:,4));
                    DACOUT4 = obj.DAC3(r);
                case 1
                    r = 1/2*( real(mainDataPathOut(:,1)) + real(mainDataPathOut(:,2)) );
                    i = 1/2*( imag(mainDataPathOut(:,1)) + imag(mainDataPathOut(:,2)) );
                    DACOUT1 = obj.DAC0(r);
                    DACOUT2 = obj.DAC1(i);
                    r = 1/2*( real(mainDataPathOut(:,3)) + real(mainDataPathOut(:,4)) );
                    i = 1/2*( imag(mainDataPathOut(:,3)) + imag(mainDataPathOut(:,4)) );
                    DACOUT3 = obj.DAC2(r);
                    DACOUT4 = obj.DAC3(i);
                case 2
                    r = real(mainDataPathOut(:,1));
                    i = imag(mainDataPathOut(:,1));
                    DACOUT1 = obj.DAC0(r);
                    DACOUT2 = obj.DAC1(i);
                    r = real(mainDataPathOut(:,3));
                    i = imag(mainDataPathOut(:,3));
                    DACOUT3 = obj.DAC2(r);
                    DACOUT4 = obj.DAC3(i);
                otherwise
                    r = real(1/2*( mainDataPathOut(:,1) + mainDataPathOut(:,2) ));
                    z = fi(zeros(size(r),1,16,0));
                    DACOUT1 = obj.DAC0(r);
                    DACOUT2 = obj.DAC1(z);
                    r = real(1/2*( mainDataPathOut(:,3) + mainDataPathOut(:,4) ));
                    DACOUT3 = obj.DAC2(r);
                    DACOUT4 = obj.DAC3(z);
            end
            
        end
        
%         function resetImpl(obj)
%             % Initialize / reset discrete-state properties
%         end
        
        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj
            
            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);
            
            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s
            
            % Set private and protected properties
            % obj.myproperty = s.myproperty;
            
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
        
        %% Simulink functions       
        function flag = isInputSizeMutableImpl(~,~)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function varargout = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            varargout = cell(8,1);
            for k=1:8
                varargout{k} = true;
            end
        end

        function sts = getSampleTimeImpl(obj)
            % Example: specify discrete sample time
            sts = obj.createSampleTime("Type", "Discrete", ...
                "SampleTime", (obj.MainDataPathInterpolation*obj.ChannelizerPathInterpolation)/obj.SampleRate);
        end

        function dc = getInputDimensionConstraintImpl(obj,~)
            % Define input dimension constraint
            dc = inputDimensionConstraint(obj, "MinimumSize", ...
                (obj.MainDataPathInterpolation*obj.ChannelizerPathInterpolation), "Concatenable", true);
        end
        
        function icon = getIconImpl(~)
            % Define icon for System block
            icon = ["AD9081","Tx"];
        end
        
        function varargout = getInputNamesImpl(obj)
            % Return input port names for System block
            numInputs = getNumInputs(obj);
            varargout = cell(1,numInputs);
            for k = 1:numInputs
                varargout{k} = ['DAC',num2str(k-1)];
            end
        end
        
        function varargout = getOutputNamesImpl(obj)
            % Return output port names for System block
            numOutputs = getNumOutputs(obj);
            varargout = cell(1,numOutputs);
            for k = 1:numOutputs
                varargout{k} = ['DataRouterMuxOut',num2str(k-1)];
            end
        end

        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = cell(8,1);
            d = obj.MainDataPathInterpolation*obj.ChannelizerPathInterpolation;
            val = propagatedInputSize(obj,1);
            assert(mod(val(1),d)==0, 'All input lengths must be a multiple of the combined decimation factor');
            val(1) = val(1)/d;
            for k=1:8
                varargout{k} = val;
            end
        end

        function varargout = getOutputDataTypeImpl(~)
            % Return data type for each output port
            varargout = cell(8,1);
            for k=1:8
                varargout{k} = "double";
            end
        end

        function varargout = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            varargout = cell(8,1);
            for k=1:8
                varargout{k} = true;
            end
        end
    end
    
    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end
        
        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end
    end
    
end

