classdef Stingray < matlab.mixin.SetGet
    properties
        ADAR1000s = [1 2 3 4;5 6 7 8];
        ArrayElementMap = [1 2 3 4;5 6 7 8; 9 10 11 12; 13 14 15 16; ...
            17 18 19 20; 21 22 23 24; 25 26 27 28; 29 30 31 32];
        ChannelElementMap = [2 6 5 1; 4 8 7 3; 10 14 13 9; 12 16 15 11; ...
            18 22 21 17; 20 24 23 19; 26 30 29 25; 28 32 31 27];
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
        VoltageP5V
        VoltageP3V3
    end
            
    methods
        function result = get.PartiallyPowered(obj)
            result = logical(obj.PowerSequencerEnable && obj.PowerSequencerPowerGood);
        end
        
        function result = get.FullyPowered(obj)
            result = logical(obj.PartiallyPowered && obj.EnableP5V && obj.PowerGoodP5V);
        end
        
        function result = get.PowerSequencerEnable(obj)
            result = obj.Monitor.getGPIO1();
        end
        
        function result = get.EnableP5V(obj)
            result = obj.Monitor.getGPIO2();
        end
        
        function result = get.PowerSequencerPowerGood(obj)
            result = obj.Monitor.getGPIO3();
        end
        
        function result = get.PowerGoodP5V(obj)
            result = obj.Monitor.getGPIO4();
        end
        
        function result = get.VoltageP3V3(obj)
            % +3.3V RF rail voltage        
            result = obj.Monitor.Ch1Voltage();
        end
        
        function result = get.VoltageP5V(obj)
            % +5.0V RF rail current in amps
            result = obj.Monitor.Ch2Current();
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
            obj.ADAR1000Array = adi.ADAR1000.Array;
            obj.ADAR1000Array.uri = uri;
            obj.ADAR1000Array();
            
            % One-Bit-ADC-DAC
            obj.GPIOHandle = adi.OneBitADCDAC;
            obj.GPIOHandle.uri = uri;
            obj.GPIOHandle();
            
            % HW-Monitor
            obj.Monitor = adi.LTC2992;
            obj.Monitor.uri = obj.uri;
            obj.Monitor();
            
            % Ensure that the board is powered down
            obj.PowerDown();
        end
    
        function obj = PulsePowerPin(WhichGPIO)
            if strcmpi(WhichGPIO, 'pwr_up_down')
                obj.GPIOHandle.PowerUpDown = true;
                obj.GPIOHandle.PowerUpDown = false;
            elseif strcmpi(WhichGPIO, '5v_ctrl')
                obj.GPIOHandle.Ctrl5V = true;
                obj.GPIOHandle.Ctrl5V = false;
            end
        end
        
        function PowerDown(obj)
            % Power down the +5V rail if it's up
            if obj.PowerGoodP5V
                % Turn on a single PA to help bring this down faster
                Mode = cell(size(obj.ChipID));
                Mode(:) = {'tx'};
                PABiasOn = zeros(size(obj.ChipID));
                PABiasOn(1,1) = -1.1;
                obj.Mode = Mode;
                obj.PABiasOn = PABiasOn;
                
                % Send a signal to power down the +5V rail
                obj.PulsePowerPin('5v_ctrl');
                
                % Wait for the rail to go down
                while (obj.VoltageP5V > 0.5)
                    sleep(0.01);
                end
            end
            
            % Power down the remaining rails if they're up
            if obj.PowerSequencerPowerGood
                % Turn on a single cell's LNAs to help bring this down faster
                obj.LNABiasOutEnable = false(size(obj.ChipID));
                
                % Send a signal to power down the remaining rails
                obj.PulsePowerPin('pwr_up_down');
                
                % Wait for the rails to come down
                while (obj.VoltageP3V3 > 0.5)
                    sleep(0.01);
                end
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