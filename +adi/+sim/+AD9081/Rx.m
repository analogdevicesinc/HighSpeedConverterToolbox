classdef Rx < adi.sim.AD9081.Base & matlab.system.mixin.SampleTime & matlab.system.mixin.Propagates
    %RX Receiver path of AD9081 MxFE
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9081.pdf">AD9081 Datasheet</a>
    
    properties(Nontunable)
        % CDDCNCOFrequencies CDDC NCO Frequencies
        %   1x4 Array of frequencies of NCOs in main data path
        CDDCNCOFrequencies = [1e6,1e6,1e6,1e6];
        % CDDCNCOEnable CDDC NCO Enable
        %   1x4 Array of booleans to enable NCOs in main data path
        CDDCNCOEnable = [false, false, false, false];
        % FDDCNCOFrequencies FDDC NCO Frequencies
        %   1x8 Array of frequencies of NCOs in channelizer path
        FDDCNCOFrequencies = [1e6,1e6,1e6,1e6,1e6,1e6,1e6,1e6];
        % FDDCNCOEnable FDDC NCO Enable
        %   1x4 Array of booleans to enable NCOs in channelizer path
        FDDCNCOEnable = [false, false, false, false, false, false, false, false];
        % MainDataPathDecimation Main Data Path Decimation
        %   Specify the decimation in the main data path which can be
        %   [1,2,3,4,6]
        MainDataPathDecimation = 1;
        % ChannelizerPathDecimation Channelizer Path Decimation
        %   Specify the decimation in the channelizer path which can be
        %   [1,2,3,4,6,8,12,16,24]
        ChannelizerPathDecimation = 1;
        % Crossbar4x4Mux0 Crossbar 4x4 Mux0
        %   Array of input and output mapping. Index is the output and the
        %   value is the selected input
        Crossbar4x4Mux0 = [1,2,3,4];
        % Crossbar4x8Mux2 Crossbar 4x8 Mux2
        %   Array of input and output mapping. Index is the output and the
        %   value is the selected input (values should not exceed 4)
        Crossbar4x8Mux2 = [1,2,1,2,3,4,3,4];
    end
    
    properties(Logical, Nontunable)
        % PFIREnable PFIR Enable
        %   Enable use of the programmable FIR filter
        PFIREnable = false
    end
    
    properties(Nontunable)
        %PFilter1Mode PFilter1 Mode
        %   Programmable filter configuration mode. The following notation
        %   will be used to describe the filtering modes:
        %   - x1: first input
        %   - x2: second input
        %   - y1: first output
        %   - y2: second output
        %   - F1: filter 1
        %   - F2: filter 2
        %   - F3: filter 3
        %   - F4: filter 4
        %   - p: length of filters (individually)
        %   The supported configuration modes are:
        %   - NoFilter: y1 = x1, y2 = x2
        %   - SingleInphase: y1 = F1(x1), y2 = x2
        %   - SingleQuadrature: y1 = x1, y2 = F1(x2)
        %   - DualReal: y1 = F1(x1), y2 = F2(x2)
        %   - HalfComplexSumInphase: y1 = F1(x1)+F2(x1), y2 = x2*z^-p
        %   - HalfComplexSumQuadrature: y2 = F1(x1)+F2(x1), y1 = x1*z^-p
        %   - FullComplex: y1 = F1(x1)-F3(x2), y2 = F1(x1)+F3(x2)-F2(x1+x2) 
        %   - Matrix: y1 = F1(x1) - F3(x2), y2 = F2(x1) - F4(x2)
        PFilter1Mode = 'SingleInphase';
        %PFilter1TapsWidthsPerQuad PFilter1 Taps Widths Per Quad
        %   Number of bits per each set of four coefficients. This matrix
        %   must be [NxM] where N is the number of distinct filters based
        %   on the current *Mode* parameter, and M is
        %   (number of individual taps)/4
        PFilter1TapsWidthsPerQuad = [...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6];
        %PFilter1Taps PFilter1Taps
        %   Filter coefficients. This matrix must be [NxM] where N is the 
        %   number of distinct filters based on the current *Mode* 
        %   parameter, and M is the number of individual taps
        PFilter1Taps = randn(4,192/4).*2^6;
        %PFilter1Gains PFilter1 Gains
        %   Gains for programmable filter 1. Can be -12,-6,0,6,12
        PFilter1Gains = [0,0,0,0];
        %PFilter2Mode PFilter2 Mode
        %   Programmable filter configuration mode. The following notation
        %   will be used to describe the filtering modes:
        %   - x1: first input
        %   - x2: second input
        %   - y1: first output
        %   - y2: second output
        %   - F1: filter 1
        %   - F2: filter 2
        %   - F3: filter 3
        %   - F4: filter 4
        %   - p: length of filters (individually)
        %   The supported configuration modes are:
        %   - NoFilter: y1 = x1, y2 = x2
        %   - SingleInphase: y1 = F1(x1), y2 = x2
        %   - SingleQuadrature: y1 = x1, y2 = F1(x2)
        %   - DualReal: y1 = F1(x1), y2 = F2(x2)
        %   - HalfComplexSumInphase: y1 = F1(x1)+F2(x1), y2 = x2*z^-p
        %   - HalfComplexSumQuadrature: y2 = F1(x1)+F2(x1), y1 = x1*z^-p
        %   - FullComplex: y1 = F1(x1)-F3(x2), y2 = F1(x1)+F3(x2)-F2(x1+x2) 
        %   - Matrix: y1 = F1(x1) - F3(x2), y2 = F2(x1) - F4(x2)
        PFilter2Mode = 'SingleInphase';
        %PFilter2TapsWidthsPerQuad PFilter2 Taps Widths Per Quad
        %   Number of bits per each set of four coefficients. This matrix
        %   must be [NxM] where N is the number of distinct filters based
        %   on the current *Mode* parameter, and M is
        %   (number of individual taps)/4
        PFilter2TapsWidthsPerQuad = [...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6;...
            16,16,16,12,12,12,6,6,6,6,6,6];
        %PFilter2Taps PFilter1Taps
        %   Filter coefficients. This matrix must be [NxM] where N is the 
        %   number of distinct filters based on the current *Mode* 
        %   parameter, and M is the number of individual taps
        PFilter2Taps = randn(4,192/4).*2^6;
        %PFilter2Gains PFilter2 Gains
        %   Gains for programmable filter 2. Can be -12,-6,0,6,12
        PFilter2Gains = [0,0,0,0];
    end
    
    properties(Logical, Nontunable)
        % ModeSelectMux1 Mode Select Mux1
        %   Boolean selection of false for real mode and true for complex
        %   mode
        ModeSelectMux1 = false;
    end
    
    properties
        % SampleRate Sample Rate of ADCs
        %   Scalar in Hz. Currently this is fixed since NSD will change
        %   with this number, which would make the model invalid
        SampleRate = 4e9;
    end
    
    properties(Hidden, Constant=true)
        PFilter1ModeSet = matlab.system.StringSet({'NoFilter','SingleInphase',...
            'SingleQuadrature','DualReal','HalfComplexSumInphase',...
            'HalfComplexSumQuadrature','FullComplex',...
            'Matrix'});
        PFilter2ModeSet = matlab.system.StringSet({'NoFilter','SingleInphase',...
            'SingleQuadrature','DualReal','HalfComplexSumInphase',...
            'HalfComplexSumQuadrature','FullComplex',...
            'Matrix'});
    end
    
    methods
        %% Constructor
        function obj = Rx(varargin)
            obj = obj@adi.sim.AD9081.Base(varargin{:});
        end
        function delete(obj)
            delete@adi.sim.AD9081.Base(obj);
        end
        % Check PFilter1Mode
        function set.PFilter1Mode(obj, value)
            obj.PFIR1.release();
            obj.PFIR1.Mode = value;
            obj.PFilter1Mode = value;
        end
        % Check PFilter2Mode
        function set.PFilter2Mode(obj, value)
            obj.PFIR2.release();
            obj.PFIR2.Mode = value;
            obj.PFilter2Mode = value;
        end
        % Check PFilter1TapsWidthsPerQuad
        function set.PFilter1TapsWidthsPerQuad(obj, value)
            obj.PFIR1.TapsWidthsPerQuad = value;
            obj.PFilter1TapsWidthsPerQuad = value;
        end
        % Check PFilter2TapsWidthsPerQuad
        function set.PFilter2TapsWidthsPerQuad(obj, value)
            obj.PFIR2.TapsWidthsPerQuad = value;
            obj.PFilter2TapsWidthsPerQuad = value;
        end
        % Check PFilter1Taps
        function set.PFilter1Taps(obj, value)
            obj.PFIR1.Taps = value;
            obj.PFilter1Taps = value;
        end
        % Check PFilter2Taps
        function set.PFilter2Taps(obj, value)
            obj.PFIR2.Taps = value;
            obj.PFilter2Taps = value;
        end
        % Check PFilter1Gains
        function set.PFilter1Gains(obj, value)
            obj.PFIR1.Gains = value;
            obj.PFilter1Gains = value;
        end

        % Check PFilter2Gains
        function set.PFilter2Gains(obj, value)
            obj.PFIR2.Gains = value;
            obj.PFilter2Gains = value;
        end
        
        % Check CDDCNCOFrequencies
        function set.CDDCNCOFrequencies(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '>=', -obj.SampleRate/2,'<=', obj.SampleRate/2}, ...
                '', 'CDDCNCOFrequencies');
            obj.CDDCNCOFrequencies = value;
            obj.setNCOFrequencies();
        end
        % Check FDDCNCOFrequencies
        function set.FDDCNCOFrequencies(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'finite', 'nonnan', 'nonempty', '>=', ...
                -obj.SampleRate/obj.MainDataPathDecimation/2,'<=', ...
                obj.SampleRate/obj.MainDataPathDecimation/2}, ...
                '', 'FDDCNCOFrequencies'); %#ok<MCSUP>
            obj.FDDCNCOFrequencies = value;
            obj.setNCOFrequencies();
        end
        % Check MainDataPathDecimation
        function set.MainDataPathDecimation(obj, value)
            obj.MainDataPathDecimation = value;
            obj.setDecimations();
        end
        % Check ChannelizerPathDecimation
        function set.ChannelizerPathDecimation(obj, value)
            obj.ChannelizerPathDecimation = value;
            obj.setDecimations();
        end
        % Check CDDCNCOEnable
        function set.CDDCNCOEnable(obj, value)
            obj.CDDCNCOEnable = value;
            obj.setNCOEnable();
        end
        % Check FDDCNCOEnable
        function set.FDDCNCOEnable(obj, value)
            obj.FDDCNCOEnable = value;
            obj.setNCOEnable();
        end
        % Check SampleRate
        function set.SampleRate(obj, value)
            validateattributes( value, { 'double','single' }, ...
                { 'real', 'scalar', 'finite', 'nonnan', 'nonempty', '>=', 1.5e9,'<=', 4e9}, ...
                '', 'SampleRate');
            obj.SampleRate = value;
            obj.setRates();
        end
        
        % Check Crossbar4x8Mux2
        function set.Crossbar4x8Mux2(obj, value)
            % Cannot support certain configs
            assert(all(value(1:4)<3),'Input to first half of Crossbar4x8Mux2 can only map from DDC 1-2');
            assert(all(value(5:8)>2),'Input to second half of Crossbar4x8Mux2 can only map from DDC 3-4');
            obj.Crossbar4x8Mux2 = value;
            obj.setRates();
        end
        % Check ModeSelectMux1
        function set.ModeSelectMux1(obj, value)
            % Cannot support certain configs
            if value % Complex To Real only supported with decimations of 2,4
                options = [2,4];
                assert(any(obj.MainDataPathDecimation==options),...
                    'In Complex to Real mode decimations of 2,4 are only supported for MainDataPathDecimation'); %#ok<MCSUP>
            end
            obj.ModeSelectMux1 = logical(value);
            obj.setRates();
        end
    end
    
    methods(Access = protected)
        
