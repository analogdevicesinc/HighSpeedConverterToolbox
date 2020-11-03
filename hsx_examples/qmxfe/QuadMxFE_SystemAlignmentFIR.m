%% QuadMxFE_SystemAlignmentFIR.m
% Description: This script is to be used with the Analog Devices Quad-MxFE
% Platform to demonstrate MATLAB control of the system. It allows the user
% to configure the Tx and Rx aspects of the system and then load in
% transmit waveforms and capture receive data for all channels on the
% system. The script uses the on-system DSP blocks to align the device
% clocks, and output/input RF channels using the NCO phase offsets and
% programmable finitie impulse response (pFIR) filters. It provides an
% example of how to use pFIRs with the system to obtain channel
% equalization and gain flatness.

% Author: Mike Jones
% Date: 10/27/2020

% This script requires the use of the Analog Devices, Inc. High
% Speed Converter Toolbox.

% Gain Access to the Analog Devices, Inc. High Speed Converter Toolbox at:
% https://github.com/analogdevicesinc/HighSpeedConverterToolbox

instrreset;
%% Reload FPGA Code
% LoadVcu118Code('C:\Xilinx\Vivado_Lab\2019.2\bin\xsdb.bat',...
%     'C:\SDG Builds\Quad MxFE for VCU118 2020-09-25\run.vcu118_quad_ad9081_204c_txmode_11_rxmode_4.tcl')

%% Setup Parameters
close all;
clearvars;
graphicsInfo = groot;

uri = 'ip:192.168.2.1';
fs_Rx = 4000e6; %ADC Sample Rate [Hz]
fs_RxIQ = 250e6; %Rx Decimated IQ Sample Rate [Hz]
carrierFreq=3.2e9; %Tx NCO Frequency & Unfolded Rx NCO Frequency [Hz]
amplitude = 2^15*db2mag(-6); %Tx Baseband Amplitude [dBFS]
basebandFreq = 1.953125e6; %Baseband Frequency Used For Intermediate Results [Hz]
plotResults = 1; %0: Do not plot intermediate results, 1: Plot intermediate results
Align_ADF4371s = 1; %0: Do not align the ADF4371s, 1: Do align the ADF4371s
Align_PLL_Using_Rx = 0; %0: Use Tx alignment for PLL alignment, 1: Use Rx alignment for PLL alignment
minCodeValue = 500; %Lowest Acceptaple ADC Code Value. Anything Lower Is Regarded As a 'Bad' Capture [arb]
useCalibrationBoard = 1; %0: Not using calibration board, 1: Using calibration board

