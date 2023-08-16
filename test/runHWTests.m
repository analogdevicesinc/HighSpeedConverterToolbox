function runHWTests(board)

import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.DiagnosticsValidationPlugin
import matlab.unittest.parameters.Parameter
import matlab.unittest.plugins.ToUniqueFile;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.constraints.ContainsSubstring;
import matlab.unittest.selectors.HasName;
import matlab.unittest.selectors.HasProcedureName;
switch board
    case {"socfpga-arria10-socdk-daq2", ...
            "zynq-zc706-adv7511-fmcdaq2", ...
            "zynqmp-zcu102-rev10-fmcdaq2"}
        at = 'DAQ2';
    case {"zynq-zc706-adv7511-fmcdaq3-revC", ...
            "zynqmp-zcu102-rev10-fmcdaq3"}
        at = 'DAQ3';
    case {"zynqmp-zcu102-rev10-ad9081-v204b-txmode9-rxmode4", ...
            "zynqmp-zcu102-rev10-ad9081-v204c-txmode0-rxmode1", ...
            "zynqmp-zcu102-rev10-ad9081-vm4-l8", ...
            "zynqmp-zcu102-rev10-ad9081-vm8-l4"}
        at = 'AD9081';
    case {"zynq-zc706-adv7511-fmcomms11"}
        at = 'FMCOMMS11';
    case {"zynqmp-zcu102-rev10-ad9172-fmc-ebz-mode4"}
        at = 'AD9172';
    otherwise
        error('%s unsupported for HW test harness', board);
end

    ats = {'DAQ2Tests','DAQ3Tests','AD9081HWTests','FMCOMMS11Test'};

    if nargin == 0
        suite = testsuite(ats);
    else
        suite = testsuite(ats);
        suite = selectIf(suite,HasProcedureName(ContainsSubstring(at,'IgnoringCase',true)));
    end
    try
        runner = matlab.unittest.TestRunner.withTextOutput('OutputDetail',1);
        runner.addPlugin(DiagnosticsValidationPlugin)
        xmlFile = board+"_HWTestResults.xml";
        plugin = XMLPlugin.producingJUnitFormat(xmlFile);
        
        runner.addPlugin(plugin);
        results = runner.run(suite);
        
        t = table(results);
        disp(t);
        disp(repmat('#',1,80));
        fid = fopen('failures.txt','a+');
        for test = results
            if test.Failed
                disp(test.Name);
                fprintf(fid,string(test.Name)+'\n');
            end
        end
        fclose(fid);
    catch e
        disp(getReport(e,'extended'));
%         bdclose('all');
%         exit(1);
    end
    save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH_MM_SS'),'.mat'],'t');
% bdclose('all');
% exit(any([results.Failed]));
end
