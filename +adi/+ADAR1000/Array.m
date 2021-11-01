classdef Array < adi.common.Attribute & adi.common.Rx & ...
        matlabshared.libiio.base
    properties (Nontunable)
        %ChipIDs Chip IDs
        %   Strings identifying ADAR100 chip IDs. These strings are the 
        %   label coinciding with each chip select and is typically in 
        %   the form csb*_chip*, e.g., csb1_chip1.
        ChipIDs = {'csb1_chip1','csb1_chip2','csb1_chip3','csb1_chip4'};
        ADAR1000s = [1 2 3 4];
        ArrayElementMap = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
        ChannelElementMap = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
    end
    
    properties(Nontunable, Hidden)
%         Timeout = Inf;
        kernelBuffersCount = 0;
        dataTypeStr = 'int16';
%         phyDevName = 'adar1000';
        % Name of driver instance in device tree
        iioDriverName = 'adar1000';
%         iioDevPHY
        devName = 'adar1000';
        SamplesPerFrame = 0;
    end
    
    properties (Hidden)
        BeamDev
    end
    
    properties (Hidden, Constant, Logical)
        ComplexData = false;
    end
    
    properties(Nontunable, Hidden, Constant)
        Type = 'Rx';
%         channel_names = {''};
    end
    
    properties (Hidden, Nontunable, Access = protected)
        isOutput = false;
    end
    
    properties (Access = private)
        ChipIDHandles
    end
    
    methods
        %% Constructor
        function obj = Array(varargin)
            coder.allowpcode('plain');
            obj = obj@matlabshared.libiio.base(varargin{:});
        end
        % Destructor
        function delete(obj)
        end
    end
    
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
        
        function setupInit(obj)
            % Check that the number of chips matches for all the inputs
            if ~((numel(obj.ChipIDs)*4) == (numel(obj.ADAR1000s)*4)) || ...
                    ~((numel(obj.ChipIDs)*4) == numel(obj.ArrayElementMap)) || ...
                    ~(numel(obj.ArrayElementMap) == numel(obj.ChannelElementMap))
                error('The number of chips must match for all the inputs');
            end
            
            obj.ChipIDHandles = cell(numel(obj.ChipIDs), 1);
            for ii = 1:numel(obj.ChipIDs)
                obj.ChipIDHandles{ii} = adi.ADAR1000.Single;
                obj.ChipIDHandles{ii}.ChipID = obj.ChipIDs{ii};
                obj.ChipIDHandles{ii}.uri = obj.uri;
                obj.ChipIDHandles{ii}.ArrayElementMap = obj.ArrayElementMap;
                obj.ChipIDHandles{ii}.ChannelElementMap = ...
                    obj.ChannelElementMap(ii, :);
            end
            x = 1;
        end
    end
end