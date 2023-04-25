classdef Tx0 < adi.AD3552R.Tx & adi.CN0585.Base
    % adi.CN0585.Rx Receive data from the LTC2387 evaluation platform
    %
    %   tx0 = adi.CN0585.Tx0;
    %   tx0 = adi.CN0585.Tx0('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.AD3552R.Tx0
    properties (Nontunable)

    end

    methods
        %% Constructor
        function obj = Tx0(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD3552R.Tx(varargin{:});
            obj.devName = 'axi-ad3552r-0';
            obj.phyDevName = 'axi-ad3552r-0';
        end

    end

end
