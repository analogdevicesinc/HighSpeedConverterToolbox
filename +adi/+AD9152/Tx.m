classdef Tx < adi.AD915x.Tx & adi.AD9152.Base 
    % adi.AD9152.Tx Transmit data to the AD9144 high speed DAC
    %   The adi.AD9152.Tx System object is a signal source that can send
    %   complex data from the AD9144.
    %
    %   tx = adi.AD9144.Tx;
    %   tx = adi.AD9144.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9144.pdf">AD9144 Datasheet</a>
    %
    %   See also adi.DAQ3.Tx
    
    properties (Nontunable, Hidden)
        devName = 'axi-ad9152-hpc';
        phyDevName = 'axi-ad9152-hpc';
        channel_names = {'voltage0','voltage1'};
    end    
    
    %% External Dependency Methods
    methods (Hidden, Static)
      
        function bName = getDescriptiveName(~)
            bName = 'AD9152';
        end       
    end
end

