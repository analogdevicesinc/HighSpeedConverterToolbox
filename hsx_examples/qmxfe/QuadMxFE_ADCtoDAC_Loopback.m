%% QuadMxFE_ADCtoDAC_Loopback.m
% Description: This script is to be used with the Analog Devices Quad-MxFE
% Platform to demonstrate MATLAB control of the system. It allows the user
% to configure the Tx and Rx aspects of the system and then configure the
% system such that a low-latency loopback occurs in which the Rx signal is
% digitized by the ADC and then sent through decimation blocks in the
% digital domain, then sent into interpolation blocks in the Tx digital
% data path, and finally synthesized by the DAC. This bypasses the
% JESD204b/c interface. It's important to note that this requires that the
% system be configured such that an equal number of Tx and Rx channels are
% enabled. If you inject a Rx signal into J501 on the Calibration Board,
% and connect J502 of the Calibration Board to a spectrum analyzer, then
% you can observe immediate changes in the frequency, amplitude, etc.

% Author: Mike Jones
% Date: 12/8/2020

% Gain Access to the Analog Devices, Inc. High Speed Converter Toolbox at:
% https://github.com/analogdevicesinc/HighSpeedConverterToolbox

instrreset;
%% Reload FPGA Code
% Load the 1GSPS, JES204c, 8Tx/8Rx Build To Demonstrate Rx-to-Tx Loopback
% LoadVcu118Code('C:\Xilinx\Vivado_Lab\2019.2\bin\xsdb.bat',...
%     'C:\SDG Builds\Quad MxFE for VCU118 2020-09-25\run.vcu118_quad_ad9081_204c_txmode_10_rxmode_11_revc.tcl')

%% Setup Parameters
close all;
clearvars;
uri = 'ip:192.168.2.1'; %Default IP Address To Connect To VCU118
fs_Rx = 4000e6; %ADC Sample Rate [Hz]
fs_RxIQ = 1000e6; %Rx Decimated IQ Sample Rate [Hz]
txNCOFreq = 3.0e9; % Tx NCO Frequency [Hz]
rxNCOFreq = 1e9; % Rx NCO Frequency [Hz]
plotResults = 1; %0: Do not plot intermediate results, 1: Plot intermediate results
useCalibrationBoard = 1; %0: Not Using Calibration Board, 1: Using Calibration Board

%% Setup Tx Configuration
tx = adi.QuadMxFE.Tx;
tx.UpdateDACFullScaleCurrent = true;
tx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
tx.uri = uri;
tx.num_coarse_attr_channels = 2; %Number of Coarse DUCs Used Per MxFE
tx.num_fine_attr_channels = 2; %Number of Fine DUCs Used Per MxFE
tx.num_data_channels = 4*tx.num_fine_attr_channels; %Total Number of Fine DUCs Used In System
tx.num_dds_channels = tx.num_data_channels*4; %Total Number of DDSs Used In System (Not Used For 'DMA' Mode)
tx.EnabledChannels = [1,2]; %Enabled Tx Channels, Only Needed for DMA
tx.EnableResampleFilters = 0; %Enable A Divide-By-Two Resampling
tx.DataSource = 'DMA'; %'DMA' or 'DDS'
tx.EnableCyclicBuffers = 1; %0: Don't Cycle Tx Waveform, 1: Cycle Tx Waveform
tx.MainNCOFrequenciesChipA = ones(1,tx.num_coarse_attr_channels)*txNCOFreq; %MxFE0 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipB = ones(1,tx.num_coarse_attr_channels)*txNCOFreq; %MxFE1 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipC = ones(1,tx.num_coarse_attr_channels)*txNCOFreq; %MxFE2 Coarse DUC NCO Frequencies [Hz]
tx.MainNCOFrequenciesChipD = ones(1,tx.num_coarse_attr_channels)*txNCOFreq; %MxFE3 Coarse DUC NCO Frequencies [Hz]
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
tx.ChannelNCOGainScalesChipA  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE0 Digital Gain Code
tx.ChannelNCOGainScalesChipB  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE1 Digital Gain Code
tx.ChannelNCOGainScalesChipC  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE2 Digital Gain Code
tx.ChannelNCOGainScalesChipD  = ones(1,tx.num_fine_attr_channels).*0.5; %MxFE3 Digital Gain Code

