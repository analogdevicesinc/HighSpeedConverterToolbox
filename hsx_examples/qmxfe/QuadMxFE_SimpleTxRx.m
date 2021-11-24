%% QuadMxFE_SimpleTxRx.m
% Description: This script is to be used with the Analog Devices Quad-MxFE
% Platform to demonstrate MATLAB control of the system. It allows the user
% to configure the Tx and Rx aspects of the system and then load in
% transmit waveforms and capture receive data for all channels on the
% system. This script requires the use of the Analog Devices, Inc. High
% Speed Converter Toolbox.
%
% Author: Chas Frick
% Date: 6/15/2021

% Gain Access to the Analog Devices, Inc. High Speed Converter Toolbox at:
% https://github.com/analogdevicesinc/HighSpeedConverterToolbox

instrreset;
%% Reload FPGA Code
% Make sure to program the FPGA using the following .tcl script for each
% variant. Supported use cases:
% ADQUADMXFE1EBZ = run.vcu118_quad_ad9081_204c_txmode_11_rxmode_4_revc.tcl
% ADQUADMXFE2EBZ = run.vcu118_quad_ad9081_204c_txmode_11_rxmode_4_revc_nz1.tcl
% ADQUADMXFE3EBZ = run.vcu118_quad_ad9082_204c_txmode_3_rxmode_2.tcl

% Example:
% LoadVcu118Code('C:\Xilinx\Vivado_Lab\2019.2\bin\xsdb.bat',...
%     'C:\SDG Builds\Quad MxFE for VCU118 2020-09-25\run.vcu118_quad_ad9081_204c_txmode_11_rxmode_4_revc.tcl')


%% Setup Parameters
close all;
clearvars;

% Select board variant number here
% 1 = ADQUADMXFE1EBZ, 2 = ADQUADMXFE2EBZ, 3 = ADQUADMXFE3EBZ
boardVariantNumber = 1;

uri = 'ip:192.168.2.1'; %Default IP Address To Connect To VCU118
fs_RxIQ = 250e6; %Rx Decimated IQ Sample Rate [Hz]
periods = 32; %Desired Number Of Periods For Tx Signal
basebandFreq = fs_RxIQ/8; %Baseband Frequency [Hz]
plotResults = 1; %0: Do not plot intermediate results, 1: Plot intermediate results
useCalibrationBoard = 1; %0: Not using calibration board, 1: Using calibration board

switch(boardVariantNumber)
    case 1
        amplitude = 2^15*db2mag(-20); %Tx Baseband Amplitude [dBFS]
        fs_Rx = 4000e6; %ADC Sample Rate [Hz]
        carrierFreq = 3.2e9; %Tx NCO Frequency & Unfolded Rx NCO Frequency [Hz]
    case 2
        amplitude = 2^15*db2mag(-20); %Tx Baseband Amplitude [dBFS]
        fs_Rx = 4000e6; %ADC Sample Rate [Hz]
        carrierFreq = 1.8e9; %Tx NCO Frequency & Rx NCO Frequency [Hz]
    case 3
        amplitude = 2^15*db2mag(-6); %Tx Baseband Amplitude [dBFS]
        fs_Rx = 6000e6; %ADC Sample Rate [Hz]
        carrierFreq = 3.2e9; %Tx NCO Frequency & Unfolded Rx NCO Frequency [Hz]
end


%% Setup Tx Configuration
tx = adi.QuadMxFE.Tx;
tx.UpdateDACFullScaleCurrent = true;
tx.DACFullScaleCurrentuA = 40000;

tx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
tx.uri = uri;