%         % Hide unused parameters when in specific modes
%         function flag = isInactivePropertyImpl(obj, prop)
%             flag = false;
%             if isprop(obj,'PFIREnable')
%                 if ~obj.PFIREnable
%                     flag = flag || strcmpi(prop,'PFilter1Mode');
%                     flag = flag || strcmpi(prop,'PFilter1TapsWidthsPerQuad');
%                     flag = flag || strcmpi(prop,'PFilter1Taps');
%                     flag = flag || strcmpi(prop,'PFilter1Gains');
%                     flag = flag || strcmpi(prop,'PFilter2Mode');
%                     flag = flag || strcmpi(prop,'PFilter2TapsWidthsPerQuad');
%                     flag = flag || strcmpi(prop,'PFilter2Taps');
%                     flag = flag || strcmpi(prop,'PFilter2Gains');
%                 end
%             end
%         end
        
        function setNCOFrequencies(obj)
            for k=1:4
                obj.(['CDDC',num2str(k)]).NCODesiredFrequency = obj.CDDCNCOFrequencies(k);
            end
            for k=1:8
                obj.(['FDDC',num2str(k)]).NCODesiredFrequency = obj.FDDCNCOFrequencies(k);
            end
        end
        
        function setDecimations(obj)
            for k=1:4
                obj.(['CDDC',num2str(k)]).Decimation = obj.MainDataPathDecimation;
            end
            for k=1:8
                obj.(['FDDC',num2str(k)]).Decimation = obj.ChannelizerPathDecimation;
            end
        end
        
        function setNCOEnable(obj)
            for k=1:4
                obj.(['CDDC',num2str(k)]).NCOEnable = obj.CDDCNCOEnable(k);
            end
            for k=1:8
                obj.(['FDDC',num2str(k)]).NCOEnable = obj.FDDCNCOEnable(k);
            end
        end
        
        function setRates(obj)
            for k=1:4
                obj.(['ADC',num2str(k-1)]).SampleRate = obj.SampleRate;
            end
            for k=1:4
                obj.(['CDDC',num2str(k)]).SampleRate = obj.SampleRate;
            end
            for k=1:8
                obj.(['FDDC',num2str(k)]).SampleRate = ...
                    obj.SampleRate/obj.MainDataPathDecimation;
            end
        end
        
        function setNCOConfigs(obj,data)

            minSFDR = 102; % >= Spurious free dynamic range in dBc
            phOffset = 0;
            % Calculate number of quantized accumulator bits
            % required from the SFDR requirement
            Nqacc = ceil((minSFDR-12)/6);

            for k=1:4
                obj.(['CDDC',num2str(k)]).NCO.SamplesPerFrame = length(data);
                obj.(['CDDC',num2str(k)]).NCO.PhaseOffset = phOffset;
                obj.(['CDDC',num2str(k)]).NCO.NumDitherBits = 4;
                obj.(['CDDC',num2str(k)]).NCO.NumQuantizerAccumulatorBits = Nqacc;
                obj.(['CDDC',num2str(k)]).NCO.Waveform = 'Complex exponential';
                obj.(['CDDC',num2str(k)]).NCO.CustomAccumulatorDataType =  numerictype([],obj.(['CDDC',num2str(k)]).NCOFTWWidth);
                obj.(['CDDC',num2str(k)]).NCO.PhaseIncrementSource = 'Property';
                obj.(['CDDC',num2str(k)]).NCO.PhaseIncrement = int64(getDDSCounterModulus(obj.(['CDDC',num2str(k)])));
                obj.(['CDDC',num2str(k)]).NCO.CustomOutputDataType =  numerictype([],17,16);
            end
        end
        
        function setupImpl(obj)
            % Set up all paths
            obj.setNCOFrequencies();
            obj.setDecimations();
            obj.setRates();
        end

        function releaseImpl(obj)
            % Release resources, such as file handles
            for k=1:4
                obj.(['CDDC',num2str(k)]).release();
            end
            for k=1:8
                obj.(['FDDC',num2str(k)]).release();
            end
            for k=1:4
                obj.(['ADC',num2str(k-1)]).release();
            end
        end

        function validateInputsImpl(obj,u0,u1,u2,u3)
            % Validate inputs to the step method at initialization
            d = (obj.MainDataPathDecimation*obj.ChannelizerPathDecimation);
            assert(mod(length(u0),d)==0, 'All input lengths must be a multiple of the combined decimation factor');
            assert(mod(length(u1),d)==0, 'All input lengths must be a multiple of the combined decimation factor');
            assert(mod(length(u2),d)==0, 'All input lengths must be a multiple of the combined decimation factor');
            assert(mod(length(u3),d)==0, 'All input lengths must be a multiple of the combined decimation factor');
        end
        
        function [...
                channelizerPathOut1,...
                channelizerPathOut2,...
                channelizerPathOut3,...
                channelizerPathOut4,...
                channelizerPathOut5,...
                channelizerPathOut6,...
                channelizerPathOut7,...
                channelizerPathOut8 ...
                ] = stepImpl(obj,u0,u1,u2,u3)
            
            u = fi([u0,u1,u2,u3],1,12,0);
            
            % Pass through ADCs
            u(:,1) = obj.ADC0(u0);
            u(:,2) = obj.ADC1(u1);
            u(:,3) = obj.ADC2(u2);
            u(:,4) = obj.ADC3(u3);
            % Apply mux0
            uMux0out = u;
            for k=1:4
                uMux0out(:,k) = u(:,obj.Crossbar4x4Mux0(k));
            end
            % PFilt stage
            if obj.PFIREnable
                [PFiltOut1,PFiltOut2] = obj.PFIR1(uMux0out(:,1),uMux0out(:,2));
                [PFiltOut3,PFiltOut4] = obj.PFIR2(uMux0out(:,3),uMux0out(:,4));
                uMux0out = [PFiltOut1,PFiltOut2,PFiltOut3,PFiltOut4];
            end
            % Mode select mux
            uMux1out = uMux0out;
            if obj.ModeSelectMux1
                uMux1out(:,1) = complex(uMux0out(:,1),uMux0out(:,2));
                uMux1out(:,2) = complex(uMux0out(:,1),uMux0out(:,2));
                uMux1out(:,3) = complex(uMux0out(:,3),uMux0out(:,4));
                uMux1out(:,4) = complex(uMux0out(:,3),uMux0out(:,4));
            end
            % CDDC stage
            mainDataPathOut1 = obj.CDDC1(uMux1out(:,1));
            mainDataPathOut2 = obj.CDDC2(uMux1out(:,2));
            mainDataPathOut3 = obj.CDDC3(uMux1out(:,3));
            mainDataPathOut4 = obj.CDDC4(uMux1out(:,4));
            
            mainDataPathOut = [...
                mainDataPathOut1, mainDataPathOut2,...
                mainDataPathOut3, mainDataPathOut4];
            
            % 4x8 Crossbar Mux 2
            uMux2out = [mainDataPathOut,mainDataPathOut];
            for k=1:8
                uMux2out(:,k) = mainDataPathOut(:,obj.Crossbar4x8Mux2(k));
            end
            
            % FDDC stage
            channelizerPathOut1 = obj.FDDC1(uMux2out(:,1));
            channelizerPathOut2 = obj.FDDC2(uMux2out(:,2));
            channelizerPathOut3 = obj.FDDC3(uMux2out(:,3));
            channelizerPathOut4 = obj.FDDC4(uMux2out(:,4));
            channelizerPathOut5 = obj.FDDC1(uMux2out(:,5));
            channelizerPathOut6 = obj.FDDC2(uMux2out(:,6));
            channelizerPathOut7 = obj.FDDC3(uMux2out(:,7));
            channelizerPathOut8 = obj.FDDC4(uMux2out(:,8));          
            
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
                "SampleTime", (obj.MainDataPathDecimation*obj.ChannelizerPathDecimation)/obj.SampleRate);
        end

        function dc = getInputDimensionConstraintImpl(obj,~)
            % Define input dimension constraint
            dc = inputDimensionConstraint(obj, "MinimumSize", ...
                (obj.MainDataPathDecimation*obj.ChannelizerPathDecimation), "Concatenable", true);
        end
        
        function icon = getIconImpl(~)
            % Define icon for System block
            icon = ["AD9081","Rx"];
        end
        
        function varargout = getInputNamesImpl(obj)
            % Return input port names for System block
            numInputs = getNumInputs(obj);
            varargout = cell(1,numInputs);
            for k = 1:numInputs
                varargout{k} = ['ADC',num2str(k-1)];
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
            d = obj.MainDataPathDecimation*obj.ChannelizerPathDecimation;
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

