%CN0585 Streaming example

board_ip = 'your_board_ip';

% Describe the devices

cn0585_device_rx = adi.CN0585.Rx('uri', cat(2, 'ip:', board_ip));
cn0585_device_tx0 = adi.CN0585.Tx0('uri', cat(2, 'ip:', board_ip));
cn0585_device_tx1 = adi.CN0585.Tx1('uri', cat(2, 'ip:', board_ip));

cn0585_device_tx0.EnableCyclicBuffers = true;
cn0585_device_tx1.EnableCyclicBuffers = true;

cn0585_device_rx.BufferTypeConversionEnable = true;

% enable the channels we want to write data to (options are 1, 2 )

cn0585_device_tx0.EnabledChannels = [1, 2];
cn0585_device_tx1.EnabledChannels = [1, 2];

% enable the channels we want to read data from (options are 1, 2, 3 ,4 )

cn0585_device_rx.EnabledChannels = [1, 2, 3, 4];

write_reg = soc.libiio.aximm.WriteHost(devName = 'mwipcore0:mmwr-channel0', IPAddress = board_ip); % MathWorks IP Core Write channel
read_reg = soc.libiio.aximm.WriteHost(devName = 'mwipcore0:mmrd-channel1', IPAddress = board_ip); % MathWorks IP Core Read  channel

%available options:'adc_input', 'dma_input', 'ramp_input'

cn0585_device_tx0.InputSource = 'dma_input';
cn0585_device_tx1.InputSource = 'dma_input';

%available options: '0/2.5V', '0/5V', '0/10V', '-5/+5V', '-10/+10V'

cn0585_device_tx0.OutputRange = '-10/+10V';
cn0585_device_tx1.OutputRange = '-10/+10V';


% generate the sine wave signal

amplitude = 2 ^ 15;
sampFreq = cn0585_device_tx0.SamplingRate;
toneFreq = 1e3;
N = sampFreq / toneFreq;
x = linspace(-pi, pi, N).';
sine_wave = amplitude * sin(x);

% continuously load data in  the buffer and configure the GPIOs state
% (SetupInit Base file)
% DAC 1 has to be updated and started first and then DAC0 in order to have syncronized data between devices 

cn0585_device_tx1([sine_wave, sine_wave]);
cn0585_device_tx0([sine_wave, sine_wave]);

% available options:"start_stream_synced", "start_stream", "stop_stream"

cn0585_device_tx1.StreamStatus = 'start_stream';
cn0585_device_tx0.StreamStatus = 'start_stream';

% the data will be contained inside “data” variable

data = cn0585_device_rx();

if cn0585_device_tx0.CheckMathWorksCore()

    write_reg.writeReg(hex2dec('100'), 85);
    write_reg.writeReg(hex2dec('104'), 22);

    fprintf('Read value from the 0x108 register is: %d \n', read_reg.readReg(hex2dec('108')));
    fprintf('Read value from the 0x10c register is: %d \n', read_reg.readReg(hex2dec('10c')));
end

title('ADAQ23876 Channels');
subplot(4, 1, 1);
plot(data(:, 1));
ylabel('Channel A');
subplot(4, 1, 2);
plot(data(:, 2));
ylabel('Channel B');
subplot(4, 1, 3);
plot(data(:, 3));
ylabel('Channel C');
subplot(4, 1, 4);
plot(data(:, 4));
ylabel('Channel D');
xlabel('Number of samples');

% when we finish reading the data we release the device

cn0585_device_tx1.StreamStatus = 'stop_stream';
cn0585_device_tx0.StreamStatus = 'stop_stream';

cn0585_device_tx1.release();
cn0585_device_tx0.release();

cn0585_device_rx.release();