switch(boardVariantNumber)
    case {1,2}
        tx.num_coarse_attr_channels = 4; %Number of Coarse DUCs Used Per MxFE
        tx.num_fine_attr_channels = 8; %Number of Fine DUCs Used Per MxFE
        tx.num_data_channels = 4*tx.num_fine_attr_channels; %Total Number of Fine DUCs Used In System
        tx.num_dds_channels = tx.num_data_channels*4; %Total Number of DDSs Used In System (Not Used For 'DMA' Mode)
        tx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,...
            17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; %Enabled Tx Channels, Only Needed for DMA
        % 12-Bit Normalized Digital Gain Code (Valid Values 0 to 1)
        % 0<=Gain<=(2^12-1)/2^11=1.9995; Gain=GainCode/2048
        % Normalized Gain Code = GainCode/2
        tx.ChannelNCOGainScalesChipA  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE0 Digital Gain Code
        tx.ChannelNCOGainScalesChipB  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE1 Digital Gain Code
        tx.ChannelNCOGainScalesChipC  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE2 Digital Gain Code
        tx.ChannelNCOGainScalesChipD  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE3 Digital Gain Code
    case 3
        tx.num_coarse_attr_channels = 4; %Number of Coarse DUCs Used Per MxFE
        tx.num_fine_attr_channels = 4; %Number of Fine DUCs Used Per MxFE
        tx.num_data_channels = 4*tx.num_fine_attr_channels; %Total Number of Fine DUCs Used In System
        tx.num_dds_channels = tx.num_data_channels*4; %Total Number of DDSs Used In System (Not Used For 'DMA' Mode)
        tx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]; %Enabled Tx Channels, Only Needed for DMA
        % 12-Bit Normalized Digital Gain Code (Valid Values 0 to 1)
        % 0<=Gain<=(2^12-1)/2^11=1.9995; Gain=GainCode/2048
        % Normalized Gain Code = GainCode/2
        tx.ChannelNCOGainScalesChipA  = ones(1,tx.num_fine_attr_channels).*0.7; %MxFE0 Digital Gain Code
        tx.ChannelNCOGainScalesChipB  = ones(1,tx.num_fine_attr_channels).*0.7; %MxFE1 Digital Gain Code
        tx.ChannelNCOGainScalesChipC  = ones(1,tx.num_fine_attr_channels).*0.7; %MxFE2 Digital Gain Code
        tx.ChannelNCOGainScalesChipD  = ones(1,tx.num_fine_attr_channels).*0.7; %MxFE3 Digital Gain Code
end
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

%% Inject Single-Tone Waveform Into Each Tx Channel
% This Example Injects Same Waveform Into All Tx Channels, But Each
% Channel Can Have Separate Waveforms Injected Instead

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

swv1 = dsp.SineWave(amplitude, basebandFreq);
swv1.ComplexOutput = true;
swv1.SampleRate = fs_RxIQ;
swv1.SamplesPerFrame = samplesPerFrame;
y1 = swv1();

release(tx);
tx(ones(samplesPerFrame,size(tx.EnabledChannels,2)).*y1); %Output Tx Waveforms

pause(1);

%% Configure Calibration Board For Desired Routing
if (useCalibrationBoard)
    CalibrationBoard = CalBoardVCU118;
%     CalibrationBoard.ConfigureCombinedLoopback(tx);
%     CalibrationBoard.ConfigureTxOutToSMA(tx);
%     AD8318_voltage = CalibrationBoard.QueryAD8318_voltage(tx);
%     CalibrationBoard.ConfigureRxInFromSMA(tx); 
    switch(boardVariantNumber)
        case {1,2}
            CalibrationBoard.ConfigureAdjacentIndividualLoopback(tx);
        case 3
            CalibrationBoard.ConfigureCombinedLoopback(tx);
    end
end

%% Setup Rx Configuration
rx = adi.QuadMxFE.Rx;
rx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
rx.uri = uri;
switch(boardVariantNumber)
    case 1
        rx.num_coarse_attr_channels = 4; %Number of Coarse DDCs Used Per MxFE
        rx.num_fine_attr_channels = 4; %Number of Fine DDCs Used Per MxFE
        rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
        rx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]; %Enabled Rx Channels
        % Keep In Mind That NCO Frequencies Range From -fs_RxIQ/2 to +fs_RxIQ/2
        % If In 2nd Nyquist Enter The Folded NCO Frequency
        rx.MainNCOFrequenciesChipA = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE0 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipB = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE1 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipC = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE2 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipD = ones(1,rx.num_coarse_attr_channels).*(4e9-carrierFreq); %MxFE3 Coarse DDC NCO Frequencies [Hz]
        rx.ExternalAttenuation = -15; %On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]. Max -15dB
    case 2
        rx.num_coarse_attr_channels = 4; %Number of Coarse DDCs Used Per MxFE
        rx.num_fine_attr_channels = 4; %Number of Fine DDCs Used Per MxFE
        rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
        rx.EnabledChannels = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]; %Enabled Rx Channels
        rx.MainNCOFrequenciesChipA = ones(1,rx.num_coarse_attr_channels).*(carrierFreq); %MxFE0 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipB = ones(1,rx.num_coarse_attr_channels).*(carrierFreq); %MxFE1 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipC = ones(1,rx.num_coarse_attr_channels).*(carrierFreq); %MxFE2 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipD = ones(1,rx.num_coarse_attr_channels).*(carrierFreq); %MxFE3 Coarse DDC NCO Frequencies [Hz]
        rx.ExternalAttenuation = -15; %On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]. Max -15dB
    case 3
        rx.num_coarse_attr_channels = 2; %Number of Coarse DDCs Used Per MxFE
        rx.num_fine_attr_channels = 2; %Number of Fine DDCs Used Per MxFE
        rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
        rx.EnabledChannels = 1:8;
        % Keep In Mind That NCO Frequencies Range From -fs_RxIQ/2 to +fs_RxIQ/2
        % In 2nd Nyquist so Enter The Folded NCO Frequency
        rx.MainNCOFrequenciesChipA = ones(1,rx.num_coarse_attr_channels).*(6e9-carrierFreq); %MxFE0 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipB = ones(1,rx.num_coarse_attr_channels).*(6e9-carrierFreq); %MxFE1 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipC = ones(1,rx.num_coarse_attr_channels).*(6e9-carrierFreq); %MxFE2 Coarse DDC NCO Frequencies [Hz]
        rx.MainNCOFrequenciesChipD = ones(1,rx.num_coarse_attr_channels).*(6e9-carrierFreq); %MxFE3 Coarse DDC NCO Frequencies [Hz]
        rx.ExternalAttenuation = 0; %On-Platform Digital Step Attenuator Gain Within RF Front-End [dB]. Max -15dB
