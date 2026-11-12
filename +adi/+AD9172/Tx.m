classdef Tx < adi.AD917x.Tx & adi.AD917x.Base
    % adi.AD9172.Tx Transmit data to the AD9172 high speed DAC
    %
    %   tx = adi.AD9172.Tx;
    %   tx = adi.AD9172.Tx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/ad9172.pdf">AD9172 Datasheet</a>
    %

    properties (Nontunable, Hidden)
        devName = 'axi-ad9172-hpc';
        channel_names = {'voltage0_i','voltage0_q'};
    end

    %% API Functions
    methods (Hidden, Access = protected)

        function icon = getIconImpl(obj)
            icon = sprintf(['AD9172 ',obj.Type]);
        end
    end


    %% External Dependency Methods
    methods (Hidden, Static)
        function bName = getDescriptiveName(~)
            bName = 'AD9172';
        end

    end
end

