classdef Tx < adi.AD3552R.Tx
    % adi.LLDK.Tx Transmit data from the LLDK evaluation platform
    %   The adi.LLDK.Tx System object is a signal source that can 
    %   send complex data to the LLDK.
    %
    %   tx = adi.LLDK.Tx;
    %   tx = adi.LLDK.Tx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.AD3552r.Tx, adi.LLDK.Rx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD3552R.Tx(varargin{:});
        end
    end
    
end

