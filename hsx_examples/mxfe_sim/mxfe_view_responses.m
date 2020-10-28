%% View RX path
rx = adi.sim.AD9081.Rx;

rx.MainDataPathDecimation = 4;
rx.ChannelizerPathDecimation = 6;

% Initial model
d = randn(24*10,1);
rx(d,d,d,d);

% Extract responses
filters = rx.RxCascade();
freqz(filters);

%% View TX path
tx = adi.sim.AD9081.Tx;

tx.MainDataPathInterpolation = 4;
tx.ChannelizerPathInterpolation = 6;

% Initial model
d = randn(24*10,1);
tx(d,d,d,d,d,d,d,d);

% Extract responses
filters = tx.TxCascade();
freqz(filters);