%% Setup Rx Configuration
rx = adi.QuadMxFE.Rx;
rx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
rx.uri = uri;
rx.num_coarse_attr_channels = 2; %Number of Coarse DDCs Used Per MxFE
rx.num_fine_attr_channels = 2; %Number of Fine DDCs Used Per MxFE
rx.num_data_channels = 4*rx.num_fine_attr_channels; %Total Number of Fine DDCs Used In System
rx.EnabledChannels = [1,2,3,4,5,6,7,8]; %Enabled Rx Channels
% Keep In Mind That NCO Frequencies Range From -fs_RxIQ/2 to +rx_RxIQ/2
% If In 2nd Nyquist Enter The Folded NCO Frequency
rx.MainNCOFrequenciesChipA = ones(1,rx.num_coarse_attr_channels).*(rxNCOFreq); %MxFE0 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipB = ones(1,rx.num_coarse_attr_channels).*(rxNCOFreq); %MxFE1 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipC = ones(1,rx.num_coarse_attr_channels).*(rxNCOFreq); %MxFE2 Coarse DDC NCO Frequencies [Hz]
rx.MainNCOFrequenciesChipD = ones(1,rx.num_coarse_attr_channels).*(rxNCOFreq); %MxFE3 Coarse DDC NCO Frequencies [Hz]
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
RxData = rx(); %Initialize The Rx System; Grab The Rx Data Into 'RxData' Matrix
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
regVal = dec2hex(rx.getRegister('283'));
pause(1);

%% Grab Initial Rx Data and store settings
RxData = rx(); %Grab the Rx data
release(rx);

%% Enable ADC-to-DAC Loopback
tx(ones(2,2));
tx.setDeviceAttributeRAW('loopback_mode','1',tx.iioDev0); % Enable MxFE0 Loopback
tx.setDeviceAttributeRAW('loopback_mode','1',tx.iioDev1); % Enable MxFE1 Loopback
tx.setDeviceAttributeRAW('loopback_mode','1',tx.iioDev2); % Enable MxFE2 Loopback
tx.setDeviceAttributeRAW('loopback_mode','1',tx.iioDev3); % Enable MxFE3 Loopback
% release(tx);

%% Configure Calibration Board For Desired Routing
% Inject a signal into the J501 SMA of the Calibration Board. Use this as
% the injected Rx signal for ADC input to DAC output loopback testing.
if (useCalibrationBoard)
    CalibrationBoard = CalBoardVCU118;
    CalibrationBoard.ConfigureRxInFromSMA(tx);
end

%% Grab some Rx data
% The Rx JESD datapath is still capable of capturing Rx data, even though
% the signal is also being loopbed back and transmitted out of the DACs.
if (plotResults==1)
    RxData = rx(); %Grab the Rx data
    release(rx);
    
    figure(1);
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
    title('Sample Data After Loopback');
    drawnow;
    
    if (rx.EnableResampleFilters)
        hanningWindow = hanning(rx.SamplesPerFrame/2);
    else
        hanningWindow = hanning(rx.SamplesPerFrame);
    end
    hanNoiseEqBw = enbw(hanningWindow);
    scalingFactor = sqrt(hanNoiseEqBw)*(rx.SamplesPerFrame/2)*2^15;
    
    figure(2);
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

        subplot(2,4,chanNum);
        plot(freqAxis1, fftMagsdB1(chanNum,:))
        grid on;
        xlabel('Frequency (MHz)','FontSize',8);
        ylabel('Amplitude (dBFS)','FontSize',8);
        if (rx.EnableResampleFilters)
            axis([-fs_RxIQ/1e6/2/2, fs_RxIQ/1e6/2/2, -100, 0]);
        else
            axis([-fs_RxIQ/1e6/2, fs_RxIQ/1e6/2, -100, 0]);
        end
        title(['Rx' num2str(chanNum-1) ' Spectrum']);
    end
    drawnow;

    %% Poll All MxFE Temperatures
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev0);
    mxfe_temp(1) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev1);
    mxfe_temp(2) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev2);
    mxfe_temp(3) = temp/1e3;
    temp = tx.getAttributeDouble('temp0', 'input', 0, tx.iioDev3);
    mxfe_temp(4) = temp/1e3;
    figure(3);
    plot(linspace(0,3,4),mxfe_temp);
    xticks(linspace(0,3,4));
    xticklabels({'0','1','2','3'});
    grid on;
    xlabel('MxFE #');
    ylabel('MxFE Temp [^oC]');
    title('MxFE Temperatures');
end
