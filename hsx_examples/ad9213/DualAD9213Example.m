clear all;

% Dual AD9213 system object
rx = adi.DualAD9213.Rx('uri','ip:10.48.65.15');
rx.EnabledChannels = [1 2];

% Get a buffer
x = rx();

% Plot data
figure; 
plot(x);

%% Perform register writes
% Split out individual devices for register access
adc1 = rx.getIIODevice('ad9213_0');
adc2 = rx.getIIODevice('ad9213_1');
pll1 = rx.getIIODevice('adf4377_0');
pll2 = rx.getIIODevice('adf4377_1');
vco = rx.getIIODevice('ltc6946');
clock_divs = rx.getIIODevice('ltc6952');

% Update SPI_TRM_FINE_DLY of both ADCs
% Reg Maps:
% https://www.analog.com/media/en/technical-documentation/data-sheets/AD9213.pdf
value1 = 1;
value2 = 4;
register = '0x150e';
rx.setRegister(value1,register,adc1);
rx.setRegister(value2,register,adc2);
% Check
fprintf('ADC1 Register: %s | Value: %s\n',register,num2str(rx.getRegister(register,adc1)));
fprintf('ADC2 Register: %s | Value: %s\n',register,num2str(rx.getRegister(register,adc2)));
% Reset JESD204 links
% Chip A
rx.setDeviceAttributeRAW('jesd204_fsm_ctrl','0',adc1);
rx.setDeviceAttributeRAW('jesd204_fsm_ctrl','1',adc1);
% Chip B
rx.setDeviceAttributeRAW('jesd204_fsm_ctrl','0',adc2);
rx.setDeviceAttributeRAW('jesd204_fsm_ctrl','1',adc2);
% Cleanup
release(rx);