%% Setup Tx Information
system(['iio_attr -u ' uri ' -D axi-ad9081-rx-0 dac-full-scale-current-ua 40000']);
system(['iio_attr -u ' uri ' -D axi-ad9081-rx-1 dac-full-scale-current-ua 40000']);
system(['iio_attr -u ' uri ' -D axi-ad9081-rx-2 dac-full-scale-current-ua 40000']);
system(['iio_attr -u ' uri ' -D axi-ad9081-rx-3 dac-full-scale-current-ua 40000']);
%         tx.setDebugAttributeLongLong('dac-full-scale-current-ua',40000,tx.iioDev0);
%         tx.setDebugAttributeLongLong('dac-full-scale-current-ua',40000,tx.iioDev1);
%         tx.setDebugAttributeLongLong('dac-full-scale-current-ua',40000,tx.iioDev2);
%         tx.setDebugAttributeLongLong('dac-full-scale-current-ua',40000,tx.iioDev3);
tx = adi.QuadMxFE.Tx;
tx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
tx.uri = uri;
tx.num_coarse_attr_channels = 4; %Number of Coarse DUCs Used Per MxFE
tx.num_fine_attr_channels = 8; %Number of Fine DUCs Used Per MxFE
tx.num_data_channels = 4*tx.num_fine_attr_channels; %Total Number of Fine DUCs Used In System        
tx.num_dds_channels = tx.num_data_channels*4; %Total Number of DDSs Used In System (Not Used For 'DMA' Mode)
tx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,...
    17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; %Enabled Tx Channels, Only Needed for DMA
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
tx(channelArray'); %Output Tx Waveforms
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
rx.num_fine_attr_channels = 4; %Number of Fine DDCs Used Per MxFE
rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
rx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]; %Enabled Rx Channels
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
rx.EnablePFIRsChipA = true; %MxFE0 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipB = true; %MxFE1 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipC = true; %MxFE2 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipD = true; %MxFE3 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.PFIRFilenamesChipA = 'disabled.cfg';  %MxFE0 pFIR File
rx.PFIRFilenamesChipB = 'disabled.cfg';  %MxFE1 pFIR File
rx.PFIRFilenamesChipC = 'disabled.cfg';  %MxFE2 pFIR File
rx.PFIRFilenamesChipD = 'disabled.cfg';  %MxFE3 pFIR File
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
    subplot(2,2,1);
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
        subplot(2,2,3);
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
    % To Match Rx0 or Tx0 Of Each MxFE
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
        subplot(2,2,2);
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
            subplot(2,2,4);
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
    figure('Name','Tx Calibration','Position',graphicsInfo.ScreenSize);
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

    %% Observe Tx-Aligned Results
    data = rx();
    % Now Find The Pulse Corresponding To Tx0
    if (abs(real(data(1,1)))>500 || abs(imag(data(1,1)))>500 || ...
            abs(real(data(50,1)))>500 || abs(imag(data(50,1)))>500) %Check if signal is present at start of capture
        [separation,initialCross,finalCross,nextCross,midLev] = ...
            pulsesep(double(abs(real(data(:,1)))>500)); 
        [maxVal, maxLoc] = max(separation);
        channel0Start = ceil(nextCross(maxLoc)); %The Tx0 Pulse Location
    else %Correct If Signal Is Aero At Start Of Capture
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
    title('Data After Tx Calibration');            
end   

samplesPerFrame = 4096; % Number of ADC Samples To Capture
NumPoints = samplesPerFrame; % Number of Points Per Frame
frequencies = linspace(0,fs_Rx,length(channelArray)*fs_Rx/fs_RxIQ); % pFIR Frequencies [Hz]
BPF_Bandwidth = fs_RxIQ/1; %Band-Pass Filter Bandwidth [Hz]
StartBand = (abs(carrierFreq-fs_Rx)-BPF_Bandwidth/2)/(fs_Rx/2); % Starting Decimated Frequency [Hz]
StopBand = (abs(carrierFreq-fs_Rx)+BPF_Bandwidth/2)/(fs_Rx/2); % Ending Decimated Frequency [Hz]
NumChannels = rx.num_data_channels; % Number of pFIR Channels To Design
numTaps = 96; % Number of Taps For Each pFIR Filter

if (useCalibrationBoard)
    CalibrationBoard.ConfigureCombinedLoopback(tx);
end

% Inject Wideband Chirp Into Tx Channels
amplitude = 2^15*db2mag(-6); % Chirp Amplitude [arb]
phaseRadians = 0*pi/180; % Chirp Baseline Phase [radians]
ADC_full_scale = 2^15; % ADC Full-Scale Value [arb]
T = 1/fs_RxIQ; % Decimated I/Q Period [s]
chirpBW = fs_RxIQ*1.0; % Chirp Bandwidth [Hz]
basebandFreqChirp = 0; % Center Chirp Frequency [Hz]
ActualToneOffset = round(NumPoints.*(basebandFreqChirp./fs_RxIQ)).*(fs_RxIQ./NumPoints); % Chirp Frequency Offset [Hz]
endTime = T*NumPoints-T; % End time [s]
tau = T*samplesPerFrame;  % Pulse Width [s]
t = -endTime/2:T:endTime/2; % Time Series
y1 = amplitude.*...
exp(1j*(2*pi*(ActualToneOffset + chirpBW/(2*tau).*t).*t + phaseRadians)); % Waveform For Each Tx Channel
tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1'); %Output Tx Waveforms

