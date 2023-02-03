% create a sinewave

board_ip = 'ip:analog';

%Connect and configure the AD3552R-0 device(Tx0)

tx0 = adi.AD3552R.Tx0('uri',board_ip); 
tx0.EnabledChannels = [1, 2];
tx0.EnableCyclicBuffers = true;
tx0.DataSource = 'DMA';

% Connect and configure the AD3552R-1 device  (Tx1)
tx1 = adi.AD3552R.Tx1('uri',board_ip);
tx1.EnabledChannels = [1, 2];
tx1.EnableCyclicBuffers = true;

% generate the sine wave signal 

amplitude = 2^12; 
sampFreq = 15e6;
toneFreq = 1e3;
N = fix(sampFreq / toneFreq);
x = linspace(-pi,pi,N).';
sine_wave = amplitude*sin(x);

% continuously load data in  the buffer 

tx0([sine_wave,sine_wave]);
tx1([sine_wave,sine_wave]);


%connect to LTC2387
rx = adi.LTC2387.Rx('uri',board_ip);
% due to data type and format we need to enable the following flag 
rx.BufferTypeConversionEnable = true;
% enable the channels we want to read data from (options are 1, 2, 3 ,4 ) S
% in this example we are enabling channels 1 and 2 
rx.EnabledChannels = [1, 2, 3, 4];
% the data will be contained inside “data” variable
[data,valid] = rx();
title('LTC2387 Captured data')
subplot(4,1,1);
plot(data(:,1));
ylabel('Channel A'); 
subplot(4,1,2);
plot(data(:,2));
ylabel('Channel B');
subplot(4,1,3);
plot(data(:,3));
ylabel('Channel C');
subplot(4,1,4);
plot(data(:,4));
ylabel('Channel D'); 
xlabel('Number of samples') 
% when we finish reading the data we release the device
rx.release ();