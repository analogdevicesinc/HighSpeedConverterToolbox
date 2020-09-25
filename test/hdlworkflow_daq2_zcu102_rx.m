%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.8 (R2020a) at 12:56:00 on 24/09/2020
% This script was generated using the following parameter values:
%     Filename  : '/tmp/hsx-add-boot-bin-test/test/hdlworkflow_daq2_zcu102_rx.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'testModel_Rx64Tx64/HDL_DUT'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','testModel_Rx64Tx64/HDL_DUT');
%--------------------------------------------------------------------------

%% Load the Model
load_system('testModel_Rx64Tx64');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('testModel_Rx64Tx64/HDL_DUT');

%% Model HDL Parameters
%% Set Model 'testModel_Rx64Tx64' HDL parameters
hdlset_param('testModel_Rx64Tx64', 'HDLSubsystem', 'testModel_Rx64Tx64/HDL_DUT');
hdlset_param('testModel_Rx64Tx64', 'ReferenceDesign', 'DAQ2 ZCU102 (RX)');
hdlset_param('testModel_Rx64Tx64', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('testModel_Rx64Tx64', 'SynthesisToolChipFamily', 'Zynq UltraScale+');
hdlset_param('testModel_Rx64Tx64', 'SynthesisToolDeviceName', 'xczu9eg-ffvb1156-2-e');
hdlset_param('testModel_Rx64Tx64', 'SynthesisToolPackageName', '');
hdlset_param('testModel_Rx64Tx64', 'SynthesisToolSpeedValue', '');
hdlset_param('testModel_Rx64Tx64', 'TargetDirectory', 'hdl_prj/hdlsrc');
hdlset_param('testModel_Rx64Tx64', 'TargetLanguage', 'Verilog');
hdlset_param('testModel_Rx64Tx64', 'TargetPlatform', 'AnalogDevices DAQ2 ZCU102');
hdlset_param('testModel_Rx64Tx64', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT', 'AXI4SlaveIDWidth', '12');
hdlset_param('testModel_Rx64Tx64/HDL_DUT', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in1', 'IOInterface', 'DAQ2 ADC Data 0 IN [0:63]');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in1', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in2', 'IOInterface', 'DAQ2 ADC Data 1 IN [0:63]');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in2', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in3', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in3', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in4', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in4', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in5', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in5', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in6', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in6', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in7', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in7', 'IOInterfaceMapping', '');

% Set Inport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in8', 'IOInterface', 'DAQ2 Data Valid IN');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/in8', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out1', 'IOInterface', 'IP Data 0 OUT [0:63]');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out1', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out2', 'IOInterface', 'IP Data 1 OUT [0:63]');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out2', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out3', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out3', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out4', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out4', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out5', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out5', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out6', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out6', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out7', 'IOInterface', 'No Interface Specified');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out7', 'IOInterfaceMapping', '');

% Set Outport HDL parameters
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out8', 'IOInterface', 'IP Data Valid OUT');
hdlset_param('testModel_Rx64Tx64/HDL_DUT/out8', 'IOInterfaceMapping', '[0]');


%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = '2018.2';
hWC.IgnoreToolVersionMismatch = false;

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndIPCore = true;
hWC.RunTaskCreateProject = true;
hWC.RunTaskGenerateSoftwareInterfaceModel = false;
hWC.RunTaskBuildFPGABitstream = true;
hWC.RunTaskProgramTargetDevice = true;

% Set properties related to 'RunTaskGenerateRTLCodeAndIPCore' Task
hWC.IPCoreRepository = '';
hWC.GenerateIPCoreReport = true;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';
hWC.EnableIPCaching = false;

% Set properties related to 'RunTaskGenerateSoftwareInterfaceModel' Task
hWC.OperatingSystem = '';

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = false;
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Custom;
hWC.CustomBuildTclFile = 'adi_build.tcl';

% Set properties related to 'RunTaskProgramTargetDevice' Task
% hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
%% Run the workflow
try
    hdlcoder.runWorkflow('testModel_Rx64Tx64/HDL_DUT', hWC, 'Verbosity', 'on');
    bdclose('all');
    out = [];
catch ME
    if exist('hdl_prj/vivado_ip_prj/boot/BOOT.BIN','file')
       ME = [];
    end
    out = ME;%.identifier
end
