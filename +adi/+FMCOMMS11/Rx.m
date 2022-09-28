classdef Rx < adi.AD9625.Rx
    % adi.FMCOMMS11.Rx Receive data from the FMCOMMS11 evaluation platform
    %
    %   rx = adi.FMCOMMS11.Rx;
    %   rx = adi.FMCOMMS11.Rx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.AD9680.Rx, adi.FMCOMMS11.Tx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9625.Rx(varargin{:});
        end
    end
    
end

