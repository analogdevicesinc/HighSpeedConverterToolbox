clc;

% Dual AD9213 system object
rx = adi.AD9213.Rx('uri','ip:10.48.65.15');
rx.EnabledChannels = [1 2];

% Get a buffer
x = rx();

% Plot data
figure; 
plot(x);

release(rx);