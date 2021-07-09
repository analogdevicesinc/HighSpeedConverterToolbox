%% QuadMxFE_MCS.m
% Description: This script is to be used with the Analog Devices Quad-MxFE
% Platform to demonstrate MATLAB control of the system. It allows the user
% to configure the Tx and Rx aspects of the system and then load in
% transmit waveforms and capture receive data for all channels on the
% system. The script uses the on-system DSP blocks to align the device
% clocks, and output/input RF channels using the NCO phase offsets. It also
% provides the user with a way to test deterministic phase realized by
% implmenting the Multi-Chip Synchronization (MCS) features in the
% Quad-MxFE Platform.

% Author: Mike Jones
% Date: 10/27/2020

% This script requires the use of the Analog Devices, Inc. High
% Speed Converter Toolbox.

% Gain Access to the Analog Devices, Inc. High Speed Converter Toolbox at:
% https://github.com/analogdevicesinc/HighSpeedConverterToolbox

instrreset;
%% Reload FPGA Code
% LoadVcu118Code('C:\Xilinx\Vivado_Lab\2019.2\bin\xsdb.bat',...
%     'C:\SDG Builds\Quad MxFE for VCU118 2020-09-25\run.vcu118_quad_ad9081_204c_txmode_11_rxmode_4_revc.tcl')

%% Setup Parameters
close all;
clearvars;
graphicsInfo = groot;

uri = 'ip:192.168.2.1';
carrierFreq = 3.2e9; %Tx NCO Frequency & Unfolded Rx NCO Frequency [Hz]
amplitude = 2^15*db2mag(-8); %Tx Baseband Amplitude [dBFS]
periods = 32; %Desired Number Of Periods For Tx Signal
basebandFreq = 1.953125e6; %Baseband Frequency Used For Intermediate Results [Hz]
plotResults = 1; %0: Do not plot intermediate results, 1: Plot intermediate results
Align_ADF4371s = 1; %0: Do not align the ADF4371s, 1: Do align the ADF4371s
Align_PLL_Using_Rx = 0; %0: Use Tx alignment for PLL alignment, 1: Use Rx alignment for PLL alignment
powerAllAfterAlignment = 1; %0: Don't change waveform after calibration, 1: Do change waveform after calibration
minCodeValue = 500; %Lowest Acceptaple ADC Code Value. Anything Lower Is Regarded As a 'Bad' Capture [arb]
useCalibrationBoard = 1; %0: Not using calibration board, 1: Using calibration board

%% Setup Tx Information
tx = adi.QuadMxFE.Tx;
tx.UpdateDACFullScaleCurrent = true;
tx.DACFullScaleCurrentuA = 40000;

tx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
tx.uri = uri;

% Poll System Information
tx(1);
fs_RxIQ = str2double(tx.getAttributeRAW('voltage0_i','sampling_frequency',0,tx.iioDev0)); %Rx Decimated IQ Sample Rate [Hz]
fs_Rx = str2double(tx.getAttributeRAW('voltage0_i','adc_frequency',0,tx.iioDev0)); %ADC Sample Rate [SPS]

[errorVal,retVal] = system(['iio_attr -u' uri ' -c -i axi-ad9081-rx-0']);
numFineDDCsPerMxFE = length(strfind(retVal,'voltage'))/2; %Number of Fine DDCs In The System

[errorVal,retVal] = system(['iio_attr -u' uri ' -c -o axi-ad9081-rx-0']);
numFineDUCsPerMxFE = length(strfind(retVal,'voltage'))/2; %Number of Fine DUCs In The System
release(tx);
tx.UpdateDACFullScaleCurrent = false;

tx.num_coarse_attr_channels = 4; %Number of Coarse DUCs Used Per MxFE
tx.num_fine_attr_channels = numFineDUCsPerMxFE; %Number of Fine DUCs Used Per MxFE
tx.num_data_channels = 4*tx.num_fine_attr_channels; %Total Number of Fine DUCs Used In System        
tx.num_dds_channels = tx.num_data_channels*4; %Total Number of DDSs Used In System (Not Used For 'DMA' Mode)
tx.EnabledChannels = 1:1:tx.num_data_channels; %Enabled Tx Channels, Only Needed for DMA
tx.EnableResampleFilters = 0; %Enable A Divide-By-Two Resampling
tx.DataSource = 'DMA'; %'DMA' or 'DDS'
tx.EnableCyclicBuffers = 1; %0: Don't Cycle Tx Waveform, 1: Cycle Tx Waveform
tx.MainNCOFrequenciesChipA = ones(1,tx.num_coarse_attr_channels)*carrierFreq; %MxFE0 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipB = ones(1,tx.num_coarse_attr_channels)*carrierFreq; %MxFE1 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipC = ones(1,tx.num_coarse_attr_channels)*carrierFreq; %MxFE2 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipD = ones(1,tx.num_coarse_attr_channels)*carrierFreq; %MxFE3 Coarse DUC NCO Frequencies [Hz]
tx.ChannelNCOFrequenciesChipA = zeros(1,tx.num_fine_attr_channels); %MxFE0 Fine DUC NCO Frequencies [Hz]
tx.ChannelNCOFrequenciesChipB = zeros(1,tx.num_fine_attr_channels); %MxFE1 Fine DUC NCO Frequencies [Hz]
tx.ChannelNCOFrequenciesChipC = zeros(1,tx.num_fine_attr_channels); %MxFE2 Fine DUC NCO Frequencies [Hz]
tx.ChannelNCOFrequenciesChipD = zeros(1,tx.num_fine_attr_channels); %MxFE3 Fine DUC NCO Frequencies [Hz]
tx.MainNCOPhasesChipA = zeros(1,tx.num_coarse_attr_channels).*1e3; %MxFE0 Coarse DUC NCO Phase Offsets [Degrees*1e3]
tx.MainNCOPhasesChipB = zeros(1,tx.num_coarse_attr_channels).*1e3; %MxFE1 Coarse DUC NCO Phase Offsets [Degrees*1e3]
tx.MainNCOPhasesChipC = zeros(1,tx.num_coarse_attr_channels).*1e3; %MxFE2 Coarse DUC NCO Phase Offsets [Degrees*1e3]
tx.MainNCOPhasesChipD = zeros(1,tx.num_coarse_attr_channels).*1e3; %MxFE3 Coarse DUC NCO Phase Offsets [Degrees*1e3]
tx.ChannelNCOPhasesChipA = zeros(1,tx.num_fine_attr_channels).*1e3; %MxFE0 Fine DUC NCO Phase Offsets [Degrees*1e3]
tx.ChannelNCOPhasesChipB = zeros(1,tx.num_fine_attr_channels).*1e3; %MxFE1 Fine DUC NCO Phase Offsets [Degrees*1e3]
tx.ChannelNCOPhasesChipC = zeros(1,tx.num_fine_attr_channels).*1e3; %MxFE2 Fine DUC NCO Phase Offsets [Degrees*1e3]
tx.ChannelNCOPhasesChipD = zeros(1,tx.num_fine_attr_channels).*1e3; %MxFE3 Fine DUC NCO Phase Offsets [Degrees*1e3]
tx.NCOEnablesChipA = ones(1,tx.num_fine_attr_channels); %MxFE0 Fine DUC Enables
tx.NCOEnablesChipB = ones(1,tx.num_fine_attr_channels); %MxFE1 Fine DUC Enables
tx.NCOEnablesChipC = ones(1,tx.num_fine_attr_channels); %MxFE2 Fine DUC Enables
tx.NCOEnablesChipD = ones(1,tx.num_fine_attr_channels); %MxFE3 Fine DUC Enables
% 12-Bit Normalized Digital Gain Code (Valid Values 0 to 1)
% 0<=Gain<=(2^12-1)/2^11=1.9995; Gain=GainCode/2048
% Normalized Gain Code = GainCode/2
tx.ChannelNCOGainScalesChipA  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE0 Digital Gain Code
tx.ChannelNCOGainScalesChipB  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE1 Digital Gain Code
tx.ChannelNCOGainScalesChipC  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE2 Digital Gain Code
tx.ChannelNCOGainScalesChipD  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE3 Digital Gain Code

%% Prepare Pulsed Baseband Data For Each Channel
% Each Tx Channel Is Gated In Time At Baseband Such That Only One
% Channel is 'ON' At A Time
f = fs_RxIQ/50;
numSignalPeriods = 1; %Number Of 1/f Periods Channel Is ON
numZeroPeriods = 1; %Number Of 1/f Periods Between Channels

tSignal = 0:1/fs_RxIQ:numSignalPeriods/f;
zerosArray = zeros(1,length(0:1/fs_RxIQ:(numZeroPeriods/f)-(2/fs_RxIQ)));

channelArray = zeros(tx.num_data_channels,2^12);
summedArray = [];
for i=1:1:tx.num_data_channels
    y(i,:) = amplitude.*exp(1j.*(2.*pi.*f.*tSignal + 0));
    channelStart(i,1) = length(summedArray)+1;
    channelArray(i,channelStart(i,:):channelStart(i,:)+length(y(i,:))-1) = y(i,:);
    summedArray = [summedArray y(i,:) zerosArray];
