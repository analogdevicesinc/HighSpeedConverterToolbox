clc; clear all;
uri = "ip:192.168.0.101"

tx = adi.QuadMxFE.Tx;
tx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
tx.uri = uri;

rx = adi.QuadMxFE.Rx;
rx.CalibrationBoardAttached = useCalibrationBoard; %0: Not Using Calibration Board, 1: Using Calibration Board
rx.uri = uri;

rx.setDeviceAttributeRAW('multichip_sync', '10', tx.iioDev3); %Issue MCS

N_NCOS = 7;
run_plot = false;
FFH_PIN_CTRL = true;

% Enable the first RX of each MxFE
RX_CHAN_EN = 1:4:16;

% In case the channelizers are not used (bypassed) compensate phase offsets using the main NCOs
channelizer_bypass = rx.ChannelNCOFrequencyAvailable;
if strcmp(channelizer_bypass, '[0 1 0]'):
    COMPENSATE_MAIN_PHASES = true;
else
    COMPENSATE_MAIN_PHASES = false;
end

% Configure properties
fprintf("--Setting up chip\n");

%{
# Loop Combined Tx Channels Back Into Combined Rx Path
dev.gpio_ctrl_ind = 1
dev.gpio_5045_v1 = 1
dev.gpio_5045_v2 = 1
dev.gpio_ctrl_rx_combined = 0
%}

rx.ExternalAttenuation = -15; % Set DSA Attenuation In Rx Front-Ends

% Set NCOs
rx.ChannelNCOFrequenciesChipA = zeros(1, 4);
rx.ChannelNCOFrequenciesChipB = zeros(1, 4);
rx.ChannelNCOFrequenciesChipC = zeros(1, 4);
rx.ChannelNCOFrequenciesChipD = zeros(1, 4);
tx.ChannelNCOFrequenciesChipA = zeros(1, 4);
tx.ChannelNCOFrequenciesChipB = zeros(1, 4);
tx.ChannelNCOFrequenciesChipC = zeros(1, 4);
tx.ChannelNCOFrequenciesChipD = zeros(1, 4);
rx.MainNCOFrequenciesChipA = 1000000000*ones(1,4);
rx.MainNCOFrequenciesChipB = 1000000000*ones(1,4);
rx.MainNCOFrequenciesChipC = 1000000000*ones(1,4);
rx.MainNCOFrequenciesChipD = 1000000000*ones(1,4);
tx.MainNCOFrequenciesChipA = 3000000000*ones(1,4);
tx.MainNCOFrequenciesChipB = 3000000000*ones(1,4);
tx.MainNCOFrequenciesChipC = 3000000000*ones(1,4);
tx.MainNCOFrequenciesChipD = 3000000000*ones(1,4);

tx.MainFfhModeInChipA(:) = {'phase_coherent'};
tx.MainFfhModeInChipB(:) = {'phase_coherent'};
tx.MainFfhModeInChipC(:) = {'phase_coherent'};
tx.MainFfhModeInChipD(:) = {'phase_coherent'};
rx.MainFfhModeInChipA(:) = {'instantaneous_update'};
rx.MainFfhModeInChipB(:) = {'instantaneous_update'};
rx.MainFfhModeInChipC(:) = {'instantaneous_update'};
rx.MainFfhModeInChipD(:) = {'instantaneous_update'};

if FFH_PIN_CTRL
    tx.MainFfhGpioModeEnableInChipA = true(1,4);
    tx.MainFfhGpioModeEnableInChipB = true(1,4);
    tx.MainFfhGpioModeEnableInChipC = true(1,4);
    tx.MainFfhGpioModeEnableInChipD = true(1,4);
    rx.MainFfhGpioModeEnableInChipA = true(1,4);
    rx.MainFfhGpioModeEnableInChipB = true(1,4);
    rx.MainFfhGpioModeEnableInChipC = true(1,4);
    rx.MainFfhGpioModeEnableInChipD = true(1,4);
    tx.TxNCOMuxSelect = 0;
    rx.RxNCOMuxSelect = 0;
