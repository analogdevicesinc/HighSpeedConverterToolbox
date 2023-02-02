% create a sinewave
x = linspace(-pi,pi,2^15).';
b1 = (2^15)*sin(x);

amplitude = 2^15; toneFreq1 = 1e6;
swv1 = dsp.SineWave(amplitude, toneFreq1);
swv1.ComplexOutput = false;
swv1.SamplesPerFrame = 2^20;
swv1.SampleRate = 1e9;
y1 = swv1();
            
amplitude = 2^15; toneFreq2 = 2e6;
swv1 = dsp.SineWave(amplitude, toneFreq2);
swv1.ComplexOutput = false;
swv1.SamplesPerFrame = 2^20;
swv1.SampleRate = 1e9;
y2 = swv1();

%connect to AD3552R-0 (Tx0)
tx0 = adi.AD3552R.Tx0('uri','ip:analog.local'); 
tx0.EnabledChannels = [1, 2];

% continuously load data in  the buffer 
tx0.EnableCyclicBuffers = true;
% load sinewave data to the buffer
tx0([b1,b1]);
subplot(3,1,1);plot(b1);

% Repeat steps for AD3552R-1  (Tx1)
tx1 = adi.AD3552R.Tx1('uri','ip:analog.local');
tx1.EnableCyclicBuffers = true;
tx1(b1);
tx1.step(b1);

%connect to LTC2387
rx = adi.LTC2387.Rx('uri','ip:analog.local');
% due to data type and format we need to enable the following flag 
rx.BufferTypeConversionEnable = true;
% enable the channels we want to read data from (options are 1, 2, 3 ,4 ) 
% in this example we are enabling channels 1 and 2 
rx.EnabledChannels = [1 2];
% the data will be contained inside “data” variable
[data,valid] = rx();
subplot(3,1,2);plot(data);
% when we finish reading the data we release the device
rx.release ();