end
release(tx);
tx(channelArray'); %Output Tx Waveform
pause(1);

%% Configure Calibration Board For Desired Routing
if (useCalibrationBoard)
    CalibrationBoard = CalBoardVCU118;
    CalibrationBoard.ConfigureCombinedLoopback(tx);
%         CalibrationBoard.ConfigureAdjacentIndividualLoopback(tx);
%         CalibrationBoard.ConfigureTxOutToSMA(tx);
%         AD8318_voltage = CalibrationBoard.QueryAD8318_voltage(tx);
%         CalibrationBoard.ConfigureRxInFromSMA(tx); 
end

%% Setup HMC7043 Coarse/Fine SYSREF Delays
%         tx.setRegister(hex2dec('00'),'EA',tx.iioDevHMC7043); %SYSREF1 Coarse Digital Delay Set To Zero

%% Setup MxFEs For Fast-Frequency Hopping Mode
tx.setRegister(hex2dec('0F'),'1B',tx.iioDev0); %DDSM Page Mask
tx.setRegister(hex2dec('EE'),'806',tx.iioDev0); %3.7GHz FTW1
tx.setRegister(hex2dec('EE'),'807',tx.iioDev0); %
tx.setRegister(hex2dec('EE'),'808',tx.iioDev0); %
tx.setRegister(hex2dec('4E'),'809',tx.iioDev0); %
tx.setRegister(hex2dec('93'),'80A',tx.iioDev0); %1.93GHz FTW2
tx.setRegister(hex2dec('5F'),'80B',tx.iioDev0); %
tx.setRegister(hex2dec('2C'),'80C',tx.iioDev0); %
tx.setRegister(hex2dec('29'),'80D',tx.iioDev0); %
tx.setRegister(hex2dec('A7'),'80E',tx.iioDev0); %1.8025GHz FTW3
tx.setRegister(hex2dec('0D'),'80F',tx.iioDev0); %
tx.setRegister(hex2dec('74'),'810',tx.iioDev0); %
tx.setRegister(hex2dec('26'),'811',tx.iioDev0); %
tx.setRegister(hex2dec('82'),'812',tx.iioDev0); %2.0675GHz FTW4
tx.setRegister(hex2dec('4E'),'813',tx.iioDev0); %
tx.setRegister(hex2dec('1B'),'814',tx.iioDev0); %
tx.setRegister(hex2dec('2C'),'815',tx.iioDev0); %
tx.setRegister(hex2dec('80'),'800',tx.iioDev0); %Phase Coherent Switch to FTW0

tx.setRegister(hex2dec('0F'),'01B',tx.iioDev1); %DDSM Page Mask
tx.setRegister(hex2dec('EE'),'806',tx.iioDev1); %3.7GHz FTW1
tx.setRegister(hex2dec('EE'),'807',tx.iioDev1); %
tx.setRegister(hex2dec('EE'),'808',tx.iioDev1); %
tx.setRegister(hex2dec('4E'),'809',tx.iioDev1); %
tx.setRegister(hex2dec('93'),'80A',tx.iioDev1); %1.93GHz FTW2
tx.setRegister(hex2dec('5F'),'80B',tx.iioDev1); %
tx.setRegister(hex2dec('2C'),'80C',tx.iioDev1); %
tx.setRegister(hex2dec('29'),'80D',tx.iioDev1); %
tx.setRegister(hex2dec('A7'),'80E',tx.iioDev1); %1.8025GHz FTW3
tx.setRegister(hex2dec('0D'),'80F',tx.iioDev1); %
tx.setRegister(hex2dec('74'),'810',tx.iioDev1); %
tx.setRegister(hex2dec('26'),'811',tx.iioDev1); %
tx.setRegister(hex2dec('82'),'812',tx.iioDev1); %2.0675GHz FTW4
tx.setRegister(hex2dec('4E'),'813',tx.iioDev1); %
tx.setRegister(hex2dec('1B'),'814',tx.iioDev1); %
tx.setRegister(hex2dec('2C'),'815',tx.iioDev1); %
tx.setRegister(hex2dec('80'),'800',tx.iioDev1); %Phase Coherent Switch to FTW0

tx.setRegister(hex2dec('0F'),'01B',tx.iioDev2); %DDSM Page Mask
tx.setRegister(hex2dec('EE'),'806',tx.iioDev2); %3.7GHz FTW1
tx.setRegister(hex2dec('EE'),'807',tx.iioDev2); %
tx.setRegister(hex2dec('EE'),'808',tx.iioDev2); %
tx.setRegister(hex2dec('4E'),'809',tx.iioDev2); %
tx.setRegister(hex2dec('93'),'80A',tx.iioDev2); %1.93GHz FTW2
tx.setRegister(hex2dec('5F'),'80B',tx.iioDev2); %
tx.setRegister(hex2dec('2C'),'80C',tx.iioDev2); %
tx.setRegister(hex2dec('29'),'80D',tx.iioDev2); %
tx.setRegister(hex2dec('A7'),'80E',tx.iioDev2); %1.8025GHz FTW3
tx.setRegister(hex2dec('0D'),'80F',tx.iioDev2); %
tx.setRegister(hex2dec('74'),'810',tx.iioDev2); %
tx.setRegister(hex2dec('26'),'811',tx.iioDev2); %
tx.setRegister(hex2dec('82'),'812',tx.iioDev2); %2.0675GHz FTW4
tx.setRegister(hex2dec('4E'),'813',tx.iioDev2); %
tx.setRegister(hex2dec('1B'),'814',tx.iioDev2); %
tx.setRegister(hex2dec('2C'),'815',tx.iioDev2); %
tx.setRegister(hex2dec('80'),'800',tx.iioDev2); %Phase Coherent Switch to FTW0

tx.setRegister(hex2dec('0F'),'01B',tx.iioDev3); %DDSM Page Mask
tx.setRegister(hex2dec('EE'),'806',tx.iioDev3); %3.7GHz FTW1
tx.setRegister(hex2dec('EE'),'807',tx.iioDev3); %
tx.setRegister(hex2dec('EE'),'808',tx.iioDev3); %
tx.setRegister(hex2dec('4E'),'809',tx.iioDev3); %
tx.setRegister(hex2dec('93'),'80A',tx.iioDev3); %1.93GHz FTW2
tx.setRegister(hex2dec('5F'),'80B',tx.iioDev3); %
tx.setRegister(hex2dec('2C'),'80C',tx.iioDev3); %
tx.setRegister(hex2dec('29'),'80D',tx.iioDev3); %
tx.setRegister(hex2dec('A7'),'80E',tx.iioDev3); %1.8025GHz FTW3
tx.setRegister(hex2dec('0D'),'80F',tx.iioDev3); %
tx.setRegister(hex2dec('74'),'810',tx.iioDev3); %
tx.setRegister(hex2dec('26'),'811',tx.iioDev3); %
tx.setRegister(hex2dec('82'),'812',tx.iioDev3); %2.0675GHz FTW4
tx.setRegister(hex2dec('4E'),'813',tx.iioDev3); %
tx.setRegister(hex2dec('1B'),'814',tx.iioDev3); %
tx.setRegister(hex2dec('2C'),'815',tx.iioDev3); %
tx.setRegister(hex2dec('80'),'800',tx.iioDev3); %Phase Coherent Switch to FTW0

%% Setup Rx Information and Connection
rx = adi.QuadMxFE.Rx;
rx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
rx.uri = uri;
rx.num_coarse_attr_channels = 4; %Number of Coarse DDCs Used Per MxFE
rx.num_fine_attr_channels = numFineDDCsPerMxFE; %Number of Fine DDCs Used Per MxFE
rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
rx.EnabledChannels = 1:1:rx.num_data_channels; %Enabled Rx Channels
% Keep In Mind That NCO Frequencies Range From -fs_RxIQ/2 to +rx_RxIQ/2
% If In 2nd Nyquist Enter The Folded NCO Frequency
rx.MainNCOFrequenciesChipA = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE0 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipB = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE1 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipC = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE2 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipD = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE3 Coarse DDC NCO Frequencies [Hz]
rx.ChannelNCOFrequenciesChipA = zeros(1,rx.num_fine_attr_channels); %MxFE0 Fine DDC NCO Frequencies [Hz]
rx.ChannelNCOFrequenciesChipB = zeros(1,rx.num_fine_attr_channels); %MxFE1 Fine DDC NCO Frequencies [Hz]
rx.ChannelNCOFrequenciesChipC = zeros(1,rx.num_fine_attr_channels); %MxFE2 Fine DDC NCO Frequencies [Hz]
rx.ChannelNCOFrequenciesChipD = zeros(1,rx.num_fine_attr_channels); %MxFE3 Fine DDC NCO Frequencies [Hz]
rx.MainNCOPhasesChipA = zeros(1,rx.num_coarse_attr_channels); %MxFE0 Coarse DDC NCO Phase Offsets [Degrees*1e3]
rx.MainNCOPhasesChipB = zeros(1,rx.num_coarse_attr_channels); %MxFE1 Coarse DDC NCO Phase Offsets [Degrees*1e3]
rx.MainNCOPhasesChipC = zeros(1,rx.num_coarse_attr_channels); %MxFE2 Coarse DDC NCO Phase Offsets [Degrees*1e3]
rx.MainNCOPhasesChipD = zeros(1,rx.num_coarse_attr_channels); %MxFE3 Coarse DDC NCO Phase Offsets [Degrees*1e3]
rx.ChannelNCOPhasesChipA = zeros(1,rx.num_fine_attr_channels); %MxFE0 Fine DDC NCO Phase Offsets [Degrees*1e3]
rx.ChannelNCOPhasesChipB = zeros(1,rx.num_fine_attr_channels); %MxFE1 Fine DDC NCO Phase Offsets [Degrees*1e3]
rx.ChannelNCOPhasesChipC = zeros(1,rx.num_fine_attr_channels); %MxFE2 Fine DDC NCO Phase Offsets [Degrees*1e3]
rx.ChannelNCOPhasesChipD = zeros(1,rx.num_fine_attr_channels); %MxFE3 Fine DDC NCO Phase Offsets [Degrees*1e3]
rx.ExternalAttenuation = 0; %On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]
rx.SamplesPerFrame = 2^12; %Number Of Samples To Capture
rx.kernelBuffersCount = 1; %Number Of Buffers To Subsequently Capture
rx.EnableResampleFilters = 0; %Enable A Divide-By-Two Resampling
rx.EnablePFIRsChipA = false; %MxFE0 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipB = false; %MxFE1 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipC = false; %MxFE2 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipD = false; %MxFE3 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
data = rx(); %Initialize The Rx System; Grab The Rx Data Into 'data' Matrix
rx.setRegister(hex2dec('FF'),'19',rx.iioDev0); %Fine DDC Page
rx.setRegister(hex2dec('FF'),'19',rx.iioDev1); %Fine DDC Page
rx.setRegister(hex2dec('FF'),'19',rx.iioDev2); %Fine DDC Page
rx.setRegister(hex2dec('FF'),'19'); %Fine DDC Page
rx.setRegister(hex2dec('61'),'283',rx.iioDev0); %Fine DDC Control
rx.setRegister(hex2dec('61'),'283',rx.iioDev1); %Fine DDC Control
rx.setRegister(hex2dec('61'),'283',rx.iioDev2); %Fine DDC Control
rx.setRegister(hex2dec('61'),'283'); %Fine DDC Control
rx.setRegister(hex2dec('1F'),'210F',rx.iioDev0); %Image Canceler: 0x210F = 0x1F; Might Need to be 0x2110=0x1F instead
rx.setRegister(hex2dec('1'),'2100',rx.iioDev0); %Image Canceler: 0x2100 = 0x1
rx.setRegister(hex2dec('1F'),'210F',rx.iioDev1); %Image Canceler: 0x210F = 0x1F
rx.setRegister(hex2dec('1'),'2100',rx.iioDev1); %Image Canceler: 0x2100 = 0x1
rx.setRegister(hex2dec('1F'),'210F',rx.iioDev2); %Image Canceler: 0x210F = 0x1F
rx.setRegister(hex2dec('1'),'2100',rx.iioDev2); %Image Canceler: 0x2100 = 0x1    
rx.setRegister(hex2dec('1F'),'210F'); %Image Canceler: 0x210F = 0x1F
rx.setRegister(hex2dec('1'),'2100'); %Image Canceler: 0x2100 = 0x1
regVal = dec2hex(rx.getRegister('283',rx.iioDev0));
regVal = dec2hex(rx.getRegister('283',rx.iioDev1));
regVal = dec2hex(rx.getRegister('283',rx.iioDev2));
regVal = dec2hex(rx.getRegister('283'));
pause(1);

