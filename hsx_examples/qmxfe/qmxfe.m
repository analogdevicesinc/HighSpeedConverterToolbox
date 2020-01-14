rx = adi.QuadMxFE.Rx;
rx.uri = 'ip:analog';
rx.EnabledChannels = [1,2,3,4];
data = rx();
plot(data);
