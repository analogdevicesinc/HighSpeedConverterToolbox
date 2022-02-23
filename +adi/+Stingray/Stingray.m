classdef Stingray < matlab.mixin.SetGet
    properties
        Frequency = 10e9
        ADAR1000s = [1 2 3 4;5 6 7 8]';
        ArrayElementMap = [1 2 3 4;5 6 7 8; 9 10 11 12; 13 14 15 16; ...
            17 18 19 20; 21 22 23 24; 25 26 27 28; 29 30 31 32]';
        ChannelElementMap = [2 6 5 1; 4 8 7 3; 10 14 13 9; 12 16 15 11; ...
            18 22 21 17; 20 24 23 19; 26 30 29 25; 28 32 31 27]';
    end
    
    properties
        ADAR1000Array
        SRayCtrl
        XCtrl
        TDD
        Synth
    end
    
    properties
        uri
        CSBs
    end
            
    methods
        function obj = Stingray(uri)
            obj.uri = uri;
            
            % ADAR1000 Array
            obj.ADAR1000Array = adi.ADAR1000.Array;
            obj.ADAR1000Array.uri = obj.uri;            
            obj.ADAR1000Array.ChipID = cell(size(obj.ADAR1000s));
            for ii = 1:2
                for jj = 1:4
                    obj.ADAR1000Array.ChipID{4*(ii-1)+jj} = sprintf('csb%d_chip%d', ii, jj);
                end
            end
            obj.ADAR1000Array.ArrayElementMap = obj.ArrayElementMap;
            obj.ADAR1000Array.ChannelElementMap = obj.ChannelElementMap;
            obj.ADAR1000Array();
            
            % Stingray Control
            obj.SRayCtrl = adi.Stingray.StingrayControl;
            obj.SRayCtrl.uri = obj.uri;
            obj.SRayCtrl();
            
            % XUD1a Control
            obj.XCtrl = adi.Stingray.XUD1aControl;
            obj.XCtrl.uri = obj.uri;
            obj.XCtrl();
            
            % PLL
            obj.Synth = adi.Stingray.ADF4371;
            obj.Synth.uri = obj.uri;
            obj.Synth();
            
            % TDD
            % obj.TDD = adi.Stingray.AXICoreTDD;
            % obj.TDD.uri = obj.uri;
            % obj.TDD();
        end
    
        function Configure(obj)
            % Set the frequency
            obj.ADAR1000Array.Frequency = obj.Frequency;
            
            % Configure ADAR1000 Array
            ArrayMode = cell(size(obj.ADAR1000Array.ChipID));
            ArrayMode(:) = {'rx'};
            obj.ADAR1000Array.Mode = ArrayMode;
            obj.ADAR1000Array.LNABiasOutEnable = false(size(obj.ADAR1000Array.ChipID));
            obj.ADAR1000Array.RxPowerDown = false(size(obj.ADAR1000Array.ChannelElementMap));
        end
    end
end