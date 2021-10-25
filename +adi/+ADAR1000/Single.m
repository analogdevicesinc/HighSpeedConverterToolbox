classdef Single < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    
    properties (Constant)
        BIAS_CODE_TO_VOLTAGE_SCALE = -0.018824
    end
    
    properties (Nontunable)
        %ChipID Chip ID
        %   Cell array of strings identifying desired chip select
        %   option of ADAR100. This is based on the jumper configuration
        %   if the EVAL-ADAR100 is used. These strings are the labels
        %   coinciding with each chip select and are typically in the
        %   form csb*_chip*, e.g., csb1_chip1. When an ADAR1000 array
        %   is instantiated, the array class will handle the instantiation 
        %   of individual adar1000 handles.
        chipID = {'csb1_chip1'};
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        function setupImpl(obj)
            % Setup LibIIO
            setupLib(obj);
            
            % Initialize the pointers
            initPointers(obj);
            
            getContext(obj);
            
            setContextTimeout(obj);
            
            obj.needsTeardown = true;
            
            % Pre-calculate values to be used faster in stepImpl()
%             obj.pIsInSimulink = coder.const(obj.isInSimulink);
%             obj.pNumBufferBytes = coder.const(obj.numBufferBytes);
            
            obj.ConnectedToDevice = true;
            setupInit(obj);
        end
        function [data,valid] = stepImpl(~)
            data = 0;
            valid = false;
        end
        function setupInit(obj)
            % Do writes directly to hardware without using set methods.
            % This is required sine Simulink support doesn't support
            % modification to nontunable variables at SetupImpl
            
            % Check dimensions of arrays
            %{
            rows = length(obj.Beams);
            assert(isequal(size(obj.RxPhases),[rows,4]), 'RxPhases must be of size 4 x length(Beams)');
            assert(isequal(size(obj.TxPhases),[rows,4]), 'TxPhases must be of size 4 x length(Beams)');
            assert(isequal(size(obj.RxGains),[rows,4]), 'RxGains must be of size 4 x length(Beams)');
            assert(isequal(size(obj.TxGains),[rows,4]), 'TxGains must be of size 4 x length(Beams)');
            
            % Get devices based on beam arrangement
            obj.setBeams(rows);
            
            % Set attributes in hardware
            obj.setAllDevs(obj.RxPhases,'phase',false)
            obj.setAllDevs(obj.TxPhases,'phase',true)
            obj.setAllDevs(obj.RxGains,'hardwaregain',false)
            obj.setAllDevs(obj.TxGains,'hardwaregain',true)
            %}
        end
    end
end