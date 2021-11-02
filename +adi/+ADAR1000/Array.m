classdef Array < adi.ADAR1000.Single       
    properties
        Frequency = 10e9
        ElementSpacing = 0.015
        RxAzimuth = 0
        RxAzimuthPhi = 0
        RxElevation = 0
        RxElevationPhi = 0
        TxAzimuth = 0
        TxAzimuthPhi = 0
        TxElevation = 0
        TxElevationPhi = 0
        PrivateArrayElementMap
    end
    
    methods
        %{
        function res = get.ArrayElementMap(obj)
            res = obj.PrivateArrayElementMap;
        end
        
        function set.ArrayElementMap(obj, value)
            obj.PrivateArrayElementMap = value;
        end
        %}
        
        function res = get.Frequency(obj)
            res = obj.Frequency;
        end
        
        function set.Frequency(obj, value)
            obj.Frequency = value;
        end
        
        function res = get.ElementSpacing(obj)
            res = obj.ElementSpacing;
        end
        
        function set.ElementSpacing(obj, value)
            obj.ElementSpacing = value;
        end
        
        function res = get.RxAzimuth(obj)
            res = obj.RxAzimuth;
        end
        
        function set.RxAzimuth(obj, value)
            obj.RxAzimuth = value;
        end
        
        function res = get.RxAzimuthPhi(obj)
            res = obj.RxAzimuthPhi;
        end
        
        function set.RxAzimuthPhi(obj, value)
            obj.RxAzimuthPhi = value;
        end
        
        function res = get.RxElevation(obj)
            res = obj.RxElevation;
        end
        
        function set.RxElevation(obj, value)
            obj.RxElevation = value;
        end
        
        function res = get.RxElevationPhi(obj)
            res = obj.RxElevationPhi;
        end
        
        function set.RxElevationPhi(obj, value)
            obj.RxElevationPhi = value;
        end
        
        function res = get.TxAzimuth(obj)
            res = obj.TxAzimuth;
        end
        
        function set.TxAzimuth(obj, value)
            obj.TxAzimuth = value;
        end
        
        function res = get.TxAzimuthPhi(obj)
            res = obj.TxAzimuthPhi;
        end
        
        function set.TxAzimuthPhi(obj, value)
            obj.TxAzimuthPhi = value;
        end
        
        function res = get.TxElevation(obj)
            res = obj.TxElevation;
        end
        
        function set.TxElevation(obj, value)
            obj.TxElevation = value;
        end
        
        function res = get.TxElevationPhi(obj)
            res = obj.TxElevationPhi;
        end
        
        function set.TxElevationPhi(obj, value)
            obj.TxElevationPhi = value;
        end
    end
    
    methods
        %% Constructor
        function obj = Array(varargin)
            % Support name-value pair arguments when constructing object
            obj = obj@adi.ADAR1000.Single(varargin{:});
            if ~any(strcmp(varargin,'ArrayElementMap'))
                obj.ArrayElementMap = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
            end
            if ~any(strcmp(varargin,'ChannelElementMap'))
                obj.ChannelElementMap = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
            end
            if ~any(strcmp(varargin,'ChipID'))
                obj.ChipID = {'csb1_chip1','csb1_chip2','csb1_chip3','csb1_chip4'};
            end
            % Check that the number of chips matches for all the inputs
            if (numel(obj.ChipID) ~= obj.NumADAR1000s) || ...
                    ((numel(obj.ChipID)*4) ~= numel(obj.ArrayElementMap)) || ...
                    (numel(obj.ArrayElementMap) ~= numel(obj.ChannelElementMap))
                error('The number of chips must match for all the inputs');
            end
        end
        
        % Destructor
        function delete(obj)
        end
    end
    
    methods
        function obj = SteerRx(Azimuth, Elevation)
            % SteerRx Steer the Rx array in a particular direction. This method assumes that the entire array is one analog beam.
            % Parameters:
            %     Azimuth: float
            %         Desired beam angle in degrees for the horizontal direction.
            %     Elevation: float
            %         Desired beam angle in degrees for the vertical direction.        
            obj.Steer("Rx", Azimuth, Elevation);
        end
        
        function obj = SteerTx(Azimuth, Elevation)
            % SteerTx Steer the Tx array in a particular direction. This method assumes that the entire array is one analog beam.
            % Parameters:
            %     Azimuth: float
            %         Desired beam angle in degrees for the horizontal direction.
            %     Elevation: float
            %         Desired beam angle in degrees for the vertical direction.
            obj.Steer("Tx", Azimuth, Elevation)
        end
    end
    
    methods (Access = private)
        function obj = Steer(RxOrTx, Azimuth, Elevation)
            [AzimuthPhi, ElevationPhi] = obj.CalculatePhi(Azimuth, Elevation);
            
            % Update the class variables
            if strcmpi(rx_or_tx, 'Rx')
                obj.RxAzimuth = Azimuth;
                obj.RxElevation = Elevation;
                obj.RxAzimuth_phi = AzimuthPhi;
                obj.RxElevation_phi = ElevationPhi;
            else
                obj.TxAzimuth = Azimuth;
                obj.TxElevation = Elevation;
                obj.TxAzimuth_phi = AzimuthPhi;
                obj.TxElevation_phi = ElevationPhi;
            end
        end
        
        function [AzPhi, ElPhi] = CalculatePhi(obj, Azimuth, Elevation)
            % CalculatePhi Calculate the Φ angles to steer the array in a particular direction. 
            % This method assumes that the entire array is one analog beam.
            % Parameters:
            %     Azimuth: float
            %         Desired beam angle in degrees for the horizontal direction.
            %     Elevation: float
            %         Desired beam angle in degrees for the vertical direction.
            
            % Convert the input angles to radians
            AzR = Azimuth * pi / 180;
            ElR = Elevation * pi / 180;

            % Calculate the phase increment (Φ) for each element in the array in both directions (in degrees)
            AzPhi = 2 * self.frequency * self.element_spacing * sin(AzR) * 180 / 3e8;
            ElPhi = 2 * self.frequency * self.element_spacing * sin(ElR) * 180 / 3e8;
        end
    end
    
    methods (Hidden, Access = protected)
        %{
        function setChipID(obj)
            numDevs = obj.iio_context_get_devices_count(obj.iioCtx);
            obj.ChipIDHandle = {};
            for ChipIDIndx = 1:numel(obj.NumADAR1000s)
                found = false;
                for k = 1:numDevs
                    devPtr = obj.iio_context_get_device(obj.iioCtx, k-1);                    
                    name = obj.iio_device_get_name(devPtr);
                    if contains(name,obj.iioDriverName)
                        attrCount = obj.iio_device_get_attrs_count(devPtr);
                        for i = 1:attrCount
                            attr = obj.iio_device_get_attr(devPtr,i-1);
                            if strcmpi(attr,'label')
                                val = obj.getDeviceAttributeRAW(attr,128,devPtr);
                                if contains(obj.ChipID{ChipIDIndx},val)
                                    obj.ChipIDHandle = [obj.ChipIDHandle(:)', {devPtr}];
                                    found = true;
                                end
                            end
                        end
                    end
                end            
                if ~found
                    error('Unable to locate %s in context',obj.ChipID{ChipIDIndx});
                end
            end
        end
        %}
        function setupInit(obj)
            setupInit@adi.ADAR1000.Single(obj);
            %{
            % Check ArrayElementMap and ChannelElementMap have the same
            % elements
            if (numel(intersect(obj.ArrayElementMap, obj.ChannelElementMap)) ~= ...
                    numel(obj.ChannelElementMap))
                error('ChannelElementMap needs to contain the same elements as ArrayElementMap');
            end
            
            % Get devices based on beam arrangement
            obj.setChipID();
            
            % Get element indices in 2D, i.e., row and column numbers
            obj.ElementR = zeros(numel(obj.ArrayElementMap), 1);
            obj.ElementC = zeros(numel(obj.ArrayElementMap), 1);
            for ii = 1:numel(obj.ChannelElementMap)
                [obj.ElementR(ii), obj.ElementC(ii)] = ...
                    find(obj.ChannelElementMap(ii) == obj.ArrayElementMap);
            end
            
            % Create channel vector
            % obj.Channels = adi.ADAR1000.Channel.empty(numel(obj.ArrayElementMap), 1);
            for ii = 1:numel(obj.ChannelElementMap)
                obj.Channels(ii) = adi.ADAR1000.Channel(obj, ii, ...
                    obj.ChannelElementMap(ii), obj.ElementR(ii), obj.ElementC(ii));
            end
            %}
            %{
            obj.ChipIDHandles = cell(numel(obj.ChipID), 1);
            for ii = 1:numel(obj.ChipID)
                obj.ChipIDHandles{ii} = adi.ADAR1000.Single;
                obj.ChipIDHandles{ii}.ChipID = obj.ChipID{ii};
                obj.ChipIDHandles{ii}.uri = obj.uri;
                obj.ChipIDHandles{ii}.ArrayElementMap = obj.ArrayElementMap;
                obj.ChipIDHandles{ii}.ChannelElementMap = ...
                    obj.ChannelElementMap(ii, :);
            end
            %}
            x = 1;
        end
    end
end