classdef Tx < adi.AD9152.Tx
    % adi.DAQ3.Tx Transmit data from the DAQ2 evaluation platform
    %   The adi.DAQ2.Tx System object is a signal source that can 
    %   send complex data to the DAQ3.
    %
    %   tx = adi.DAQ3.Tx;
    %   tx = adi.DAQ3.Tx('uri','ip:192.168.2.1');
    %
    %   <a href="https://wiki.analog.com/resources/eval/user-guides/ad-fmcdaq3-ebz">User Guide</a>
    %
    %   See also adi.AD9152.Tx, adi.DAQ3.Rx
    methods
        %% Constructor
        function obj = Tx(varargin)
            % Returns the matlabshared.libiio.base object
            coder.allowpcode('plain');
            obj = obj@adi.AD9152.Tx(varargin{:});
        end
    end
    
end