%% Issue Synchronization Algorithms
sysrefPhasesAfterSync = ones(1,4);
numTimesForOneShotSync = 0;

while (sum(sysrefPhasesAfterSync)>0)
    tx.setDeviceAttributeRAW('multichip_sync', '10', tx.iioDev3); %Issue MCS

    tx.setRegister(hex2dec('00'),'B5',tx.iioDev0);
    sysref_Phase0 = tx.getRegister('B6',tx.iioDev0);
    sysref_Phase0 = sysref_Phase0 + 2^9*tx.getRegister('B5',tx.iioDev0); %Monitor SYSREF Phase
    tx.setRegister(hex2dec('00'),'B5',tx.iioDev1);
    sysref_Phase1 = tx.getRegister('B6',tx.iioDev1);
    sysref_Phase1 = sysref_Phase1 + 2^9*tx.getRegister('B5',tx.iioDev1); %Monitor SYSREF Phase
    tx.setRegister(hex2dec('00'),'B5',tx.iioDev2);
    sysref_Phase2 = tx.getRegister('B6',tx.iioDev2);
    sysref_Phase2 = sysref_Phase2 + 2^9*tx.getRegister('B5',tx.iioDev2); %Monitor SYSREF Phase
    tx.setRegister(hex2dec('00'),'B5',tx.iioDev3);
    sysref_Phase3 = tx.getRegister('B6',tx.iioDev3);
    sysref_Phase3 = sysref_Phase3 + 2^9*tx.getRegister('B5',tx.iioDev3); %Monitor SYSREF Phase   
    sysrefPhasesAfterSync = [sysref_Phase0, sysref_Phase1, sysref_Phase2, sysref_Phase3]

    if (sum(sysrefPhasesAfterSync)==0) %SYSREF Phase Is Stable, Now Check Once More To Confirm
        tx.setRegister(hex2dec('00'),'B5',tx.iioDev0);
        sysref_Phase0 = tx.getRegister('B6',tx.iioDev0);
        sysref_Phase0 = sysref_Phase0 + 2^9*tx.getRegister('B5',tx.iioDev0); %Monitor SYSREF Phase
        tx.setRegister(hex2dec('00'),'B5',tx.iioDev1);
        sysref_Phase1 = tx.getRegister('B6',tx.iioDev1);
        sysref_Phase1 = sysref_Phase1 + 2^9*tx.getRegister('B5',tx.iioDev1); %Monitor SYSREF Phase
        tx.setRegister(hex2dec('00'),'B5',tx.iioDev2);
        sysref_Phase2 = tx.getRegister('B6',tx.iioDev2);
        sysref_Phase2 = sysref_Phase2 + 2^9*tx.getRegister('B5',tx.iioDev2); %Monitor SYSREF Phase
        tx.setRegister(hex2dec('00'),'B5',tx.iioDev3);
        sysref_Phase3 = tx.getRegister('B6',tx.iioDev3);
        sysref_Phase3 = sysref_Phase3 + 2^9*tx.getRegister('B5',tx.iioDev3); %Monitor SYSREF Phase   
        sysrefPhasesAfterSync = [sysref_Phase0, sysref_Phase1, sysref_Phase2, sysref_Phase3]
    else %SYSREF->LEMC Phase Is Not Stable, Adjust PLL/Synthesizer To Compensate
        badSysrefPhases = find(sysrefPhasesAfterSync>0);
        for PLLNum=badSysrefPhases
            switch PLLNum
                case 1
                    varNamePLL = genvarname('iioDevADF4371_0');
                case 2
                    varNamePLL = genvarname('iioDevADF4371_1');
                case 3
                    varNamePLL = genvarname('iioDevADF4371_2');
                case 4
                    varNamePLL = genvarname('iioDevADF4371_3');
            end
            ADF4371_PhaseAdjust = 90; %Adjust Corresponding PLL/Synthesizer By 90-Degrees
            while (ADF4371_PhaseAdjust>0)
                if (ADF4371_PhaseAdjust>360)
                    phaseWord = dec2hex(round(359.99997*2^24/360),6);
                    ADF4371_PhaseAdjust = ADF4371_PhaseAdjust - 360;
                else
                    phaseWord = dec2hex(round(ADF4371_PhaseAdjust*2^24/360),6);
                    ADF4371_PhaseAdjust = 0;
                end
                tx.setRegister(hex2dec('04'),'2B',eval(['tx.' varNamePLL])); %Turn On Sigma-Delta
                tx.setRegister(hex2dec('00'),'12',eval(['tx.' varNamePLL])); %Turn Off Autocalibration
                tx.setRegister(hex2dec('40'),'1A',eval(['tx.' varNamePLL])); %Turn ON Phase Adjust
                tx.setRegister(hex2dec(phaseWord(5:6)),'1B',eval(['tx.' varNamePLL]));
                tx.setRegister(hex2dec(phaseWord(3:4)),'1C',eval(['tx.' varNamePLL]));
                tx.setRegister(hex2dec(phaseWord(1:2)),'1D',eval(['tx.' varNamePLL]));
                reg10Val = tx.getRegister('10',eval(['tx.' varNamePLL]));
                tx.setRegister(reg10Val,'10',eval(['tx.' varNamePLL])); 
            end
            fprintf(['PLL' num2str(PLLNum-1) ' Phase Adjusted By 90 Degrees\n']);
        end
    end

    numTimesForOneShotSync = numTimesForOneShotSync + 1;
end        

tstart = tic;        

%% Grab Initial Rx Data
pause(1);
data = rx(); %Grab the Rx data & save to 'data' matrix

tx.setRegister(hex2dec('00'),'B5',tx.iioDev0);
sysref_Phase0 = tx.getRegister('B6',tx.iioDev0);
sysref_Phase0 = sysref_Phase0 + 2^9*tx.getRegister('B5',tx.iioDev0); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev1);
sysref_Phase1 = tx.getRegister('B6',tx.iioDev1);
sysref_Phase1 = sysref_Phase1 + 2^9*tx.getRegister('B5',tx.iioDev1); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev2);
sysref_Phase2 = tx.getRegister('B6',tx.iioDev2);
sysref_Phase2 = sysref_Phase2 + 2^9*tx.getRegister('B5',tx.iioDev2); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev3);
sysref_Phase3 = tx.getRegister('B6',tx.iioDev3);
sysref_Phase3 = sysref_Phase3 + 2^9*tx.getRegister('B5',tx.iioDev3); %Monitor SYSREF Phase   
sysrefPhasesAfterBaselineCapture = [sysref_Phase0, sysref_Phase1, sysref_Phase2, sysref_Phase3]

