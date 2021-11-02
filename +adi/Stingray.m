classdef Stingray < matlab.mixin.SetGet
    properties
        ADAR1000s = [1 2 3 4;5 6 7 8; 9 10 11 12; 13 14 15 16];
        ArrayElementMap = [1 2 3 4;5 6 7 8; 9 10 11 12; 13 14 15 16; ...
            17 18 19 20; 21 22 23 24; 25 26 27 28; 29 30 31 32; ...
            33 34 35 36; 37 38 39 40; 41 42 43 44; 45 46 47 48; ...
            49 50 51 52; 53 54 55 56; 57 58 59 60; 61 62 63 64];
        ChannelElementMap = [1 2 3 4;5 6 7 8; 9 10 11 12; 13 14 15 16; ...
            17 18 19 20; 21 22 23 24; 25 26 27 28; 29 30 31 32; ...
            33 34 35 36; 37 38 39 40; 41 42 43 44; 45 46 47 48; ...
            49 50 51 52; 53 54 55 56; 57 58 59 60; 61 62 63 64];
    end
    
    properties (Access = private)
        ADAR1000Array
        GPIOHandle
        Monitor
    end
    
    properties
        uri
        CSBs
        ChipIDs
        PartiallyPowered
        PowerSequencerEnable
        PowerSequencerPowerGood
        FullyPowered
        EnableP5V
        PowerGoodP5V
    end
            
    methods
        function res = get.PartiallyPowered(obj)
            res = logical(obj.PowerSequencerEnable && obj.PowerSequencerPowerGood);
        end
        
        function res = get.FullyPowered(obj)
            res = logical(obj.PartiallyPowered && obj.EnableP5V && obj.PowerGoodP5V);
        end
        
        function res = get.PowerSequencerEnable(obj)
            res = obj.Monitor.getGPIO1();
        end
        
        function res = get.EnableP5V(obj)
            res = obj.Monitor.getGPIO2();
        end
        
        function res = get.PowerSequencerPowerGood(obj)
            res = obj.Monitor.getGPIO3();
        end
        
        function res = get.PowerGoodP5V(obj)
            res = obj.Monitor.getGPIO4();
        end
    end
    
    methods
        function obj = Stingray(uri, CSBs)
            obj.uri = uri;
            for ii = 1:CSBs
                for jj = 1:4
                    obj.ChipIDs{4*(ii-1)+jj} = sprintf('csb%d_chip%d', ii, jj);
                end
            end
            obj.ADAR1000Array = adi.ADAR1000.Array('uri', uri);
            obj.ADAR1000Array();
            
            % One-Bit-ADC-DAC
            obj.GPIOHandle = adi.OneBitADCDAC;
            obj.GPIOHandle.uri = uri;
            obj.GPIOHandle();
            
            % HW-Monitor
            obj.Monitor = adi.LTC2992;
            obj.Monitor.uri = obj.uri;
            obj.Monitor();
        end
    
        function obj = PulsePowerPin(WhichGPIO)
            if strcmpi(WhichGPIO, 'pwr_up_down')
                obj.GPIOHandle.PowerUpDown = true;
                obj.GPIOHandle.PowerUpDown = false;
            else
                obj.GPIOHandle.Ctrl5V = true;
                obj.GPIOHandle.Ctrl5V = false;
            end
        end
        
        function obj = PowerUp(Enable5V)
            if ~obj.PartiallyPowered
                % Send a signal to power up the Stingray board's first few rails
                obj.PulsePowerPin('pwr_up_down');
                
                % Wait for the supplies to settle
                loops = 0;
                while ~obj.PowerSequencerPowerGood
                    pause(0.01);
                    loops = loops+1;
                    if (loops > 50)
                        error('Power sequencer PG pin never went high, something''s wrong');
                    end
                end
                
                if ~obj.PartiallyPowered
                    error('Board didn''t power up!');
                end
            end
            
            % Send a signal to power up the +5V rail
            if (Enable5V && ~obj.FullyPowered)
                obj.PulsePowerPin('5v_ctrl')
            end
            %{
            # Ensure that the devices are disabled and set to use SPI T/R control
            for device in self.devices.values():
                device.tr_source = 'spi'
                device.mode = 'disabled'
            %}
        end
    end
end