% % Now test with single frequency
% % Ensure Integer Periods To Make Waveform Cycling Contiguous
% if (basebandFreq ~= 0)
%     samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
%     samplesPerFrameCheck = samplesPerFrame;
%     while rem(samplesPerFrameCheck,1)~=0
%         samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
%     end
%     samplesPerFrame = samplesPerFrameCheck;
%     while (samplesPerFrame > 2^12) % Max is 8k samples
%         if (periods>1)
%             periods = periods - 1;
%             samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
%             samplesPerFrameCheck = samplesPerFrame;
%             while rem(samplesPerFrameCheck,1)~=0
%                 samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
%             end
%             samplesPerFrame = samplesPerFrameCheck;
%         else
%             basebandFreq = 0e6;
%             samplesPerFrame = 2^12; %Max is 8k samples
%         end
%     end    
% else
%     samplesPerFrame = 2^12; %Max is 8k samples
% end
% while (samplesPerFrame < 32) %Need minimum of 32 samples
%     periods = periods*2;
%     samplesPerFrame = (1/basebandFreq*fs_RxIQ*periods);
%     samplesPerFrameCheck = samplesPerFrame;
%     while rem(samplesPerFrameCheck,1)~=0
%         samplesPerFrameCheck = samplesPerFrameCheck + samplesPerFrame;
%     end
%     samplesPerFrame = samplesPerFrameCheck;
% end
% amplitude = 2^15*db2mag(-6);
% swv1 = dsp.SineWave(amplitude, basebandFreq);
% swv1.ComplexOutput = true;
% swv1.SampleRate = fs_RxIQ;
% swv1.SamplesPerFrame = samplesPerFrame;
% y1 = swv1();
% tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveform

% %% Create A Complex-Valued Noise Injection Source for Calibration
% initial = zeros(NumPoints,size(tx.EnabledChannels,2));
% input = 2^15*db2mag(-6).*awgn(initial,5)/sqrt(2);
% input = real(input) + 1j.*real(input);
% tx(input);

rx.ExternalAttenuation = -9; % On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]
dataUncalibrated = rx(); % Grab Rx Uncalibrated Data & Save To Complex Matrix

[minVal, minLoc] = min(abs(dataUncalibrated)); % Determine Minimum Envelope
dataCircShiftedUncalibrated = circshift(dataUncalibrated, -minLoc(1));

spectrumUnequalizedOut = fftshift(fft(dataCircShiftedUncalibrated,[],1));
spectrumUnequalizedOutMagsdB = 20.*log10(sqrt(abs(spectrumUnequalizedOut))./ADC_full_scale);
spectrumUnequalizedOutPhase = angle(spectrumUnequalizedOut);

if (rx.EnableResampleFilters)
    hanningWindow = hanning(rx.SamplesPerFrame/2);
else
    hanningWindow = hanning(rx.SamplesPerFrame);
end
hanNoiseEqBw = enbw(hanningWindow);
scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15; % Scale To Get Into dBFS

if (rx.EnableResampleFilters)
    freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(spectrumUnequalizedOutMagsdB));
else
    freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(spectrumUnequalizedOutMagsdB));
end

combinedComplexData = 0; % Combined Rx Data
for chanNum=1:1:NumChannels
    combinedComplexData = combinedComplexData + (real(dataCircShiftedUncalibrated(:,chanNum)) + sqrt(-1).*imag(dataCircShiftedUncalibrated(:,chanNum)));
end
fftMagsdB1Error = spectrumUnequalizedOutMagsdB - spectrumUnequalizedOutMagsdB(:,1); % Magnitude Error With Respect To Rx0
fftUncalibratedPhaseError = wrapToPi(spectrumUnequalizedOutPhase - spectrumUnequalizedOutPhase(:,1)); % Phase Error With Respect To Rx0

