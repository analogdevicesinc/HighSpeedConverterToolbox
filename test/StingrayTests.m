classdef StingrayTests < HardwareTests
    properties
        uri = 'ip:192.168.1.100';
        author = 'ADI';
        sray
    end
    
    methods(TestClassSetup)
        %{
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.Stingray.Stingray;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
        %}
        function SetupStingray(testCase)
            % Setup Stingray
            testCase.sray = adi.Stingray.Stingray(testCase.uri);
            try
                testCase.sray.Configure();    
            catch ME
                disp(ME);
            end
        end        
    end
    
    %{
    methods(TestMethodTeardown)
        %{
        % Check hardware connected
        function CheckForHardware(testCase)
            Device = @()adi.Stingray.Stingray;
            testCase.CheckDevice('ip',Device,testCase.uri(4:end),false);
        end
        %}
        function ResetStingray(testCase)
            try
                testCase.sray.Configure();    
            catch ME
                disp(ME);
            end
        end        
    end
    %}
    
    % Device Attribute Tests
    methods (Test)
        function testMode(testCase)
            values = cell(size(testCase.sray.ADAR1000Array.ChipID));
            values(:) = {'Rx'};            
            values(randi([1 numel(testCase.sray.ADAR1000Array.ChipID)], 1, 3)) = {'Tx'};
            values(randi([1 numel(testCase.sray.ADAR1000Array.ChipID)], 1, 3)) = {'Disabled'};
            testCase.sray.ADAR1000Array.Mode = values;
            rvalues = testCase.sray.ADAR1000Array.Mode;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testStateTxOrRx(testCase)
            values = cell(size(testCase.sray.ADAR1000Array.ChipID));
            values(:) = {'Rx'};            
            values(randi([1 numel(testCase.sray.ADAR1000Array.ChipID)], 1, 3)) = {'Tx'};
            testCase.sray.ADAR1000Array.StateTxOrRx = values;
            rvalues = testCase.sray.ADAR1000Array.StateTxOrRx;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.RxEnable = values;
            rvalues = testCase.sray.ADAR1000Array.RxEnable;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxEnable = logical(false(size(testCase.sray.ADAR1000Array.ChipID)));
        end
        
        function testTxEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.TxEnable = values;
            rvalues = testCase.sray.ADAR1000Array.TxEnable;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxEnable = logical(false(size(testCase.sray.ADAR1000Array.ChipID)));
        end
        
        function testLNABiasOutEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.LNABiasOutEnable = values;
            rvalues = testCase.sray.ADAR1000Array.LNABiasOutEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testLNABiasOn(testCase)
            values = randi([127 255], size(testCase.sray.ADAR1000Array.ChipID))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
            testCase.sray.ADAR1000Array.LNABiasOn = values;
            rvalues = testCase.sray.ADAR1000Array.LNABiasOn;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.LNABiasOn = 200*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testBeamMemEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.BeamMemEnable = values;
            rvalues = testCase.sray.ADAR1000Array.BeamMemEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testBiasDACEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.BiasDACEnable = values;
            rvalues = testCase.sray.ADAR1000Array.BiasDACEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testBiasDACMode(testCase)
            values = cell(size(testCase.sray.ADAR1000Array.ChipID));
            values(:) = {'Toggle'};            
            values(randi([1 numel(testCase.sray.ADAR1000Array.ChipID)], 1, 3)) = {'On'};
            testCase.sray.ADAR1000Array.BiasDACMode = values;
            rvalues = testCase.sray.ADAR1000Array.BiasDACMode;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testBiasMemEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.BiasMemEnable = values;
            rvalues = testCase.sray.ADAR1000Array.BiasMemEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testCommonMemEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.CommonMemEnable = values;
            rvalues = testCase.sray.ADAR1000Array.CommonMemEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testCommonRxBeamState(testCase)
            values = randi([0 120])*ones(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.CommonRxBeamState = values;
            rvalues = testCase.sray.ADAR1000Array.CommonRxBeamState;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testCommonTxBeamState(testCase)
            values = randi([0 120])*ones(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.CommonTxBeamState = values;
            rvalues = testCase.sray.ADAR1000Array.CommonTxBeamState;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testExternalTRPin(testCase)
            values = cell(size(testCase.sray.ADAR1000Array.ChipID));
            values(:) = {'Pos'};            
            testCase.sray.ADAR1000Array.ExternalTRPin = values;
            rvalues = testCase.sray.ADAR1000Array.ExternalTRPin;
            testCase.verifyEqual(rvalues,values);
            
            values = cell(size(testCase.sray.ADAR1000Array.ChipID));
            values(:) = {'Neg'};            
            testCase.sray.ADAR1000Array.ExternalTRPin = values;
            rvalues = testCase.sray.ADAR1000Array.ExternalTRPin;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testExternalTRPolarity(testCase)
            values = true(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.ExternalTRPolarity = values;
            rvalues = testCase.sray.ADAR1000Array.ExternalTRPolarity;
            testCase.verifyEqual(rvalues,values);
            
            values = false(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.ExternalTRPolarity = values;
            rvalues = testCase.sray.ADAR1000Array.ExternalTRPolarity;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testLNABiasOff(testCase)
            values = randi([127 255], size(testCase.sray.ADAR1000Array.ChipID))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
            testCase.sray.ADAR1000Array.LNABiasOff = values;
            rvalues = testCase.sray.ADAR1000Array.LNABiasOff;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.LNABiasOn = 255*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testPolState(testCase)
            values = true(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.PolState = values;
            rvalues = testCase.sray.ADAR1000Array.PolState;
            testCase.verifyEqual(rvalues,values);
            
            values = false(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.PolState = values;
            rvalues = testCase.sray.ADAR1000Array.PolState;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testPolSwitchEnable(testCase)
            values = true(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.PolSwitchEnable = values;
            rvalues = testCase.sray.ADAR1000Array.PolSwitchEnable;
            testCase.verifyEqual(rvalues,values);
            
            values = false(size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.PolSwitchEnable = values;
            rvalues = testCase.sray.ADAR1000Array.PolSwitchEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxLNABiasCurrent(testCase)
            values = randi([5 8], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.RxLNABiasCurrent = values;
            rvalues = testCase.sray.ADAR1000Array.RxLNABiasCurrent;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxLNABiasCurrent = 5*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testRxLNAEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.RxLNAEnable = values;
            rvalues = testCase.sray.ADAR1000Array.RxLNAEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxToTxDelay1(testCase)
            values = randi([0 15], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.RxToTxDelay1 = values;
            rvalues = testCase.sray.ADAR1000Array.RxToTxDelay1;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxToTxDelay2(testCase)
            values = randi([0 15], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.RxToTxDelay2 = values;
            rvalues = testCase.sray.ADAR1000Array.RxToTxDelay2;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxVGAEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.RxVGAEnable = values;
            rvalues = testCase.sray.ADAR1000Array.RxVGAEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxVGABiasCurrentVM(testCase)
            values = randi([2 5], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.RxVGABiasCurrentVM = values;
            rvalues = testCase.sray.ADAR1000Array.RxVGABiasCurrentVM;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxVGABiasCurrentVM = 2*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testRxVMEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.RxVMEnable = values;
            rvalues = testCase.sray.ADAR1000Array.RxVMEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testSequencerEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.SequencerEnable = values;
            rvalues = testCase.sray.ADAR1000Array.SequencerEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTRSwitchEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.TRSwitchEnable = values;
            rvalues = testCase.sray.ADAR1000Array.TRSwitchEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxPABiasCurrent(testCase)
            values = randi([3 6], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.TxPABiasCurrent = values;
            rvalues = testCase.sray.ADAR1000Array.TxPABiasCurrent;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxPABiasCurrent = 3*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testTxPAEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.TxPAEnable = values;
            rvalues = testCase.sray.ADAR1000Array.TxPAEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxToRxDelay1(testCase)
            values = randi([0 15], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.TxToRxDelay1 = values;
            rvalues = testCase.sray.ADAR1000Array.TxToRxDelay1;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxToRxDelay2(testCase)
            values = randi([0 15], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.TxToRxDelay2 = values;
            rvalues = testCase.sray.ADAR1000Array.TxToRxDelay2;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxVGAEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.TxVGAEnable = values;
            rvalues = testCase.sray.ADAR1000Array.TxVGAEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxVGABiasCurrentVM(testCase)
            values = randi([2 5], size(testCase.sray.ADAR1000Array.ChipID));
            testCase.sray.ADAR1000Array.TxVGABiasCurrentVM = values;
            rvalues = testCase.sray.ADAR1000Array.TxVGABiasCurrentVM;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxVGABiasCurrentVM = 2*ones(size(testCase.sray.ADAR1000Array.ChipID));
        end
        
        function testTxVMEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChipID)));
            testCase.sray.ADAR1000Array.TxVMEnable = values;
            rvalues = testCase.sray.ADAR1000Array.TxVMEnable;
            testCase.verifyEqual(rvalues,values);
        end
    end
    
    % Channel Attribute Tests
    methods (Test)
        function testDetectorEnable(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.DetectorEnable = values;
            rvalues = testCase.sray.ADAR1000Array.DetectorEnable;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testPABiasOff(testCase)
            values = randi([127 255], size(testCase.sray.ADAR1000Array.ChannelElementMap))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
            testCase.sray.ADAR1000Array.PABiasOff = values;
            rvalues = testCase.sray.ADAR1000Array.PABiasOff;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.PABiasOff = 255*ones(size(testCase.sray.ADAR1000Array.ChannelElementMap))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
        end
        
        function testPABiasOn(testCase)
            values = randi([127 255], size(testCase.sray.ADAR1000Array.ChannelElementMap))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
            testCase.sray.ADAR1000Array.PABiasOn = values;
            rvalues = testCase.sray.ADAR1000Array.PABiasOn;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.PABiasOn = 255*ones(size(testCase.sray.ADAR1000Array.ChannelElementMap))*...
                testCase.sray.ADAR1000Array.BIAS_CODE_TO_VOLTAGE_SCALE;
        end
        
        function testRxAttn(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.RxAttn = values;
            rvalues = testCase.sray.ADAR1000Array.RxAttn;
            testCase.verifyEqual(rvalues,values);
        end        
        
        function testRxBeamState(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(randi([0 120], 1, tmp_size(2)), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.RxBeamState = values;
            rvalues = testCase.sray.ADAR1000Array.RxBeamState;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxPowerDown(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.RxPowerDown = values;
            rvalues = testCase.sray.ADAR1000Array.RxPowerDown;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxPowerDown = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
        
        function testRxGain(testCase)
            values = randi([0 127], size(testCase.sray.ADAR1000Array.ChannelElementMap));
            testCase.sray.ADAR1000Array.RxGain = values;
            rvalues = testCase.sray.ADAR1000Array.RxGain;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testRxPhase(testCase)
            values = randi([0 127], size(testCase.sray.ADAR1000Array.ChannelElementMap));
            testCase.sray.ADAR1000Array.RxPhase = values;
            rvalues = testCase.sray.ADAR1000Array.RxPhase;
            testCase.verifyEqual(rvalues,values, "AbsTol", 4);
        end
        
        function testTxAttn(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.TxAttn = values;
            rvalues = testCase.sray.ADAR1000Array.TxAttn;
            testCase.verifyEqual(rvalues,values);
        end        
        
        function testTxBeamState(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(randi([0 120], 1, tmp_size(2)), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.TxBeamState = values;
            rvalues = testCase.sray.ADAR1000Array.TxBeamState;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxPowerDown(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.TxPowerDown = values;
            rvalues = testCase.sray.ADAR1000Array.TxPowerDown;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxPowerDown = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
        
        function testTxGain(testCase)
            values = randi([0 127], size(testCase.sray.ADAR1000Array.ChannelElementMap));
            testCase.sray.ADAR1000Array.TxGain = values;
            rvalues = testCase.sray.ADAR1000Array.TxGain;
            testCase.verifyEqual(rvalues,values);
        end
        
        function testTxPhase(testCase)
            values = randi([0 127], size(testCase.sray.ADAR1000Array.ChannelElementMap));
            testCase.sray.ADAR1000Array.TxPhase = values;
            rvalues = testCase.sray.ADAR1000Array.TxPhase;
            testCase.verifyEqual(rvalues,values, "AbsTol", 4);
        end
        %{
        function testRxBiasState(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.RxBiasState = values;
            rvalues = testCase.sray.ADAR1000Array.RxBiasState;
            testCase.verifyEqual(rvalues,values);
        end
        %}
        function testRxSequencerStart(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(logical(randi([0 1], 1, tmp_size(2))), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.RxSequencerStart = values;
            rvalues = testCase.sray.ADAR1000Array.RxSequencerStart;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxSequencerStart = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
        
        function testRxSequencerStop(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(logical(randi([0 1], 1, tmp_size(2))), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.RxSequencerStop = values;
            rvalues = testCase.sray.ADAR1000Array.RxSequencerStop;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.RxSequencerStop = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
        %{
        function testTxBiasState(testCase)
            values = logical(randi([0 1], size(testCase.sray.ADAR1000Array.ChannelElementMap)));
            testCase.sray.ADAR1000Array.TxBiasState = values;
            rvalues = testCase.sray.ADAR1000Array.TxBiasState;
            testCase.verifyEqual(rvalues,values);
        end
        %}
        function testTxSequencerStart(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(logical(randi([0 1], 1, tmp_size(2))), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.TxSequencerStart = values;
            rvalues = testCase.sray.ADAR1000Array.TxSequencerStart;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxSequencerStart = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
        
        function testTxSequencerStop(testCase)
            tmp_size = size(testCase.sray.ADAR1000Array.ChannelElementMap);
            values = repmat(logical(randi([0 1], 1, tmp_size(2))), tmp_size(1), 1);
            testCase.sray.ADAR1000Array.TxSequencerStop = values;
            rvalues = testCase.sray.ADAR1000Array.TxSequencerStop;
            testCase.verifyEqual(rvalues,values);
            testCase.sray.ADAR1000Array.TxSequencerStop = false(size(testCase.sray.ADAR1000Array.ChannelElementMap));
        end
    end
end