end

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
rx.SamplesPerFrame = 2^12; %Number Of Samples To Capture
rx.kernelBuffersCount = 1; %Number Of Buffers To Subsequently Capture
rx.EnableResampleFilters = 0; %Enable A Divide-By-Two Resampling
rx.EnablePFIRsChipA = false; %MxFE0 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipB = false; %MxFE1 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipC = false; %MxFE2 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx.EnablePFIRsChipD = false; %MxFE3 pFIR Configuration; false: Don't Use pFIRs, true: Use pFIRs
rx(); %Initialize The Rx System; Grab The Rx Data Into 'RxData' Matrix
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
dec2hex(rx.getRegister('283',rx.iioDev0));
dec2hex(rx.getRegister('283',rx.iioDev1));
dec2hex(rx.getRegister('283',rx.iioDev2));
dec2hex(rx.getRegister('283'));
pause(1);

%% Grab Initial Rx Data
RxData = rx(); %Grab the Rx data

% Plot Initial Rx Results
if (plotResults==1)
    figure(1);
    subplot(2,2,1);
    plot(real(RxData));
    hold on;
    plot(imag(RxData));
    hold off;
    ylim([-32768 32768]);
    yticks(linspace(-2^15, 2^15, 11));
    yticklabels({'-32768' '-26214' '-19661' '-13107' '-6554' '0' '6554' '13107' '19661' '26214' '32768'});
    xlabel('Sample Number');
    ylabel('ADC Code');
    xlim([0 2^12]);
    grid on;
    title('Sample Data Prior To Rx Calibration');
    drawnow;
    
    if (rx.EnableResampleFilters)
        hanningWindow = hanning(rx.SamplesPerFrame/2);
    else
        hanningWindow = hanning(rx.SamplesPerFrame);
    end
    hanNoiseEqBw = enbw(hanningWindow);
    scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;
    
    for chanNum=1:1:rx.num_data_channels
        complexData1 = (real(RxData(:,chanNum)) + sqrt(-1).*imag(RxData(:,chanNum)))./scalingFactor;
        windowedData1 = complexData1' .* (hanningWindow');
        fftComplex1 = fft(windowedData1);
        fftComplexShifted1 = fftshift(fftComplex1);
        fftMags1 = abs(fftComplexShifted1);
        fftMagsdB1(chanNum,:) = 20 * log10(fftMags1); 
        if (rx.EnableResampleFilters)
            freqAxis1 = linspace((-fs_RxIQ/1e6/2/2), (fs_RxIQ/1e6/2/2), length(fftMagsdB1));
        else
            freqAxis1 = linspace((-fs_RxIQ/1e6/2), (fs_RxIQ/1e6/2), length(fftMagsdB1));
        end

        subplot(2,2,3);
        plot(freqAxis1, fftMagsdB1(chanNum,:))
        grid on;
        hold on;
        xlabel('Frequency (MHz)','FontSize',8);
        ylabel('Amplitude (dBFS)','FontSize',8);
        if (rx.EnableResampleFilters)
            axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -100, 0]);
        else
            axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -100, 0]);
        end
    end
    hold off;
    title('Frequency Response Of All Rx Channels');
    drawnow;

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
    subplot(2,2,2);
    plot(linspace(0,3,4),adf4371_temp);
    xticklabels({'0','1','2','3'});
    grid on;
    xlabel('ADF4371 #');
    ylabel('ADF4371 Temp [^oC]');
    title('PLL/Synthesizer Temperatures');

    %% Poll All MxFE Temperatures
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev0);
    mxfe_temp(1) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev1);
    mxfe_temp(2) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev2);
    mxfe_temp(3) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev3);
    mxfe_temp(4) = temp/1e3;
    subplot(2,2,4);
    plot(linspace(0,3,4),mxfe_temp);
    xticklabels({'0','1','2','3'});
    grid on;
    xlabel('MxFE #');
    ylabel('MxFE Temp [^oC]');
    title('MxFE Temperatures');
end

release(rx);