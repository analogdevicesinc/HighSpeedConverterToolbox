% TX will only work once before needing to restart the board need to check
% why/ error after first run :
%     Error using matlabshared.libiio.base/cstatusid
%     Failed to configure device and buffers.


% tx = adi.LLDK.Tx('uri','ip:10.48.65.153');
% % tx.EnableCyclicBuffers = true;
% x = linspace(-pi,pi,2^15).';
%   
% b1 = sin(x);
% tx(b1);
% tx.step(b1);

rx = adi.LLDK.Rx('uri','ip:10.48.65.153');
% to be able to read data from the Rx component we need to eneble the
% following flag BufferTypeConversionEnable
rx.BufferTypeConversionEnable = true;

% The followind example will keep reading data from channels 1 and 2 and
% plot them 
% It will first read from channel 1 then channel 2 then both of them 
while true
    % Enable the first channel and read it's data 
    rx.EnabledChannels = [1];
    [data,valid] = rx();
    subplot(3,1,1);plot(data);
    drawnow;
    rx.release(); % after we plot the date we need to release the Rx 
    
    % Enable the second channel and read it's data
    rx.EnabledChannels = [2];
    [data,valid] = rx();
    subplot(3,1,2);plot(data);
    drawnow;
    rx.release();% after we plot the date we need to release the Rx 
    
    % Enable channels 1 and 2 and read data from both at the same time
    rx.EnabledChannels = [1 2];
    [data,valid] = rx();
    subplot(3,1,3);plot(data);
    drawnow;
    rx.release();% after we plot the date we need to release the Rx 
end