%% Plot Uncalibrated System Response
systemPerformanceFigureHandle = figure('Name','System Performance Calibration','Position',graphicsInfo.ScreenSize);
subplot(2,4,1);
plot(real(dataCircShiftedUncalibrated(:,1:NumChannels)));
ylim([-32768 32768]);
yticks(linspace(-2^15, 2^15, 11));
yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
xlabel('Sample Number');
ylabel('ADC Code');
xlim([0 2^12]);
grid on;
title(['Before Rx Calibration, f_{carrier}=' num2str(carrierFreq/1e9) 'GHz']);
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

subplot(2,4,2);
plot(freqAxis1, spectrumUnequalizedOutMagsdB);
grid on;
xlabel('Frequency [MHz]');
ylabel('Amplitude [dBFS]');
if (rx.EnableResampleFilters)
    axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -60, 0]);
else
    axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -60, 0]);
end
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);
title('Uncalibrated Channel Rx Spectrum');

subplot(2,4,3);
plot(freqAxis1,fftMagsdB1Error);
ylim([-2 2]);
xlim([-(fs_RxIQ*0.8)/1e6/2 (fs_RxIQ*0.8)/1e6/2]);
grid on;
xlabel('Frequency [MHz]');
ylabel('Magnitude Error [dB]');
title('Uncalibrated Rx Amplitude Error');
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

subplot(2,4,4);
plot(freqAxis1,fftUncalibratedPhaseError*180/pi);
ylim([-180 180]);
xlim([-(fs_RxIQ*0.8)/1e6/2 (fs_RxIQ*0.8)/1e6/2]);
grid on;
xlabel('Frequency [MHz]');
ylabel('Phase Error [^o]');
title('Uncalibrated Rx Phase Error');
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);
drawnow;

%% Perform Rx Phase Calibration Using AD9081 NCO Phase Offsets
RxPhaseOffsets = angle(timeZeroAligned)*180/pi;
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
    misalignedPhaseRxChannels(chanNum,1) = RxPhaseOffsets(10,chanNum) - RxPhaseOffsets(10,1);    
    eval(['newMisalignedPhase(chanNum,1) = rx.' varNamePhase '(chanIndexOnMxFE) + misalignedPhaseRxChannels(chanNum,1)*1e3;'])
    if (newMisalignedPhase(chanNum,1)>180e3)
        newMisalignedPhase(chanNum,1) = -(360e3-newMisalignedPhase(chanNum,1));
    elseif (newMisalignedPhase(chanNum,1)<-180e3)
        newMisalignedPhase(chanNum,1) = 360e3+newMisalignedPhase(chanNum,1);
    end
    % Apply Rx NCO Phase Offsets
    eval(['rx.' varNamePhase '(chanIndexOnMxFE) = newMisalignedPhase(chanNum,1);']);
end
alignedRxPhases = ...
    [rx.MainNCOPhasesChipA; rx.MainNCOPhasesChipB;...
    rx.MainNCOPhasesChipC; rx.MainNCOPhasesChipD]./1e3;   

%% Grab Data For FIR Equalization Design
dataUncalibrated = rx(); % Grad Rx Data & Save to 'dataUncalibrated' Matrix

[minVal, minLoc] = min(abs(dataUncalibrated)); % Determine minimum envelop
dataCircShiftedUncalibrated = circshift(dataUncalibrated, -minLoc(1));
% scaleForFlat = (db2mag(-4)*2^15-1)./(abs(dataCircShiftedUncalibrated));

spectrumUnequalizedOut = fftshift(fft(dataCircShiftedUncalibrated,[],1));
spectrumUnequalizedOutMagsdB = 20.*log10(sqrt(abs(spectrumUnequalizedOut))./ADC_full_scale);
scaleForFlat = abs(spectrumUnequalizedOut)./max(abs(spectrumUnequalizedOut(:,1)));
% scaleForFlat = 1;

