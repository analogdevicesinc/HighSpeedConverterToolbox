function hRD = plugin_rd(board, design)
% Reference design definition

% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('DAQ2 %s (%s)', upper(board), upper(design));

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices DAQ2 %s', upper(board));

% Tool information
hRD.SupportedToolVersion = {'2018.2'};

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

%% Add custom design files
% add custom Vivado design
hRD.addCustomVivadoDesign( ...
	'CustomBlockDesignTcl', fullfile('projects', 'daq2', lower(board), 'system_project_rxtx.tcl'), ...
	'CustomTopLevelHDL',    fullfile('projects', 'daq2', lower(board), 'system_top.v'));

hRD.BlockDesignName = 'system';

% custom constraint files
hRD.CustomConstraints = {...
    fullfile('projects', 'daq2', lower(board), 'system_constr.xdc'), ...
    fullfile('projects', 'common', lower(board), sprintf('%s_system_constr.xdc', lower(board))), ...
    };

% custom source files
hRD.CustomFiles = {...
    fullfile('projects')...,
	fullfile('library')...,
    };

hRD.addParameter( ...
    'ParameterID',   'ref_design', ...
    'DisplayName',   'Reference Type', ...
    'DefaultValue',  design);

hRD.addParameter( ...
    'ParameterID',   'fpga_board', ...
    'DisplayName',   'FPGA Boad', ...
    'DefaultValue',  upper(board));


%% Add interfaces
% add clock interface
switch(upper(design))
    case 'RX'
        hRD.addClockInterface( ...
            'ClockConnection',   'util_daq2_xcvr/rx_out_clk_0', ...
            'ResetConnection',   'axi_ad9680_jesd_rstgen/peripheral_aresetn');
    case 'TX'
        hRD.addClockInterface( ...
            'ClockConnection',   'util_daq2_xcvr/tx_out_clk_0', ...
            'ResetConnection',   'axi_ad9144_jesd_rstgen/peripheral_aresetn');
%     case 'RX & TX'
%         hRD.addClockInterface( ...
%             'ClockConnection',   'axi_adrv9009_rx_clkgen/clk_0', ...
%             'ResetConnection',   'sys_rstgen/peripheral_aresetn');
    otherwise
        error('Unknown reference design');
end