badCaptures = 0;
while (sum(max(real(data))>minCodeValue)~=rx.num_data_channels)
    badCaptures = badCaptures + 1;
    fprintf('Bad Capture During ADF4371 Phase Alignment!\n');
    if (badCaptures>4)
        error('Bad Capture During ADF4371 Phase Alignment!\n');
    end
    tx.setDeviceAttributeRAW('multichip_sync', '10', tx.iioDev3);
    pause(1);
    data = rx(); %Grab the Rx data
end        

% Plot Initial PLL/Synthesizer Baseline Results
if (plotResults==1)
    pllCalFigureHandle = figure('Name','PLL Calibration','Position',graphicsInfo.ScreenSize);
    subplot(2,4,1);
    plot(real(data));
    hold on;
    plot(imag(data));
    hold off;
    xlabel('Sample Number');
    ylabel('ADC Code');
    xlim([0 2^12]);
    grid on;
    title('Prior To Rx Calibration');
    drawnow;

    for chanNum=2:1:rx.num_data_channels
        subplot(2,4,5);
        corrValue = real(xcorr(data(:,1),data(:,chanNum)))./max((abs(xcorr(data(:,1),data(:,chanNum)))));
        if (rx.EnableResampleFilters)
            plot(linspace(-rx.SamplesPerFrame/2,rx.SamplesPerFrame/2,rx.SamplesPerFrame-1),corrValue);
        else
            plot(linspace(-rx.SamplesPerFrame,rx.SamplesPerFrame,2*rx.SamplesPerFrame-1),corrValue);
        end
        xlabel('Sample Number');
        ylabel('Normalized Cross-Correlation');
        xlim([-2^12 2^12]);
        grid on;
        hold on;

    end
    hold off;
    drawnow;
end

%% Poll ADF4371 Temperatures To Determine Gradient
tx.setRegister(hex2dec('0C'),'32',tx.iioDevADF4371_0);
tx.setRegister(hex2dec('A3'),'33',tx.iioDevADF4371_0);
adf4371_temp(1) = double(tx.getRegister('6E',tx.iioDevADF4371_0)) - 83.5;
tx.setRegister(hex2dec('0C'),'32',tx.iioDevADF4371_1);
tx.setRegister(hex2dec('A3'),'33',tx.iioDevADF4371_1);
adf4371_temp(2) = double(tx.getRegister('6E',tx.iioDevADF4371_1)) - 83.5;
tx.setRegister(hex2dec('0C'),'32',tx.iioDevADF4371_2);
tx.setRegister(hex2dec('A3'),'33',tx.iioDevADF4371_2);
adf4371_temp(3) = double(tx.getRegister('6E',tx.iioDevADF4371_2)) - 83.5;
tx.setRegister(hex2dec('0C'),'32',tx.iioDevADF4371_3);
tx.setRegister(hex2dec('A3'),'33',tx.iioDevADF4371_3);
adf4371_temp(4) = double(tx.getRegister('6E',tx.iioDevADF4371_3)) - 83.5;
deltaTemp = adf4371_temp - adf4371_temp(1);

%% Perform ADF4371 Phase Alignment
if (Align_ADF4371s==1)
    % Find the pulse corresponding to Tx0
    if (abs(real(data(1,1)))>500 || abs(imag(data(1,1)))>500 || ...
            abs(real(data(50,1)))>500 || abs(imag(data(50,1)))>500) %Check if signal is present at start of capture
        [separation,initialCross,finalCross,nextCross,midLev] = ...
            pulsesep(double(abs(real(data(:,1)))>500)); 
        [maxVal, maxLoc] = max(separation);
        channel0Start = ceil(nextCross(maxLoc)); %The Tx0 pulse location
    else %Correct if signal is zero at start of capture
        [period,initialCross,finalCross,nextCross,midLev] = ...
            pulseperiod(double(abs(real(data(:,1)))>500));
        channel0Start = ceil(initialCross(1));
    end
    timeZeroAlignedFirstRx = circshift(data(:,1),-channel0Start);
    timeZeroAligned = circshift(data,-channel0Start);

    % Determine Required ADF4371 Phase Adjustments
    phaseOffsets = angle(timeZeroAligned)*180/pi;
    misalignedPhaseRx = phaseOffsets(10,:) - phaseOffsets(10,1);
    % Now determine the phase offsets for each Tx
    for i=1:1:tx.num_data_channels
        txPhaseOffsets(i,1) = angle(timeZeroAlignedFirstRx(1+(i-1)*100))*180/pi;
        txPhaseOffsetToApply(i,1) = wrapTo360(txPhaseOffsets(i,1) - txPhaseOffsets(1,1));
    end

    iterVal=1;
    for i=1:rx.num_fine_attr_channels:rx.num_data_channels
        if misalignedPhaseRx(1,i)>0
            newPhaseAdjustmentRx(1,iterVal) = 360-misalignedPhaseRx(1,i);
        else
            newPhaseAdjustmentRx(1,iterVal) = -misalignedPhaseRx(1,i);
        end
        iterVal = iterVal + 1;
    end    
    newPhaseAdjustmentRx = wrapTo360(newPhaseAdjustmentRx);

    if (Align_PLL_Using_Rx==1)
        PLL_phaseAdjust = ((12e9/2)/carrierFreq).*newPhaseAdjustmentRx;
    else
        PLL_phaseAdjust = ((12e9/2)/carrierFreq).*txPhaseOffsetToApply(1:tx.num_fine_attr_channels:tx.num_data_channels-1,1);
    end

    % Apply ADF4371 PLL/Synthesizer Phase Adjustments To PLL1/PLL2/PLL3
    % To Match Rx0 Of Each MxFE
    phaseWord = dec2hex(round(PLL_phaseAdjust(1)*2^24/360),6);
    tx.setRegister(hex2dec('04'),'2B',tx.iioDevADF4371_0); %Turn On Sigma-Delta
    tx.setRegister(hex2dec('00'),'12',tx.iioDevADF4371_0); %Turn Off Autocalibration
    tx.setRegister(hex2dec('40'),'1A',tx.iioDevADF4371_0); %Turn ON Phase Adjust
    tx.setRegister(hex2dec(phaseWord(5:6)),'1B',tx.iioDevADF4371_0);
    tx.setRegister(hex2dec(phaseWord(3:4)),'1C',tx.iioDevADF4371_0);
    tx.setRegister(hex2dec(phaseWord(1:2)),'1D',tx.iioDevADF4371_0);
    reg10Val = tx.getRegister('10',tx.iioDevADF4371_0);
    tx.setRegister(reg10Val,'10',tx.iioDevADF4371_0);    

    % Adjust Second PLL/Synthesizer Phase
    ADF4371_2_PhaseAdjust = PLL_phaseAdjust(2);
    while (ADF4371_2_PhaseAdjust>0)
        if (ADF4371_2_PhaseAdjust>360)
            phaseWord = dec2hex(round(359.99997*2^24/360),6);
            ADF4371_2_PhaseAdjust = ADF4371_2_PhaseAdjust - 360;
        else
            phaseWord = dec2hex(round(ADF4371_2_PhaseAdjust*2^24/360),6);
            ADF4371_2_PhaseAdjust = 0;
        end
        tx.setRegister(hex2dec('04'),'2B',tx.iioDevADF4371_1); %Turn On Sigma-Delta
        tx.setRegister(hex2dec('00'),'12',tx.iioDevADF4371_1); %Turn Off Autocalibration
        tx.setRegister(hex2dec('40'),'1A',tx.iioDevADF4371_1); %Turn ON Phase Adjust
        tx.setRegister(hex2dec(phaseWord(5:6)),'1B',tx.iioDevADF4371_1);
        tx.setRegister(hex2dec(phaseWord(3:4)),'1C',tx.iioDevADF4371_1);
        tx.setRegister(hex2dec(phaseWord(1:2)),'1D',tx.iioDevADF4371_1);
        reg10Val = tx.getRegister('10',tx.iioDevADF4371_1);
        tx.setRegister(reg10Val,'10',tx.iioDevADF4371_1);
    end

    % Adjust Third PLL/Synthesizer Phase
    ADF4371_3_PhaseAdjust = PLL_phaseAdjust(3);
    while (ADF4371_3_PhaseAdjust>0)
        if (ADF4371_3_PhaseAdjust>360)
            phaseWord = dec2hex(round(359.99997*2^24/360),6);
            ADF4371_3_PhaseAdjust = ADF4371_3_PhaseAdjust - 360;
        else
            phaseWord = dec2hex(round(ADF4371_3_PhaseAdjust*2^24/360),6);
            ADF4371_3_PhaseAdjust = 0;
        end
        tx.setRegister(hex2dec('04'),'2B',tx.iioDevADF4371_2); %Turn On Sigma-Delta
        tx.setRegister(hex2dec('00'),'12',tx.iioDevADF4371_2); %Turn Off Autocalibration
        tx.setRegister(hex2dec('40'),'1A',tx.iioDevADF4371_2); %Turn ON Phase Adjust
        tx.setRegister(hex2dec(phaseWord(5:6)),'1B',tx.iioDevADF4371_2);
        tx.setRegister(hex2dec(phaseWord(3:4)),'1C',tx.iioDevADF4371_2);
        tx.setRegister(hex2dec(phaseWord(1:2)),'1D',tx.iioDevADF4371_2);
        reg10Val = tx.getRegister('10',tx.iioDevADF4371_2);
        tx.setRegister(reg10Val,'10',tx.iioDevADF4371_2);
    end

    % Adjust Fourth PLL/Synthesizer Phase
    ADF4371_4_PhaseAdjust = PLL_phaseAdjust(4);
    while (ADF4371_4_PhaseAdjust>0)
        if (ADF4371_4_PhaseAdjust>360)
            phaseWord = dec2hex(round(359.99997*2^24/360),6);
            ADF4371_4_PhaseAdjust = ADF4371_4_PhaseAdjust - 360;
        else
            phaseWord = dec2hex(round(ADF4371_4_PhaseAdjust*2^24/360),6);
            ADF4371_4_PhaseAdjust = 0;
        end
        tx.setRegister(hex2dec('04'),'2B',tx.iioDevADF4371_3); %Turn On Sigma-Delta
        tx.setRegister(hex2dec('00'),'12',tx.iioDevADF4371_3); %Turn Off Autocalibration
        tx.setRegister(hex2dec('40'),'1A',tx.iioDevADF4371_3); %Turn ON Phase Adjust
        tx.setRegister(hex2dec(phaseWord(5:6)),'1B',tx.iioDevADF4371_3);
        tx.setRegister(hex2dec(phaseWord(3:4)),'1C',tx.iioDevADF4371_3);
        tx.setRegister(hex2dec(phaseWord(1:2)),'1D',tx.iioDevADF4371_3);
        reg10Val = tx.getRegister('10',tx.iioDevADF4371_3);
        tx.setRegister(reg10Val,'10',tx.iioDevADF4371_3); 
    end
    pause(0.5);

    if (plotResults==1)
        data = rx();

        % Plot Synthesizer-Aligned Rx Results
        subplot(2,4,2);
        plot(real(data(:,1)));
        hold on;
        if (Align_PLL_Using_Rx==1)
            plot(real(data(:,5)));
            plot(real(data(:,9)));
            plot(real(data(:,13)));
        else
            plot(imag(data(:,1)));
        end
        hold off;
        xlabel('Sample Number');
        ylabel('ADC Code');
        xlim([0 2^12]);
        grid on;
        title('After PLL Calibration');
        drawnow;

        for chanNum=2:1:rx.num_data_channels
            subplot(2,4,6);
            corrValue = real(xcorr(data(:,1),data(:,chanNum)))./max((abs(xcorr(data(:,1),data(:,chanNum)))));
            if (rx.EnableResampleFilters)
                plot(linspace(-rx.SamplesPerFrame/2,rx.SamplesPerFrame/2,rx.SamplesPerFrame-1),corrValue);
            else
                plot(linspace(-rx.SamplesPerFrame,rx.SamplesPerFrame,2*rx.SamplesPerFrame-1),corrValue);
            end
            xlabel('Sample Number');
            ylabel('Normalized Cross-Correlation');
            xlim([-2^12 2^12]);
            grid on;
            hold on;
        end
        hold off;
        drawnow;   
    else
        data = rx(); %Grab PLL-Aligned Data
    end
    while (sum(max(real(data))>minCodeValue)~=rx.num_data_channels)
        error('Bad Capture During Tx/Rx Calibration!\n');
    end