%% Calculate Amplitude And Phase Errors Across Channels In Frequency Domain
% Keep in mind that the equalizer pFIRs operate at the non-decimated, full
% Nyquist sample rate! The 'errorResponse' is good for the pass-band only!
errorResponse = spectrumUnequalizedOut./spectrumUnequalizedOut(:,1); %Error Response Within Decimation Passband
errorResponse = abs(1./scaleForFlat).*exp(1j.*unwrap(angle(errorResponse),2)); %Invert Amplitude
frequenciesForEqualizerF1 = linspace(0,StartBand*0.95,size(errorResponse,1)); %Outside Decimation Frequencies
frequenciesForEqualizerF2 = linspace(StartBand,StopBand,size(errorResponse,1)); %Inside Decimation Frequencies
frequenciesForEqualizerF3 = linspace(StopBand*1.05,1,size(errorResponse,1)); %Outside Decimation Frequencies
errorResponseF1 = ones(NumChannels,length(frequenciesForEqualizerF1)).*exp(-1j*pi*numTaps/2*frequenciesForEqualizerF1);
errorResponseF1(:,1) = 0;
errorResponseF2 = errorResponse'.*exp(-1j*pi*numTaps/2*frequenciesForEqualizerF2); %Force Group Delay To Middle Of FIR Design
errorResponseF3 = ones(NumChannels,length(frequenciesForEqualizerF3)).*exp(-1j*pi*numTaps/2*frequenciesForEqualizerF3);
errorResponseF3(:,end) = 0;

% Smooth Error Response & Only Look At Inner 80% Of Decimated I/Q Rate
for currentChannel=1:1:NumChannels
    errorResponseF2Smooth(currentChannel,:) = smooth(errorResponseF2(currentChannel,:)',0.0005)';
end
errorResponseF2SmoothInner = errorResponseF2Smooth(:,int16(0.1*length(frequenciesForEqualizerF2)):int16(0.9*length(frequenciesForEqualizerF2)));
frequenciesForEqualizerF2Inner = frequenciesForEqualizerF2(int16(0.1*length(frequenciesForEqualizerF2)):int16(0.9*length(frequenciesForEqualizerF2)));

% Plot Individual Rx Error Responses
figure('Name','Error Response','Position',graphicsInfo.ScreenSize);
for currentChannel=1:4:NumChannels
    mxFENum = floor((currentChannel-1)/4);
    subplot(2,4,(mxFENum+1)); plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, angle(errorResponseF2Smooth(currentChannel,:))*180/pi,'b'); grid on;
    hold on; plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, angle(errorResponseF2Smooth(currentChannel+1,:))*180/pi,'r');
    plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, angle(errorResponseF2Smooth(currentChannel+2,:))*180/pi,'g');
    plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, angle(errorResponseF2Smooth(currentChannel+3,:))*180/pi,'c'); hold off;
    ylim([-180 180]);
    xlabel('Frequency [GHz]');
    ylabel('Phase [^o]');
    title('Error Response MxFE0');
    legend('0','1','2','3');
    subplot(2,4,(mxFENum+1)+4); plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, 20*log10(abs(errorResponseF2Smooth(currentChannel,:))),'b'); grid on;
    hold on; plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, 20*log10(abs(errorResponseF2Smooth(currentChannel+1,:))),'r');
    plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, 20*log10(abs(errorResponseF2Smooth(currentChannel+2,:))),'g');
    plot(frequenciesForEqualizerF2.*(fs_Rx/2)/1e9, 20*log10(abs(errorResponseF2Smooth(currentChannel+3,:))),'c'); hold off;
    xlabel('Frequency [GHz]');
    ylabel('Amplitude [dB]'); 
end

%% Design FIR Filters For Each Channel
% W_Equalizer = 10.*hanning(size(errorResponseF2SmoothInner,2))';
% W_Equalizer = 100.*bartlett(size(errorResponseF2,2))';
W_Equalizer = 10;

