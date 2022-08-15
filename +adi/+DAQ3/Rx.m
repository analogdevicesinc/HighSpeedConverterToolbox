classdef Rx < adi.AD9680.Rx
    % adi.DAQ3.Rx Receive data from the DAQ3 evaluation platform
    %   The adi.DAQ3.Rx System object is a signal source that can 
    %   receive complex data from the DAQ3.
    %
    %   rx = adi.DAQ3.Rx;
    %   rx = adi.DAQ3.Rx('uri','192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcDAQ3-ebz">User Guide</a>
    %
    %   See also adi.AD9680.Rx, adi.DAQ3.Tx
    methods
        %% Constructor
        function obj = Rx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9680.Rx(varargin{:});
        end
    end
    
end