else
    tx.MainFfhGpioModeEnableInChipA = false(1,4);
    tx.MainFfhGpioModeEnableInChipB = false(1,4);
    tx.MainFfhGpioModeEnableInChipC = false(1,4);
    tx.MainFfhGpioModeEnableInChipD = false(1,4);
    rx.MainFfhGpioModeEnableInChipA = false(1,4);
    rx.MainFfhGpioModeEnableInChipB = false(1,4);
    rx.MainFfhGpioModeEnableInChipC = false(1,4);
    rx.MainFfhGpioModeEnableInChipD = false(1,4);
end


rx.MainNCOFfhIndexInChipA = (1:4)*16;
rx.MainNCOFfhIndexInChipB = (1:4)*16;
rx.MainNCOFfhIndexInChipC = (1:4)*16;
rx.MainNCOFfhIndexInChipD = (1:4)*16;
rx.MainNCOFrequenciesChipA = 1000000000 + (1:4)*1000000;
rx.MainNCOFrequenciesChipB = 1000000000 + (1:4)*1250000;
rx.MainNCOFrequenciesChipC = 1000000000 + (1:4)*1500000;
rx.MainNCOFrequenciesChipD = 1000000000 + (1:4)*1750000;
tx.MainNCOFfhIndexInChipA = (1:4)*16;
tx.MainNCOFfhIndexInChipB = (1:4)*16;
tx.MainNCOFfhIndexInChipC = (1:4)*16;
tx.MainNCOFfhIndexInChipD = (1:4)*16;
tx.MainNCOFrequenciesChipA = 3000000000 - (1:4)*1000000;
tx.MainNCOFrequenciesChipB = 3000000000 - (1:4)*1250000;
tx.MainNCOFrequenciesChipC = 3000000000 - (1:4)*1500000;
tx.MainNCOFrequenciesChipD = 3000000000 - (1:4)*1750000;


rx.kernelBuffersCount = 1;
rx.EnabledChannels = RX_CHAN_EN;
tx.EnabledChannels = 1:16;
rx.NyquistZoneChipA = {'even'};
rx.NyquistZoneChipB = {'even'};
rx.NyquistZoneChipC = {'even'};
rx.NyquistZoneChipD = {'even'};

rx.SamplesPerFrame = 2^12;
tx.EnableCyclicBuffers = true;

% Set single DDS tone for TX on one transmitter
tx.DataSource = 'DDS';
tx.dds_single_tone(rx.SamplingRate / 50, 0.1, channel=0)
tx.DDSFrequencies(1, 1) = rx.SamplingRate/50;
tx.DDSFrequencies(1, 2) = rx.SamplingRate/50;
tx.DDSScales(1, 1) = 0.1; 
tx.DDSScales(1, 2) = 0.1;
tx.DDSPhases(1, 1) = 90e3;

for l=0:2
    rx.setDeviceAttributeRAW('multichip_sync', '10', tx.iioDev3); %Issue MCS
    if FFH_PIN_CTRL
        for i=0:N_NCOS-1
            tx.TxFFHMuxSelect = i + 1
            Rx.RxFFHMuxSelect = i
        end
    else
        rx.MainNCOFfhIndexInChipA = (1:4)*16;
        rx.MainNCOFfhIndexInChipB = (1:4)*16;
        rx.MainNCOFfhIndexInChipC = (1:4)*16;
        rx.MainNCOFfhIndexInChipD = (1:4)*16;
        tx.MainNCOFfhIndexInChipA = (1:4)*16;
        tx.MainNCOFfhIndexInChipB = (1:4)*16;
        tx.MainNCOFfhIndexInChipC = (1:4)*16;
        tx.MainNCOFfhIndexInChipD = (1:4)*16;
    end
end