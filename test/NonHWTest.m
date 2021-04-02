classdef NonHWTest < matlab.unittest.TestCase
    
    properties(TestParameter)
        rootClasses = {'AD9081','AD9144','AD9467'...
            'AD9680','DAQ2','QuadMxFE'}
        children = {'Rx','Tx'};
    end
    
   
    methods (Test)
        
        function call_constructors(testCase,rootClasses,children)
            sdr = eval(['adi.',rootClasses,'.',children,'()']);
            testCase.assertEqual(class(sdr),['adi.',rootClasses,'.',children]);
        end
        
    end

    
end

