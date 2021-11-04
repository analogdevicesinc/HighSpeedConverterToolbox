clc;
clear;
close all;

dut = adi.ADAR1000.Single;
dut.uri = 'ip:192.168.1.111';
dut();
dutMode = cell(size(dut.ChipID));
dutMode(:) = {'tx'};
SelfBiasedLNAs = true;
if strcmpi(dutMode{1}, 'rx')
    dut.Mode = dutMode;
    
    if SelfBiasedLNAs
        % Allow the external LNAs to self-bias
        dut.LNABiasOutEnable = false;
    else
        % Set the external LNA bias
        dut.LNABiasOn = -0.7;
    end
    
    % Enable the Rx path for each channel
    dut.RxPowerDown = true(size(dut.ChannelElementMap));
    
    % Set the gain and phase
    dut.RxPhase = 10*dut.ChannelElementMap;
    dut.RxGain = hex2dec('0x67')*ones(size(dut.ChannelElementMap));
    
    % Latch in the gains & phases
    dut.LatchRxSettings();
elseif strcmpi(dutMode{1}, 'tx')
    device.mode = dutMode;

    % Enable the Tx path for each channel and set the external PA bias
    dut.TxPowerDown = true(size(dut.ChannelElementMap));
    dut.PABiasOn = -1.1*ones(size(dut.ChannelElementMap));
    
    % Set the gain and phase
    dut.TxPhase = 10*dut.ChannelElementMap;
    dut.TxGain = hex2dec('0x67')*ones(size(dut.ChannelElementMap));
    
    % Latch in the gains & phases
    dut.LatchTxSettings();
end