else
    PLL_phaseAdjust = zeros(1,4);
end

%% Poll All MxFE Temperatures
temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev0);
mxfe_temp(1) = temp/1e3;
temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev1);
mxfe_temp(2) = temp/1e3;
temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev2);
mxfe_temp(3) = temp/1e3;
temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev3);
mxfe_temp(4) = temp/1e3;        

%% Align All Tx Channels
% Now Find The Pulse Corresponding To Tx0
if (abs(real(data(1,1)))>500 || abs(imag(data(1,1)))>500 || ...
        abs(real(data(50,1)))>500 || abs(imag(data(50,1)))>500) %Check if signal is present at start of capture
    [separation,initialCross,finalCross,nextCross,midLev] = ...
        pulsesep(double(abs(real(data(:,1)))>500)); 
    [maxVal, maxLoc] = max(separation);
    channel0Start = ceil(nextCross(maxLoc)); %The Tx0 pulse location
else %Correct if signal is zero at start of capture
    [period,initialCross,finalCross,nextCross,midLev] = ...
        pulseperiod(double(abs(real(data(:,1)))>500));
    channel0Start = ceil(initialCross(1));
end
timeZeroAlignedFirstRx = circshift(data(:,1),-channel0Start);
timeZeroAligned = circshift(data,-channel0Start);
% Now Determine the Phase Offsets for Each Tx Channel
for i=1:1:tx.num_data_channels
    txPhaseOffsets(i,1) = angle(timeZeroAlignedFirstRx(1+(i-1)*100))*180/pi;
    txPhaseOffsetToApply(i,1) = wrapTo180(txPhaseOffsets(i,1) - txPhaseOffsets(1,1));
end
alignedTxPhases(1,:) = txPhaseOffsetToApply(1:tx.num_fine_attr_channels);
alignedTxPhases(2,:) = txPhaseOffsetToApply(1*tx.num_fine_attr_channels+1:2*tx.num_fine_attr_channels);
alignedTxPhases(3,:) = txPhaseOffsetToApply(2*tx.num_fine_attr_channels+1:3*tx.num_fine_attr_channels);
alignedTxPhases(4,:) = txPhaseOffsetToApply(3*tx.num_fine_attr_channels+1:4*tx.num_fine_attr_channels);

% Apply Tx NCO Phase Offsets
if (tx.num_fine_attr_channels<=4)
    tx.MainNCOPhasesChipA = alignedTxPhases(1,:).*1e3;
    tx.MainNCOPhasesChipB = alignedTxPhases(2,:).*1e3;
    tx.MainNCOPhasesChipC = alignedTxPhases(3,:).*1e3;
    tx.MainNCOPhasesChipD = alignedTxPhases(4,:).*1e3;
else
    tx.ChannelNCOPhasesChipA = alignedTxPhases(1,:).*1e3;
    tx.ChannelNCOPhasesChipB = alignedTxPhases(2,:).*1e3;
    tx.ChannelNCOPhasesChipC = alignedTxPhases(3,:).*1e3;
    tx.ChannelNCOPhasesChipD = alignedTxPhases(4,:).*1e3;            
end

if (plotResults==1)
    txCalibrationFigureHandle = figure('Name','Tx Calibration','Position',graphicsInfo.ScreenSize);
    subplot(3,1,1);
    plot(real(data(:,1)));
    grid on;
    xlim([0 2^12]);
    xlabel('Sample Number');
    ylabel('ADC Code');
    title('Data Prior To Determining Tx0 Location');
    
    subplot(3,1,2);
    plot(real(timeZeroAlignedFirstRx));
    grid on;
    xlim([0 2^12]);
    xlabel('Sample Number');
    ylabel('ADC Code');
    title('Data After Determining Tx0 Location');
end

%% Perform Rx Phase Calibration Using AD9081 NCO Phase Offsets
phaseOffsets = angle(timeZeroAligned)*180/pi;
for chanNum=2:1:rx.num_data_channels
    MxFENum = floor((chanNum-1)/rx.num_fine_attr_channels) + 1;
    chanIndexOnMxFE = mod(chanNum-1,rx.num_fine_attr_channels) + 1;
    switch MxFENum
        case 1
            varNamePhase = genvarname('MainNCOPhasesChipA');
        case 2
            varNamePhase = genvarname('MainNCOPhasesChipB');
        case 3
            varNamePhase = genvarname('MainNCOPhasesChipC');
        case 4
            varNamePhase = genvarname('MainNCOPhasesChipD');
    end 
    misalignedPhaseRx = phaseOffsets(10,chanNum) - phaseOffsets(10,1);    
    eval(['newMisalignedPhase = rx.' varNamePhase '(chanIndexOnMxFE) + misalignedPhaseRx*1e3;'])
    if (newMisalignedPhase>180e3)
        newMisalignedPhase = -(360e3-newMisalignedPhase);
    elseif (newMisalignedPhase<-180e3)
        newMisalignedPhase = 360e3+newMisalignedPhase;
    end
    % Apply Rx NCO Phase Offsets
    eval(['rx.' varNamePhase '(chanIndexOnMxFE) = newMisalignedPhase;']);
end
alignedRxPhases = ...
    [rx.MainNCOPhasesChipA; rx.MainNCOPhasesChipB;...
    rx.MainNCOPhasesChipC; rx.MainNCOPhasesChipD]./1e3;

