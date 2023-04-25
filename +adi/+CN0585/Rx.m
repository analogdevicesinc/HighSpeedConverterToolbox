classdef Rx < adi.LTC2387.Rx
    % adi.CN0585.Rx Receive data from the LTC2387 evaluation platform
    %
    %   rx = adi.CN0585.Rx;
    %   rx = adi.CN0585.Rx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.LTC2387.Rx
    properties (Nontunable)

    end

    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.LTC2387.Rx(varargin{:});
        end

    end

end