for currentChannel=1:1:NumChannels
    fprintf(['Desiging FIR Filter for Channel ' num2str(currentChannel) '\n'])    
    designedEqualizerObject = fdesign.arbmagnphase('N,B,F,H',numTaps-1,3,...
        frequenciesForEqualizerF1,errorResponseF1(currentChannel,:),...
        frequenciesForEqualizerF2Inner,errorResponseF2SmoothInner(currentChannel,:),...
        frequenciesForEqualizerF3,errorResponseF3(currentChannel,:));
    filterOptions = designopts(designedEqualizerObject,'firls'); % 'firls' or 'equiripple'
    filterOptions.FilterStructure = 'dffir'; % FilterStructure = 'dffir', 'dffirt', 'dfsymfir', 'dfasymfir', or 'fftfir'
    filterOptions.B1Weights = 1;
    filterOptions.B2Weights = W_Equalizer; % More Heavily Weight Decimated I/Q Band
    filterOptions.B3Weights = 1;
    designedEqualizers(currentChannel,:) = design(designedEqualizerObject,filterOptions); % Design the pFIRs
    designedEqualizersTaps(currentChannel,:) = designedEqualizers(currentChannel,:).Numerator; % Save the Taps
    designedEqualizersTapsExtended(currentChannel,:) = [zeros(1,(96-numTaps)/2) designedEqualizersTaps(currentChannel,:) zeros(1,(96-numTaps)/2)]./sum(designedEqualizersTaps(currentChannel,:));
end
fvtool(designedEqualizers,'Analysis','freq','Fs',fs_Rx); % Plot Equalizer Response
legend;

%% Scale FIR & Determine Best Quantization Error For FIR Coefficients To Load Into MxFE
pfir = adi.sim.AD9081.PFIRDesigner;
pfir.Mode = 'DualReal';

for currentChannel=1:2:NumChannels
    filename{currentChannel,:} = ['QuadMxFE_DualReal_CH' num2str(currentChannel-1) 'and' num2str(currentChannel) '_' num2str(carrierFreq/1e9) 'GHz.cfg'];
    filename{currentChannel+1,:} = ['QuadMxFE_DualReal_CH' num2str(currentChannel-1) 'and' num2str(currentChannel) '_' num2str(carrierFreq/1e9) 'GHz.cfg'];
    pfir.OutputFilename = filename{currentChannel,:};

    % Find Best Tap Quantization For Given Filter
    [config1,tapsInt16_1,qt1,error1] = DesignPFilt(designedEqualizersTapsExtended(currentChannel,:),pfir.Mode,96);
    [config2,tapsInt16_2,qt2,error2] = DesignPFilt(designedEqualizersTapsExtended(currentChannel+1,:),pfir.Mode,96);

    % Update Model
    pfir.Gains = [0 0 0 0];
    pfir.Taps = [qt1; qt2];
    pfir.TapsWidthsPerQuad = [config1; config2];
    if any(currentChannel==[1,5,9,13])
        pfir.ADCTarget = 'adc_pair_0';
    else
        pfir.ADCTarget = 'adc_pair_1';
    end

    % Create Filter File
    pfir.ToFile();
    
    filterTaps(currentChannel,:) = pfir.Taps(1,:);
    filterTaps(currentChannel+1,:) = pfir.Taps(2,:);
    filterTapsInt16(currentChannel,:) = tapsInt16_1;
    filterTapsInt16(currentChannel+1,:) = tapsInt16_2;
    errorValues(currentChannel,:) = error1;
    errorValues(currentChannel+1,:) = error2;
    bitwidthConfig(currentChannel,:) = config1;
    bitwidthConfig(currentChannel+1,:) = config2;
end