%% Observe Final Results
if (plotResults==1)
    data = rx(); % Grab Rx Data & Save To 'data' Matrix
    % Now find the pulse corresponding to Tx0
    if (abs(real(data(1,1)))>500 || abs(imag(data(1,1)))>500 || ...
            abs(real(data(50,1)))>500 || abs(imag(data(50,1)))>500) %Check if signal is present at start of capture
        [separation,initialCross,finalCross,nextCross,midLev] = ...
            pulsesep(double(abs(real(data(:,1)))>500)); 
        [maxVal, maxLoc] = max(separation);
        channel0Start = ceil(nextCross(maxLoc)); %The Tx0 pulse location
    else %Correct if signal is zero at start of capture
        [period,initialCross,finalCross,nextCross,midLev] = ...
            pulseperiod(double(abs(real(data(:,1)))>500));
        channel0Start = ceil(initialCross(1));
    end
    timeZeroAlignedFirstRx = circshift(data(:,1),-channel0Start);
    timeZeroAligned = circshift(data,-channel0Start);
    subplot(3,1,3);
    plot(real(timeZeroAlignedFirstRx));
    grid on;
    xlim([0 2^12]);
    xlabel('Sample Number');
    ylabel('ADC Code');
    title('Data After Tx/Rx Calibration');

      % Ensure Integer Periods To Make Waveform Cycling Contiguous
    if (basebandFreq ~= 0)
        samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
        samplesPerFrameCheck = samplesPerFrame;
        while rem(samplesPerFrameCheck,1)~=0
            samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
        end
        samplesPerFrame = samplesPerFrameCheck;
        while (samplesPerFrame > 2^12) % Max is 8k samples
            if (periods>1)
                periods = periods - 1;
                samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
                samplesPerFrameCheck = samplesPerFrame;
                while rem(samplesPerFrameCheck,1)~=0
                    samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
                end
                samplesPerFrame = samplesPerFrameCheck;
            else
                basebandFreq = 0e6;
                samplesPerFrame = 2^12; %Max is 8k samples
            end
        end    
    else
        samplesPerFrame = 2^12; %Max is 8k samples
    end
    while (samplesPerFrame < 32) %Need minimum of 32 samples
        periods = periods*2;
        samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
        samplesPerFrameCheck = samplesPerFrame;
        while rem(samplesPerFrameCheck,1)~=0
            samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
        end
        samplesPerFrame = samplesPerFrameCheck;
    end

    % Inject A Single-Tone Waveform Into Memory
    amplitude = 2^15*db2mag(-6);
    rx.ExternalAttenuation = -10; % Set DSA Attenuation In Rx Front-Ends
    swv1 = dsp.SineWave(amplitude, basebandFreq);
    swv1.ComplexOutput = true;
    swv1.SampleRate = fs_RxIQ;
    swv1.SamplesPerFrame = samplesPerFrame;
    y1 = swv1();
    tx(ones(swv1.SamplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveform

    pause(1);
    data = rx(); % Grab the Rx Data & Save to 'data' Matrix
    for chanNum=2:1:rx.num_data_channels
        figure(pllCalFigureHandle);
        subplot(2,4,7);
        % Compute Cross Correlation With Rx0 Being The Reference
        corrValue = real(xcorr(data(:,1),data(:,chanNum)))./max((abs(xcorr(data(:,1),data(:,chanNum)))));
        if (rx.EnableResampleFilters)
            plot(linspace(-rx.SamplesPerFrame/2,rx.SamplesPerFrame/2,rx.SamplesPerFrame-1),corrValue);
        else
            plot(linspace(-rx.SamplesPerFrame,rx.SamplesPerFrame,2*rx.SamplesPerFrame-1),corrValue);
        end
        xlabel('Sample Number');
        ylabel('Normalized Cross-Correlation');
        xlim([-2^12 2^12]);
        grid on;
        hold on;

    end
    hold off;
    drawnow;

    subplot(2,4,3);
    plot(real(data));
    hold on;
    plot(imag(data));
    hold off;
    ylim([-32768 32768]);
    yticks(linspace(-2^15, 2^15, 11));
    yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
    xlabel('Sample Number');
    ylabel('ADC Code');
    xlim([0 2^12]);
    grid on;
    title('After Rx Calibration');

    %% FFT Processing
    pause(1);            
    data = rx();
    if (rx.EnableResampleFilters)
        hanningWindow = hanning(rx.SamplesPerFrame/2);
    else
        hanningWindow = hanning(rx.SamplesPerFrame);
    end
    hanNoiseEqBw = enbw(hanningWindow);
    scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;

    combinedComplexData = 0;
    for chanNum=1:1:rx.num_data_channels
        complexData1 = (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)))./scalingFactor;
        windowedData1 = complexData1' .* (hanningWindow');
        fftComplex1 = fft(windowedData1);
        fftComplexShifted1 = fftshift(fftComplex1);
        fftMags1 = abs(fftComplexShifted1);
        fftMagsdB1 = 20 * log10(fftMags1);
        if (rx.EnableResampleFilters)
            freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
        else
            freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
        end

        subplot(2,4,4);
        plot(freqAxis1, fftMagsdB1)
        grid on;
        hold on;
        xlabel('Frequency (MHz)','FontSize',8);
        ylabel('Amplitude (dBFS)','FontSize',8);
        if (rx.EnableResampleFilters)
            axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
        else
            axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
        end

        combinedComplexData = combinedComplexData + (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)));
    end
    title('Individual Channel Rx Spectrum');
    hold off;

    alignedRxPhases = ...
        [rx.MainNCOPhasesChipA; rx.MainNCOPhasesChipB;...
        rx.MainNCOPhasesChipC; rx.MainNCOPhasesChipD]./1e3

    %% Plot Combined Rx
    scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15*2^4; %Extra 2^4 due to bit growth from combined 16-channels
    combinedComplexData = combinedComplexData./scalingFactor;
    windowedData1 = combinedComplexData' .* (hanningWindow');
    fftComplex1 = fft(windowedData1);
    fftComplexShifted1 = fftshift(fftComplex1);
    fftMags1 = abs(fftComplexShifted1);
    fftMagsdB1 = 20 * log10(fftMags1);
    if (rx.EnableResampleFilters)
        freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
    else
        freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
    end
    subplot(2,4,8);
    plot(freqAxis1, fftMagsdB1)
    grid on;
    xlabel('Frequency (MHz)','FontSize',8);
    ylabel('Amplitude (dBFS)','FontSize',8);
    title('Combined 16-Channel Rx Spectrum');
    if (rx.EnableResampleFilters)
        axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
    else
        axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
    end
    drawnow;

    %% Now Configure Calibration Board For Adjacent Loopback
    if (useCalibrationBoard)
        %% Change data to be a bit backed off in amplitude
        % Now test with single frequency
        % Ensure Integer Periods To Make Waveform Cycling Contiguous
        if (basebandFreq ~= 0)
            samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
            samplesPerFrameCheck = samplesPerFrame;
            while rem(samplesPerFrameCheck,1)~=0
                samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
            end
            samplesPerFrame = samplesPerFrameCheck;
            while (samplesPerFrame > 2^12) % Max is 8k samples
                if (periods>1)
                    periods = periods - 1;
                    samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
                    samplesPerFrameCheck = samplesPerFrame;
                    while rem(samplesPerFrameCheck,1)~=0
                        samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
                    end
                    samplesPerFrame = samplesPerFrameCheck;
                else
                    basebandFreq = 0e6;
                    samplesPerFrame = 2^12; %Max is 8k samples
                end
            end    
        else
            samplesPerFrame = 2^12; %Max is 8k samples
        end
        while (samplesPerFrame < 32) %Need minimum of 32 samples
            periods = periods*2;
            samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
            samplesPerFrameCheck = samplesPerFrame;
            while rem(samplesPerFrameCheck,1)~=0
                samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
            end
            samplesPerFrame = samplesPerFrameCheck;
        end
        amplitude = 2^15*db2mag(-18);
        swv1 = dsp.SineWave(amplitude, basebandFreq);
        swv1.ComplexOutput = true;
        swv1.SampleRate = fs_RxIQ;
        swv1.SamplesPerFrame = samplesPerFrame;
        y1 = swv1();
        tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveform
        
        %% Work on cal board
        CalibrationBoard.ConfigureAdjacentIndividualLoopback(tx); % Set Calibration Board For Adjacent Loopback
        rx.ExternalAttenuation = -15; % Set DSA Attenuation For All Rx Front-Ends
        data = rx(); % Grab Rx Data & Save To 'data' Matrix

        adjacentLoopbackFigureHandle = figure('Name','Adjacent Loopback Performance','Position',graphicsInfo.ScreenSize);
        % Plot Cross-Correlation
        for chanNum=1:1:rx.num_data_channels
            subplot(2,2,3);
            corrValue = real(xcorr(data(:,rx.num_data_channels),data(:,chanNum)))./max((abs(xcorr(data(:,rx.num_data_channels),data(:,chanNum)))));
            if (rx.EnableResampleFilters)
                plot(linspace(-rx.SamplesPerFrame/2,rx.SamplesPerFrame/2,rx.SamplesPerFrame-1),corrValue);
            else
                plot(linspace(-rx.SamplesPerFrame,rx.SamplesPerFrame,2*rx.SamplesPerFrame-1),corrValue);
            end
            xlabel('Sample Number');
            xlim([-200 200]);
            ylabel('Normalized Cross-Correlation');
            grid on;
            hold on;
        end
        hold off;

        % Plot Real Part Of Captured Rx Data
        subplot(2,2,1);
        plot(real(data(1:400,:)));
        ylim([-32768 32768]);
        yticks(linspace(-2^15, 2^15, 11));
        yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
        xlabel('Sample Number');
        ylabel('ADC Code');
        grid on;
        title('After Rx Calibration With Adjacent Loopback');

        if (rx.EnableResampleFilters)
            hanningWindow = hanning(rx.SamplesPerFrame/2);
        else
            hanningWindow = hanning(rx.SamplesPerFrame);
        end
        hanNoiseEqBw = enbw(hanningWindow);
        scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;

        % Compute FFT
        combinedComplexData = 0;
        for chanNum=1:1:rx.num_data_channels
            complexData1 = (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)))./scalingFactor;
            windowedData1 = complexData1' .* (hanningWindow');
            fftComplex1 = fft(windowedData1);
            fftComplexShifted1 = fftshift(fftComplex1);
            fftMags1 = abs(fftComplexShifted1);
            fftMagsdB1 = 20 * log10(fftMags1);
            if (rx.EnableResampleFilters)
                freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
            else
                freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
            end

            % Plot FFT
            subplot(2,2,4);
            plot(freqAxis1, fftMagsdB1)
            grid on;
            hold on;
            xlabel('Frequency (MHz)','FontSize',8);
            ylabel('Amplitude (dBFS)','FontSize',8);
            if (rx.EnableResampleFilters)
                axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
            else
                axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
            end

            combinedComplexData = combinedComplexData + (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)));
        end
        title('Individual Channel Rx Spectrum');
        hold off;    
        txPlusRxPhaseOffsets = unwrap((angle(data(1,:)) - angle(data(1,rx.num_data_channels))))*180/pi;
        % Plot Phase Error Relative To Rx0 on MxFE0
        subplot(2,2,2);
        scatter(linspace(1,rx.num_data_channels,rx.num_data_channels),txPlusRxPhaseOffsets,'filled');
        xlabel('Rx Channel');
        ylabel('Phase Error [^o]');
        title('Calibration Board Phase Error');
        grid on;
        ylim([-180 180]);
        xticks([2 4 6 8 10 12 14 16]);
        yticks([-180 -150 -120 -90 -60 -30 0 30 60 90 120 150 180]);
        drawnow;
    end

    %% Now Turn Everything On
    if (powerAllAfterAlignment==1)
        if (useCalibrationBoard)
            CalibrationBoard.ConfigureCombinedLoopback(tx);
        end
        % First test with wideband chirp
        amplitude = 2^15*db2mag(-6);
        phaseRadians = 0*pi/180;
        ADC_full_scale = 2^15;
        T = 1/fs_RxIQ;
        chirpBW = fs_RxIQ*1.0;
        basebandFreqChirp = 0;
        NumPoints = samplesPerFrame;
        ActualToneOffset = round(NumPoints.*(basebandFreqChirp./fs_RxIQ)).*(fs_RxIQ./NumPoints);
        endTime = T*NumPoints-T;
        tau = T*samplesPerFrame;  %pulse width
        t = -endTime/2:T:endTime/2;
        y1 = amplitude.*...
            exp(1j*(2*pi*(ActualToneOffset + chirpBW/(2*tau).*t).*t + phaseRadians));
        tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1'); %Output Tx Waveform

        rx.ExternalAttenuation = -10;
        data = rx();
        [minVal, minLoc] = min(abs(data)); % Determine Minimum Envelope
        dataCircShiftedUncalibrated = circshift(data, -minLoc(1));        
        combinedLoopbackFigureHandle = figure('Name','Combined Loopback Performance','Position',graphicsInfo.ScreenSize);
        subplot(3,2,1);
        plot(real(dataCircShiftedUncalibrated));
        hold on;
        plot(imag(dataCircShiftedUncalibrated));
        hold off;
        ylim([-32768 32768]);
        xlabel('Sample Number');
        ylabel('ADC Code');
        grid on;
        title('Wideband Calibration Results');

        if (rx.EnableResampleFilters)
            hanningWindow = hanning(rx.SamplesPerFrame/2);
        else
            hanningWindow = hanning(rx.SamplesPerFrame);
        end
        hanNoiseEqBw = enbw(hanningWindow);
        scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;

        combinedComplexData = 0;
        for chanNum=1:1:rx.num_data_channels
            complexData1 = (real(dataCircShiftedUncalibrated(:,chanNum)) + sqrt(-1).*imag(dataCircShiftedUncalibrated(:,chanNum)))./scalingFactor;
            windowedData1 = complexData1' .* (hanningWindow');
            fftComplex1 = fft(windowedData1);
            fftComplexShifted1 = fftshift(fftComplex1);
            fftMags1 = abs(fftComplexShifted1);
            fftMagsdB1 = 20 * log10(fftMags1);
            if (rx.EnableResampleFilters)
                freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
            else
                freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
            end

            subplot(3,2,3);
            plot(freqAxis1, fftMagsdB1)
            grid on;
            hold on;
            xlabel('Frequency (MHz)');
            ylabel('Amplitude (dBFS)');
            if (rx.EnableResampleFilters)
                axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
            else
                axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
            end

            combinedComplexData = combinedComplexData + (real(dataCircShiftedUncalibrated(:,chanNum)) + sqrt(-1).*imag(dataCircShiftedUncalibrated(:,chanNum)));
        end
        title('Individual Channel Rx Windowed Spectrum');
        hold off;

        % Plot Combined Rx
        scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15*2^4; %Extra 2^4 due to bit growth from combined 16-channels
        combinedComplexData = combinedComplexData./scalingFactor;
        windowedData1 = combinedComplexData' .* (hanningWindow');
        fftComplex1 = fft(windowedData1);
        fftComplexShifted1 = fftshift(fftComplex1);
        fftMags1 = abs(fftComplexShifted1);
        fftMagsdB1 = 20 * log10(fftMags1);
        if (rx.EnableResampleFilters)
            freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
        else
            freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
        end
        subplot(3,2,5);
        plot(freqAxis1, fftMagsdB1)
        grid on;
        xlabel('Frequency (MHz)');
        ylabel('Amplitude (dBFS)');
        title('Combined 16-Channel Rx Windowed Spectrum');
        if (rx.EnableResampleFilters)
            axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
        else
            axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
        end

        % Now test with single frequency
        % Ensure Integer Periods To Make Waveform Cycling Contiguous
        if (basebandFreq ~= 0)
            samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
            samplesPerFrameCheck = samplesPerFrame;
            while rem(samplesPerFrameCheck,1)~=0
                samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
            end
            samplesPerFrame = samplesPerFrameCheck;
            while (samplesPerFrame > 2^12) % Max is 8k samples
                if (periods>1)
                    periods = periods - 1;
                    samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
                    samplesPerFrameCheck = samplesPerFrame;
                    while rem(samplesPerFrameCheck,1)~=0
                        samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
                    end
                    samplesPerFrame = samplesPerFrameCheck;
                else
                    basebandFreq = 0e6;
                    samplesPerFrame = 2^12; %Max is 8k samples
                end
            end    
        else
            samplesPerFrame = 2^12; %Max is 8k samples
        end
        while (samplesPerFrame < 32) %Need minimum of 32 samples
            periods = periods*2;
            samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
            samplesPerFrameCheck = samplesPerFrame;
            while rem(samplesPerFrameCheck,1)~=0
                samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
            end
            samplesPerFrame = samplesPerFrameCheck;
        end
        amplitude = 2^15*db2mag(-9);
        swv1 = dsp.SineWave(amplitude, basebandFreq);
        swv1.ComplexOutput = true;
        swv1.SampleRate = fs_RxIQ;
        swv1.SamplesPerFrame = samplesPerFrame;
        y1 = swv1();
        tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveform

        rx.ExternalAttenuation = -7;
        data = rx();
        subplot(3,2,2);
        plot(real(data));
        hold on;
        plot(imag(data));
        hold off;
        ylim([-32768 32768]);
        xlabel('Sample Number');
        ylabel('ADC Code');
        grid on;
        title('Single-Frequency Calibration Results');

        if (rx.EnableResampleFilters)
            hanningWindow = hanning(rx.SamplesPerFrame/2);
        else
            hanningWindow = hanning(rx.SamplesPerFrame);
        end
        hanNoiseEqBw = enbw(hanningWindow);
        scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;

        combinedComplexData = 0;
        for chanNum=1:1:rx.num_data_channels
            complexData1 = (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)))./scalingFactor;
            windowedData1 = complexData1' .* (hanningWindow');
            fftComplex1 = fft(windowedData1);
            fftComplexShifted1 = fftshift(fftComplex1);
            fftMags1 = abs(fftComplexShifted1);
            fftMagsdB1 = 20 * log10(fftMags1);
            if (rx.EnableResampleFilters)
                freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
            else
                freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
            end

            subplot(3,2,4);
            plot(freqAxis1, fftMagsdB1)
            grid on;
            hold on;
            xlabel('Frequency (MHz)');
            ylabel('Amplitude (dBFS)');
            if (rx.EnableResampleFilters)
                axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
            else
                axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
            end

            combinedComplexData = combinedComplexData + (real(data(:,chanNum)) + sqrt(-1).*imag(data(:,chanNum)));
        end
        title('Individual Channel Rx Windowed Spectrum');
        hold off;

        %% Plot Combined Rx
        scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15*2^4; %Extra 2^4 due to bit growth from combined 16-channels
        combinedComplexData = combinedComplexData./scalingFactor;
        windowedData1 = combinedComplexData' .* (hanningWindow');
        fftComplex1 = fft(windowedData1);
        fftComplexShifted1 = fftshift(fftComplex1);
        fftMags1 = abs(fftComplexShifted1);
        fftMagsdB1 = 20 * log10(fftMags1);
        if (rx.EnableResampleFilters)
            freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
        else
            freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
        end
        subplot(3,2,6);
        plot(freqAxis1, fftMagsdB1)
        grid on;
        xlabel('Frequency (MHz)');
        ylabel('Amplitude (dBFS)');
        title('Combined 16-Channel Rx Windowed Spectrum');
        if (rx.EnableResampleFilters)
            axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -120, 0]);
        else
            axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -120, 0]);
        end
    end
