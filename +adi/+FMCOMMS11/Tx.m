classdef Tx < adi.AD9162.Tx
    % adi.FMCOMMS11.Tx Transmit data from the DAQ2 evaluation platform
    %
    %   tx = adi.FMCOMMS11.Tx;
    %   tx = adi.FMCOMMS11.Tx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcomms11-ebz">User Guide</a>
    %
    %   See also adi.AD9162.Tx, adi.FMCOMMS11.Rx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9162.Tx(varargin{:});
        end
    end
    
end

