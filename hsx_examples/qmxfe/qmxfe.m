uri = 'ip:10.72.162.37';
rx = adi.QuadMxFE.Rx;
rx.uri = uri;
rx.EnabledChannels = [1,2,3,4];
data = rx();
plot(data);

tx = adi.QuadMxFE.Tx;
tx.uri = uri;
tx.EnabledChannels = [1,2,3,4];
tx.DataSource = 'DDS';
tx();
