classdef Rx < adi.AD9656.Rx
    % adi.AD9656.Rx Receive data from the AD9363 transceiver
    %   The adi.AD9656.Rx System object is a signal source that can receive
    %   complex data from the AD9364.
    %
    %   rx = adi.AD9656.Rx;
    %   rx = adi.AD9656.Rx('uri','192.168.2.1');
    %
    %   <a href="http://www.analog.com/media/en/technical-documentation/data-sheets/AD9656.pdf">AD9656 Datasheet</a>
    %
    %   See also adi.Pluto.Rx
       
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9656.Rx(varargin{:});
        end
    end
    
end