end

%% Check How New Phases Compare To MCS Old Phases
tx.setRegister(hex2dec('00'),'B5',tx.iioDev0);
sysref_Phase0 = tx.getRegister('B6',tx.iioDev0);
sysref_Phase0 = sysref_Phase0 + 2^9*tx.getRegister('B5',tx.iioDev0); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev1);
sysref_Phase1 = tx.getRegister('B6',tx.iioDev1);
sysref_Phase1 = sysref_Phase1 + 2^9*tx.getRegister('B5',tx.iioDev1); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev2);
sysref_Phase2 = tx.getRegister('B6',tx.iioDev2);
sysref_Phase2 = sysref_Phase2 + 2^9*tx.getRegister('B5',tx.iioDev2); %Monitor SYSREF Phase
tx.setRegister(hex2dec('00'),'B5',tx.iioDev3);
sysref_Phase3 = tx.getRegister('B6',tx.iioDev3);
sysref_Phase3 = sysref_Phase3 + 2^9*tx.getRegister('B5',tx.iioDev3); %Monitor SYSREF Phase   
sysrefPhasesAfterSystemCal = [sysref_Phase0, sysref_Phase1, sysref_Phase2, sysref_Phase3]
nowTime = datetime('now');
fileName = sprintf([num2str(carrierFreq/1e9) 'GHz_AlignADF4371s_' num2str(Align_ADF4371s) '_AlignPLLRxs_' num2str(Align_PLL_Using_Rx) '_' num2str(basebandFreq/1e6) 'MHzOffset_' num2str(nowTime.Hour) '_' num2str(nowTime.Minute) '_' num2str(round(nowTime.Second)) '__' num2str(nowTime.Month) '_' num2str(nowTime.Day) '_' num2str(nowTime.Year) '.mat']);
% Save The Alignment & Runtime Results To A .mat File
save(fileName,'alignedRxPhases','alignedTxPhases','adf4371_temp',...
    'mxfe_temp','PLL_phaseAdjust','sysrefPhasesAfterSync',...
    'sysrefPhasesAfterBaselineCapture','sysrefPhasesAfterSystemCal',...
    'numTimesForOneShotSync');