% Plot pFIR Taps For All Rx Channels
figure('Name','Filter Taps','Position',graphicsInfo.ScreenSize);
for currentChannel=1:1:NumChannels
    subplot(4,4,currentChannel);
    stem(filterTaps(currentChannel,:)','r','filled');
    hold on;
    stem(filterTapsInt16(currentChannel,:)','b');
    hold off;
    legend('Quantized','OriginalInt16');
    grid on;
    xlabel('Tap Number [arb]');
    ylabel('Coefficient Value [arb]');
    ylim([-2^15 2^15]);
    xlim([0 length(filterTaps(currentChannel,:))]);
    title(['Desired Vs. Quantized Coefs, error= ' num2str(errorValues(currentChannel,:)) ', f=' num2str(carrierFreq/1e9) 'GHz']);
end

%% Apply A Chirp And See How The pFIRs Perform Through Calibration Board
if (useCalibrationBoard)
    CalibrationBoard.ConfigureCombinedLoopback(tx);
end

%% Load New pFIR Files Into Quad-MxFE Platform
for chanNum=1:4:NumChannels
    mxFENum = floor((chanNum-1)/4);
    if (mxFENum==0)
        rx.PFIRFilenamesChipA = {filename{1,:}, filename{3,:}};
    elseif (mxFENum==1)
        rx.PFIRFilenamesChipB = {filename{5,:}, filename{7,:}};
    elseif (mxFENum==2)
        rx.PFIRFilenamesChipC = {filename{9,:}, filename{11,:}};
    elseif (mxFENum==3)
        rx.PFIRFilenamesChipD = {filename{13,:}, filename{15,:}};
    end
end
pause(1);

%% Grab New Calibrated Rx Data
dataCalibrated = rx();

[minVal, minLoc] = min(abs(dataCalibrated)); % Determine Minimum Envelope
dataCircShiftedCalibrated = circshift(dataCalibrated, -minLoc(1));

spectrumEqualizedOut = fftshift(fft(dataCircShiftedCalibrated,[],1));
spectrumEqualizedOutMagsdB = 20.*log10(sqrt(abs(spectrumEqualizedOut))./ADC_full_scale);
spectrumEqualizedOutPhase = angle(spectrumEqualizedOut);

figure(systemPerformanceFigureHandle);
subplot(2,4,5);
plot(real(dataCircShiftedCalibrated(:,1:NumChannels)));
ylim([-32768 32768]);
yticks(linspace(-2^15, 2^15, 11));
yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
xlabel('Sample Number');
ylabel('ADC Code');
xlim([0 2^12]);
grid on;
title(['After Rx Calibration, f_{carrier}=' num2str(carrierFreq/1e9) 'GHz']);
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

if (rx.EnableResampleFilters)
    freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(spectrumEqualizedOutMagsdB));
else
    freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(spectrumEqualizedOutMagsdB));
end

combinedComplexData = 0;
for chanNum=1:1:NumChannels
    combinedComplexData = combinedComplexData + (real(dataCircShiftedCalibrated(:,chanNum)) + sqrt(-1).*imag(dataCircShiftedCalibrated(:,chanNum)));
end
fftMagsdB1CalibratedError = spectrumEqualizedOutMagsdB - spectrumEqualizedOutMagsdB(:,1);
fftCalibratedPhaseError = wrapToPi(spectrumEqualizedOutPhase - spectrumEqualizedOutPhase(:,1));

% Plot Calibrated Response
subplot(2,4,6);
plot(freqAxis1, spectrumEqualizedOutMagsdB);
grid on;
xlabel('Frequency [MHz]');
ylabel('Amplitude [dBFS]');
if (rx.EnableResampleFilters)
    axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -60, 0]);
else
    axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -60, 0]);
end
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);
title('Calibrated Channel Rx Spectrum');

subplot(2,4,7);
plot(freqAxis1,fftMagsdB1CalibratedError);
hold on;
ylim([-2 2]);
xlim([-(fs_RxIQ*0.8)/1e6/2 (fs_RxIQ*0.8)/1e6/2]);
grid on;
xlabel('Frequency [MHz]');
ylabel('Magnitude Error [dB]');
title('Calibrated Rx Amplitude Error');
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

subplot(2,4,8);
plot(freqAxis1,fftCalibratedPhaseError*180/pi);
ylim([-180 180]);
xlim([-(fs_RxIQ*0.8)/1e6/2 (fs_RxIQ*0.8)/1e6/2]);
grid on;
xlabel('Frequency [MHz]');
ylabel('Phase Error [^o]');
title('Calibrated Rx Phase Error');
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

%% Observe Combined Rx Channel Improvements
amplitude = 2^15*db2mag(-6);
swv1 = dsp.SineWave(amplitude, basebandFreq);
swv1.ComplexOutput = true;
swv1.SampleRate = fs_RxIQ;
swv1.SamplesPerFrame = samplesPerFrame;
y1 = swv1();
tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveform

rx.ExternalAttenuation = -8;  % On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]
dataSingleToneCalibrated = rx(); % Grad Rx Data & Save To Complex 'dataSingleToneCalibrated' Matrix
release(rx); % Release The Rx Handle Now That Program Is Mostly Done

spectrumEqualizedSingleToneOut = fftshift(fft(dataSingleToneCalibrated,[],1));
spectrumEqualizedSingleToneOutMagsdB = 20.*log10(sqrt(abs(spectrumEqualizedSingleToneOut))./ADC_full_scale);

% Plot Combined Improvement Results
figure('Name','Calibrated System','Position',graphicsInfo.ScreenSize);
subplot(1,3,1);
plot(real(dataSingleToneCalibrated(:,1:NumChannels)));
ylim([-32768 32768]);
yticks(linspace(-2^15, 2^15, 11));
yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
xlabel('Sample Number');
ylabel('ADC Code');
xlim([0 2^12]);
grid on;
title(['After Rx Calibration, f_{carrier}=' num2str(carrierFreq/1e9) 'GHz']);
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);

if (rx.EnableResampleFilters)
    hanningWindow = hanning(rx.SamplesPerFrame/2);
else
    hanningWindow = hanning(rx.SamplesPerFrame);
end
hanNoiseEqBw = enbw(hanningWindow);
scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;

if (rx.EnableResampleFilters)
    freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(spectrumEqualizedSingleToneOutMagsdB));
else
    freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(spectrumEqualizedSingleToneOutMagsdB));
end

combinedComplexDataSingleTone = 0;
for chanNum=1:1:NumChannels
    complexData1 = real(dataSingleToneCalibrated(:,chanNum)) + sqrt(-1).*imag(dataSingleToneCalibrated(:,chanNum));
    complexData1Scaled = complexData1./scalingFactor;
    windowedData1 = complexData1Scaled' .* (hanningWindow');
    fftComplex1 = fft(windowedData1);
    fftComplexShifted1 = fftshift(fftComplex1);
    fftMags1 = abs(fftComplexShifted1);
    fftMagsdB1Calibrated(chanNum,:) = 20 * log10(fftMags1);

    combinedComplexDataSingleTone = combinedComplexDataSingleTone + (real(complexData1) + sqrt(-1).*imag(complexData1));
end
subplot(1,3,2);
plot(freqAxis1, fftMagsdB1Calibrated);
grid on;
xlabel('Frequency (MHz)','FontSize',8);
ylabel('Amplitude (dBFS)','FontSize',8);
if (rx.EnableResampleFilters)
    axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -100, 0]);
else
    axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -100, 0]);
end
legend(num2str(linspace(0,15,16)'),'Location','EastOutside','FontSize',5);
title('Calibrated Channel Rx Spectrum');

scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^(15+sqrt(NumChannels)); %Bit Growth from Combining
complexDataCombined = (real(combinedComplexDataSingleTone) + sqrt(-1).*imag(combinedComplexDataSingleTone))./scalingFactor;
windowedDataCombined = complexDataCombined' .* (hanningWindow');
fftComplexCombined = fft(windowedDataCombined);
fftComplexShiftedCombined = fftshift(fftComplexCombined);
fftMagsCombined = abs(fftComplexShiftedCombined);
fftMagsdB1CalibratedCombined = 20 * log10(fftMagsCombined);
if (rx.EnableResampleFilters)
    freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1CalibratedCombined));
else
    freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1CalibratedCombined));
end

subplot(1,3,3);
plot(freqAxis1, fftMagsdB1CalibratedCombined);
grid on;
xlabel('Frequency (MHz)','FontSize',8);
ylabel('Amplitude (dBFS)','FontSize',8);
title('Calibrated Combined Channel Rx Spectrum');
if (rx.EnableResampleFilters)
    axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -100, 0]);
else
    axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -100, 0]);
end