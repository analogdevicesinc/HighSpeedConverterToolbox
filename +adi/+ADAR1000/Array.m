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
            if ((numel(obj.ChipID)*4) ~= numel(obj.ArrayElementMap))
                error('Expected equal number of elements in ArrayElementMap and 4*numel(ChipIDs)');
            end
            if (numel(obj.ArrayElementMap) ~= numel(obj.ChannelElementMap))
                error('Expected equal number of elements in ArrayElementMap and ChannelElementMap');
            end
        end
        
        % Destructor
        function delete(obj)
        end
    end
    
    methods
        function SteerRx(obj, Azimuth, Elevation)
            % SteerRx Steer the Rx array in a particular direction. This method assumes that the entire array is one analog beam.
            % Parameters:
            %     Azimuth: float
            %         Desired beam angle in degrees for the horizontal direction.
            %     Elevation: float
            %         Desired beam angle in degrees for the vertical direction.        
            obj.Steer("Rx", Azimuth, Elevation);
        end
        
        function SteerTx(obj, Azimuth, Elevation)
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
        function Steer(obj, RxOrTx, Azimuth, Elevation)
            [AzimuthPhi, ElevationPhi] = obj.CalculatePhi(Azimuth, Elevation);
            
            % Update the class variables
            if strcmpi(RxOrTx, 'Rx')
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
        function setupInit(obj)
            setupInit@adi.ADAR1000.Single(obj);
            x = 1;
        end
    end
end