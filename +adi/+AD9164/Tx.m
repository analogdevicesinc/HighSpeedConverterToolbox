classdef Tx <  adi.AD916x.Tx & adi.AD9164.Base 
    % adi.AD9162.Tx Transmit data to the AD9162 high speed DAC
    %
    %   tx = adi.AD9162.Tx;
    %   tx = adi.AD9162.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9161-9162.pdf">AD9162 Datasheet</a>
    %
    %   See also adi.FMCOMMS11.Tx

    properties (Nontunable, Hidden)
        devName = 'axi-ad9164-hpc';
        channel_names = {'voltage0_i','voltage0_q'};
    end


end

