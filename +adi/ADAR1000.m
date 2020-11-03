classdef ADAR1000 < adi.common.Attribute & ...
        adi.common.DebugAttribute & adi.common.Rx & ...
        matlabshared.libiio.base
    %ADAR1000 Beamformer
    properties (Nontunable)
        Beams = {'BEAM0'};
    end
    
    properties
        RxPhases = [0,0,0,0];
        TxPhases = [0,0,0,0];
        RxGains = [0,0,0,0];
        TxGains = [0,0,0,0];
    end
    
    properties(Nontunable, Hidden)
        Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
        phyDevName = 'adar1000';
        iioDriverName = 'dev';
        iioDevPHY
        devName = 'adar1000';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties (Hidden)
        beam_devs = {};
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
        channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    methods
        %% Constructor
        function obj = ADAR1000(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Destructor
        function delete(obj)
        end
        function val = CheckDims(obj,attr,val)
            rows = length(obj.Beams);
            assert(isequal(size(val),[rows,4]), [attr ' must be of size 4 x length(Beams)']);
        end
        function setAllDevs(obj,values,attr,output)
            tol = 1;
            for devIndx = 1:length(obj.beam_devs)
                for c = 1:4
                    chan = sprintf('voltage%d',c-1);
                    dev = obj.beam_devs{devIndx};
                    obj.setAttributeDouble(chan,attr,...
                        values(devIndx,c),output,tol,dev);
                end
            end
        end
        % Check Beams
        function set.Beams(obj, value)
            assert(iscell(value),'Beams must be a cell array of strings');
            obj.Beams = value;
        end
        % Check RxGains
        function set.RxGains(obj, value)
            obj.RxGains = obj.CheckDims('RxGains', value);
            if obj.ConnectedToDevice
                setAllDevs(obj,value,'hardwaregain',false)
            end
        end
        % Check TxGains
        function set.TxGains(obj, value)
            obj.TxGains = obj.CheckDims('TxGains', value);
            if obj.ConnectedToDevice
                setAllDevs(obj,value,'hardwaregain',true)
            end
        end
        % Check RxPhases
        function set.RxPhases(obj, value)
            obj.RxPhases = obj.CheckDims('RxPhases', value);
            if obj.ConnectedToDevice
                setAllDevs(obj,value,'phase',false)
            end
        end
        % Check TxPhases
        function set.TxPhases(obj, value)
            obj.TxPhases = obj.CheckDims('TxPhases', value);
            if obj.ConnectedToDevice
                setAllDevs(obj,value,'phase',true)
            end
        end
        
    end
    
    %% API Functions
    methods (Hidden, Access = protected)
        
        
        function setBeams(obj,rows)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            obj.beam_devs = {};
            for beamIndx = 1:rows
                found = false;
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);
                    attrCount = obj.iio_device_get_attrs_count(devPtr);
                    name = obj.iio_device_get_name(devPtr);
                    if strcmpi(name,obj.iioDriverName)
                        for i = 1:attrCount
                            attr = obj.iio_device_get_attr(devPtr,i-1);
                            if strcmpi(attr,'label')
                                val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                                if contains(val,obj.Beams{beamIndx})
                                    obj.beam_devs = [obj.beam_devs(:)', {devPtr}];
                                    found = true;
                                end
                            end
                        end
                    end
                end
                if ~found
                    error('Unable to locate %s in context',obj.Beams{beamIndx});
                end
            end
        end
        
        function setupImpl(obj)
            % Setup LibIIO
            setupLib(obj);
            
            % Initialize the pointers
            initPointers(obj);
            
            getContext(obj);
            
            setContextTimeout(obj);
            
            % Get the device
            % obj.iioDev = getDev(obj, obj.devName);
            
            obj.needsTeardown = true;
                        
            % Pre-calculate values to be used faster in stepImpl()
            obj.pIsInSimulink = coder.const(obj.isInSimulink);
            obj.pNumBufferBytes = coder.const(obj.numBufferBytes);
            
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
        end
    end
    
    %% External Dependency Methods
    methods (Hidden, Static)
        
        function tf = isSupportedContext(bldCfg)
            tf = matlabshared.libiio.ExternalDependency.isSupportedContext(bldCfg);
        end
        
        function updateBuildInfo(buildInfo, bldCfg)
            % Call the matlabshared.libiio.method first
            matlabshared.libiio.ExternalDependency.updateBuildInfo(buildInfo, bldCfg);
        end
        
    end
end



