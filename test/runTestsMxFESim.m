import matlab.unittest.plugins.DiagnosticsRecordingPlugin
import matlab.unittest.plugins.TestReportPlugin

if ~exist('logs', 'dir')
    mkdir('logs')
end

runner = matlab.unittest.TestRunner.withNoPlugins;
runner.addPlugin(DiagnosticsRecordingPlugin);
runner.addPlugin(TestReportPlugin.producingPDF('Report.pdf',...
    'IncludingPassingDiagnostics',true,'IncludingCommandWindowText',true));
runner.ArtifactsRootFolder = fullfile(pwd,'logs');

suite = testsuite('AD9081Tests');

results = runner.run(suite);
t = table(results);
disp(t);