% Save New Alignment Results To New Variables
alignedRxPhasesNew = alignedRxPhases;
alignedTxPhasesNew = alignedTxPhases;
adf4371_tempNew = adf4371_temp;
mxfe_tempNew = mxfe_temp;
PLL_phaseAdjustNew = PLL_phaseAdjust;
sysrefPhasesAfterSyncNew = sysrefPhasesAfterSync;
sysrefPhasesAfterBaselineCaptureNew = sysrefPhasesAfterBaselineCapture;
sysrefPhasesAfterSystemCalNew = sysrefPhasesAfterSystemCal;
numTimesForOneShotSyncNew = numTimesForOneShotSync;

% Search In Particular '.\Baseline Files Using ADF4371 Phase Adjustment\
% Align Using Tx\' Directory For Baseline Files (Must Be Populated By
% User Using Original File Saved Above) - Use Baseline As Comparison To New
if (Align_ADF4371s==1)
    startString = 'Baseline Files Using ADF4371 Phase Adjustment\';
    if (Align_PLL_Using_Rx==1)
        startString = [startString 'Align Using Rx\'];
    else
        startString = [startString 'Align Using Tx\'];
    end
else
    startString = 'Baseline Files Not Using ADF4371 Phase Adjustment\';
end
stringToUseForMat = [startString num2str(carrierFreq/1e9) 'GHz*.mat'];
fileForMat = dir(stringToUseForMat);
if ~isempty(fileForMat)
    fileNameForMat = [startString fileForMat.name];
    load(fileNameForMat); %This overwrites alignedRxPhases/alignedTxPhases
end

% Plot Baseline Vs. New Phase Offset Comparison For Given Thermal Gradient
MCSFigureHandle = figure('Name','Multi Chip Sync Performance','Position',graphicsInfo.ScreenSize);
subplot(1,4,1);
plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhasesNew(1,:),'Color','r','LineStyle','none','Marker','.','MarkerSize',14);
hold on;
plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhasesNew(2,:),'Color','b','LineStyle','none','Marker','.','MarkerSize',14);
plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhasesNew(3,:),'Color','g','LineStyle','none','Marker','.','MarkerSize',14);
plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhasesNew(4,:),'Color','k','LineStyle','none','Marker','.','MarkerSize',14);
if ~isempty(fileForMat)
    plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhases(1,1:rx.num_fine_attr_channels),'ro');
    plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhases(2,1:rx.num_fine_attr_channels),'bo');
    plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhases(3,1:rx.num_fine_attr_channels),'go');
    plot(linspace(0,rx.num_fine_attr_channels-1,rx.num_fine_attr_channels),alignedRxPhases(4,1:rx.num_fine_attr_channels),'ko');
end
hold off;
xlabel('Coarse Rx DDC');
xticks(linspace(0,3,4));
xticklabels({'0','1','2','3'});
xlim([0 rx.num_fine_attr_channels-1])
ylabel('Calibrated Rx Phase Offset');
ylim([-180 180]);
yticks(linspace(-180,180,37));
title('New Phase Rx Comparison To MCS Boot-Up Phase');
grid on;
legend('MxFE0','MxFE1','MxFE2','MxFE3','Orientation','Vertical','FontSize',8);
subplot(1,4,2);
plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhasesNew(1,:),'Color','r','LineStyle','none','Marker','.','MarkerSize',14);
hold on;
plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhasesNew(2,:),'Color','b','LineStyle','none','Marker','.','MarkerSize',14);
plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhasesNew(3,:),'Color','g','LineStyle','none','Marker','.','MarkerSize',14);
plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhasesNew(4,:),'Color','k','LineStyle','none','Marker','.','MarkerSize',14);
if ~isempty(fileForMat)
    plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhases(1,1:tx.num_fine_attr_channels),'ro');
    plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhases(2,1:tx.num_fine_attr_channels),'bo');
    plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhases(3,1:tx.num_fine_attr_channels),'go');
    plot(linspace(0,tx.num_fine_attr_channels-1,tx.num_fine_attr_channels),alignedTxPhases(4,1:tx.num_fine_attr_channels),'ko');
end
hold off;
xlabel('Fine Tx DUC');
xticks(linspace(0,7,8));
xticklabels({'0','1','2','3','4','5','6','7'});
xlim([0 tx.num_fine_attr_channels-1]);
ylabel('Calibrated Tx Phase Offset');
ylim([-180 180]);
yticks(linspace(-180,180,37));
title('New Phase Tx Comparison To MCS Boot-Up Phase');
grid on;
legend('MxFE0','MxFE1','MxFE2','MxFE3','Orientation','Vertical','FontSize',8);
subplot(1,4,3);
yyaxis('left');
plot(linspace(0,3,4),adf4371_tempNew);
hold on;
plot(linspace(0,3,4),mxfe_tempNew);
hold off;
grid on;
ylim([50 122]);
xticks(linspace(0,3,4));
yticks(linspace(50,122,37));
xlabel('ADF4371/AD9081 #');
ylabel('ADF4371/AD9081 Temperature [^oC]');
yyaxis('right');
plot(linspace(0,3,4),PLL_phaseAdjustNew);
legend('ADF4371 Temp','AD9081 Temp','ADF4371 Phase');
ylim([0 720]);
ylabel('ADF4371 Phase Increment [^o]');
yticks(linspace(0,720,37));
grid on;
title(['Measured ADF4371 Thermal Gradient, f_{carrier}=' num2str(carrierFreq/1e9) 'GHz']);
drawnow;
subplot(1,4,4);
plot(linspace(0,3,4),sysrefPhasesAfterSyncNew,'bo','MarkerSize',8);
hold on;
plot(linspace(0,3,4),sysrefPhasesAfterBaselineCaptureNew,'ro','MarkerSize',9)
plot(linspace(0,3,4),sysrefPhasesAfterSystemCalNew,'go');
hold off;
grid on;
xlabel('MxFE Number');
xticks(linspace(0,3,4));
ylabel('Sysref Phase [DAC Clock Cycles]');
title(['SYSREF Phase During Execution, #1-Shot Syncs=' num2str(numTimesForOneShotSyncNew)]);
legend('After Sync','After Rx Baseline Capture','After System Cal','Orientation','Vertical');

if (useCalibrationBoard)
    LTC5596_voltage = CalibrationBoard.QueryLTC5596_voltage(tx);
end

release(rx);
if (useCalibrationBoard)
    CalibrationBoard.ConfigureTxOutToSMA(tx);
end