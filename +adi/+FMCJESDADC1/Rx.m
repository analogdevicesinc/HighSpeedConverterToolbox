classdef Rx < adi.AD9250.Rx
    % adi.FMCJESDADC1.Rx Receive data from the FMCOMMS11 evaluation platform
    %
    %   rx = adi.FMCJESDADC1.Rx;
    %   rx = adi.FMCJESDADC1.Rx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq2-ebz">User Guide</a>
    %
    %   See also adi.AD9250.Rx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9250.Rx(varargin{:});
        end
    end
    
end

