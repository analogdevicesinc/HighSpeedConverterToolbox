classdef BSPTests < BSPTestsBase
    
    methods(TestClassSetup)
        % Add the necessary files to path
        function addbspfiles(~)
            addpath('..');
            addpath(genpath('../hdl'));
        end
    end
    
end
