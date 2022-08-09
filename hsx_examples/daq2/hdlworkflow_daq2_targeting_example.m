%--------------------------------------------------------------------------
% HDL Workflow Script
% Generated with MATLAB 9.11 (R2021b) at 17:25:24 on 04/08/2022
% This script was generated using the following parameter values:
%     Filename  : 'C:\git\hsx\HighSpeedConverterToolbox\hsx_examples\daq2\hdlworkflow.m'
%     Overwrite : true
%     Comments  : true
%     Headers   : true
%     DUT       : 'daq2_targeting_example/HDL_DUT'
% To view changes after modifying the workflow, run the following command:
% >> hWC.export('DUT','daq2_targeting_example/HDL_DUT');
%--------------------------------------------------------------------------

%% Load the Model
load_system('daq2_targeting_example');

%% Restore the Model to default HDL parameters
%hdlrestoreparams('daq2_targeting_example/HDL_DUT');

%% Model HDL Parameters
%% Set Model 'daq2_targeting_example' HDL parameters
hdlset_param('daq2_targeting_example', 'HDLSubsystem', 'daq2_targeting_example/HDL_DUT');
hdlset_param('daq2_targeting_example', 'ReferenceDesign', 'DAQ2 ZCU102 (RX & TX)');
hdlset_param('daq2_targeting_example', 'ReferenceDesignParameter', {'project','daq2','carrier','zcu102','ref_design','Rx & Tx','fpga_board','ZCU102','preprocess','off','postprocess','off','HDLVerifierJTAGAXI','off'});
hdlset_param('daq2_targeting_example', 'SynthesisTool', 'Xilinx Vivado');
hdlset_param('daq2_targeting_example', 'SynthesisToolChipFamily', 'Zynq UltraScale+');
hdlset_param('daq2_targeting_example', 'SynthesisToolDeviceName', 'xczu9eg-ffvb1156-2-e');
hdlset_param('daq2_targeting_example', 'SynthesisToolPackageName', '');
hdlset_param('daq2_targeting_example', 'SynthesisToolSpeedValue', '');
hdlset_param('daq2_targeting_example', 'TargetDirectory', 'hdl_prj\hdlsrc');
hdlset_param('daq2_targeting_example', 'TargetLanguage', 'Verilog');
hdlset_param('daq2_targeting_example', 'TargetPlatform', 'AnalogDevices DAQ2 ZCU102');
hdlset_param('daq2_targeting_example', 'Workflow', 'IP Core Generation');

% Set SubSystem HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT', 'AXI4SlaveIDWidth', '12');
hdlset_param('daq2_targeting_example/HDL_DUT', 'ProcessorFPGASynchronization', 'Free running');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in1', 'IOInterface', 'DAQ2 ADC Data 0 IN [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/in1', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in2', 'IOInterface', 'DAQ2 ADC Data 1 IN [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/in2', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in3', 'IOInterface', 'IP Data 0 IN [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/in3', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in4', 'IOInterface', 'IP Data 1 IN [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/in4', 'IOInterfaceMapping', '[0:63]');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in5', 'IOInterface', 'IP Valid Rx Data IN');
hdlset_param('daq2_targeting_example/HDL_DUT/in5', 'IOInterfaceMapping', '[0]');

% Set Inport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/in6', 'IOInterface', 'IP Valid Tx Data IN');
hdlset_param('daq2_targeting_example/HDL_DUT/in6', 'IOInterfaceMapping', '[0]');

% Set Outport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/out1', 'IOInterface', 'IP Data 0 OUT [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/out1', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/out2', 'IOInterface', 'IP Data 1 OUT [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/out2', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/out3', 'IOInterface', 'DAQ2 DAC Data 0 OUT [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/out3', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/out4', 'IOInterface', 'DAQ2 DAC Data 1 OUT [0:63]');
hdlset_param('daq2_targeting_example/HDL_DUT/out4', 'IOInterfaceMapping', '[0:63]');

% Set Outport HDL parameters
hdlset_param('daq2_targeting_example/HDL_DUT/out5 ', 'IOInterface', 'IP Data Valid OUT');
hdlset_param('daq2_targeting_example/HDL_DUT/out5 ', 'IOInterfaceMapping', '[0]');


%% Workflow Configuration Settings
% Construct the Workflow Configuration Object with default settings
hWC = hdlcoder.WorkflowConfig('SynthesisTool','Xilinx Vivado','TargetWorkflow','IP Core Generation');

% Specify the top level project directory
hWC.ProjectFolder = 'hdl_prj';
hWC.ReferenceDesignToolVersion = '2019.1';
hWC.IgnoreToolVersionMismatch = true;

% Set Workflow tasks to run
hWC.RunTaskGenerateRTLCodeAndIPCore = true;
hWC.RunTaskCreateProject = true;
hWC.RunTaskGenerateSoftwareInterface = true;
hWC.RunTaskBuildFPGABitstream = true;
hWC.RunTaskProgramTargetDevice = false;

% Set properties related to 'RunTaskGenerateRTLCodeAndIPCore' Task
hWC.IPCoreRepository = '';
hWC.GenerateIPCoreReport = true;

% Set properties related to 'RunTaskCreateProject' Task
hWC.Objective = hdlcoder.Objective.None;
hWC.AdditionalProjectCreationTclFiles = '';
hWC.EnableIPCaching = false;

% Set properties related to 'RunTaskGenerateSoftwareInterface' Task
hWC.GenerateSoftwareInterfaceModel = false;
hWC.OperatingSystem = '';
hWC.GenerateSoftwareInterfaceScript = true;

% Set properties related to 'RunTaskBuildFPGABitstream' Task
hWC.RunExternalBuild = true;
hWC.EnableDesignCheckpoint = false;
hWC.TclFileForSynthesisBuild = hdlcoder.BuildOption.Default;
hWC.CustomBuildTclFile = '';
if ispc
    hWC.CustomBuildTclFile = 'adi_build_win.tcl';
else
    hWC.CustomBuildTclFile = 'adi_build.tcl';
end
hWC.DefaultCheckpointFile = 'Default';
hWC.RoutedDesignCheckpointFilePath = '';
hWC.MaxNumOfCoresForBuild = '';

% Set properties related to 'RunTaskProgramTargetDevice' Task
%hWC.ProgrammingMethod = hdlcoder.ProgrammingMethod.Download;

% Validate the Workflow Configuration Object
hWC.validate;

%% Run the workflow
try
    hdlcoder.runWorkflow('daq2_targeting_example/HDL_DUT', hWC, 'Verbosity', 'on');
    bdclose('all');
    out = [];
catch ME
    if exist('hdl_prj/vivado_ip_prj/boot/BOOT.BIN','file')
       ME = [];
    end
    out = ME;%.identifier
end