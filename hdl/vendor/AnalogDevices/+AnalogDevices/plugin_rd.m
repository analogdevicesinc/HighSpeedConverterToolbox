function hRD = plugin_rd(project, board, design)
% Reference design definition

%   Copyright 2014-2015 The MathWorks, Inc.

pname = upper(project);
ppath = project;
if strcmpi(project, 'ad9081')
    ppath = 'ad9081_fmca_ebz';
end
if strcmpi(project, 'ad9434')
    ppath = 'ad9434_fmc';
end
if strcmpi(project, 'ad9739a')
    ppath = 'ad9739a_fmc';
end
if strcmpi(project, 'ad9265')
    ppath = 'ad9265_fmc';
end
if strcmpi(project, 'fmcjesdadc1')
    ppath = 'fmcjesdadc1';
end
if strcmpi(project, 'ad9783')
    ppath = 'ad9783_ebz';
end
if strcmpi(project, 'ad9208')
    ppath = 'ad9208_dual_ebz';
end
% Construct reference design object
hRD = hdlcoder.ReferenceDesign('SynthesisTool', 'Xilinx Vivado');

% Create the reference design for the SOM-only
% This is the base reference design that other RDs can build upon
hRD.ReferenceDesignName = sprintf('%s %s (%s)', pname, upper(board), upper(design));

% Determine the board name based on the design
hRD.BoardName = sprintf('AnalogDevices %s %s', pname, upper(board));

% Tool information
%hRD.SupportedToolVersion = {adi.Version.Vivado}; % FIXME
hRD.SupportedToolVersion = {'2022.2'};

% Get the root directory
rootDir = fileparts(strtok(mfilename('fullpath'), '+'));

% Design files are shared
hRD.SharedRD = true;
hRD.SharedRDFolder = fullfile(rootDir, 'vivado');

%% Set top level project pieces
hRD.addParameter( ...
    'ParameterID',   'project', ...
    'DisplayName',   'HDL Project Subfolder', ...
    'DefaultValue',  lower(ppath));

hRD.addParameter( ...
    'ParameterID',   'carrier', ...
    'DisplayName',   'HDL Project Carrier', ...
    'DefaultValue',  lower(board));


%% Add custom design files
% add custom Vivado design
hRD.addCustomVivadoDesign( ...
    'CustomBlockDesignTcl', fullfile('projects', 'scripts', 'system_project_rxtx.tcl'), ...
    'CustomTopLevelHDL',    fullfile('projects', lower(ppath), lower(board), 'system_top.v'));

hRD.BlockDesignName = 'system';

% custom constraint files
hRD.CustomConstraints = {...
    fullfile('projects', lower(ppath), lower(board), 'system_constr.xdc'), ...
    fullfile('projects', 'common', lower(board), sprintf('%s_system_constr.xdc', lower(board))), ...
    };

% custom source files
hRD.CustomFiles = {...
    fullfile('projects')...
    fullfile('library')...
    fullfile('scripts')...
    };

hRD.addParameter( ...
    'ParameterID',   'ref_design', ...
    'DisplayName',   'Reference Type', ...
    'DefaultValue',  lower(strrep(design, ' & ','')));

hRD.addParameter( ...
    'ParameterID',   'fpga_board', ...
    'DisplayName',   'FPGA Boad', ...
    'DefaultValue',  upper(board));

hRD.addParameter( ...
    'ParameterID',   'preprocess', ...
    'DisplayName',   'Preprocess', ...
    'DefaultValue',  'off');

hRD.addParameter( ...
    'ParameterID',   'postprocess', ...
    'DisplayName',   'Postprocess', ...
    'DefaultValue',  'off');

%% Add interfaces
% add clock interface
AnalogDevices.add_clocks(hRD,project,design)

%% Add IO
AnalogDevices.add_io(hRD,project,board,design);
