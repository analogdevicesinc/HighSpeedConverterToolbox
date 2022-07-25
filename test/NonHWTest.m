classdef NonHWTest < matlab.unittest.TestCase
    
    properties(TestParameter)
        rootClasses = {...
            {'AD9081',{'Rx','Tx'}},...
            {'AD9144',{'Tx'}},...
            {'AD9152',{'Tx'}},...
            {'AD9467',{'Rx'}},...
            {'AD9680',{'Rx'}},...
            {'DAQ2',{'Rx','Tx'}},...
            {'QuadMxFE',{'Rx','Tx'}}...
            };
    end
        
    methods (Test)
        
        function call_constructors(testCase,rootClasses)
            for trx = rootClasses{2}
                sdr = eval(['adi.',rootClasses{1},'.',trx{:},'()']);
                testCase.assertEqual(class(sdr),['adi.',rootClasses{1},'.',trx{:}]);
            end
        end
        
    end
    
    
end

