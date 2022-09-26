function hRD = plugin_rd_rx
% Reference design definition

% Call the common reference design definition function
hRD = AnalogDevices.plugin_rd('AD9695', 'ZCU102', 'Rx');
