classdef Rx < adi.LTC2387.Rx
    % adi.LLDK.Rx Receive data from the LLDK evaluation platform
    %   The adi.LLDK.Rx System object is a signal source that can 
    %   receive complex data from the LLDK.
    %
    %   rx = adi.LLDK.Rx;
    %   rx = adi.LLDK.Rx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.LTC2387.Rx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.LTC2387.Rx(varargin{:});
        end
    end
    
end

