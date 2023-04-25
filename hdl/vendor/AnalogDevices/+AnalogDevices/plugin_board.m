function hB = plugin_board(project, board)
% Use Plugin API to create board plugin object

if nargin < 2
    board = "";
end    
hB = hdlcoder.Board;

pname = project;

% Target Board Information
hB.BoardName    = sprintf('AnalogDevices %s', upper(pname));
if nargin > 1
    hB.BoardName    = sprintf('%s %s', hB.BoardName, upper(board));
end

% FPGA Device
hB.FPGAVendor   = 'Xilinx';

% Determine the device based on the board
switch lower(project)
    case {'daq2'}
        switch(upper(board))
            case 'ZCU102'
                hB.FPGADevice   = sprintf('xc%s', 'zu9eg-ffvb1156-2-e');
                hB.FPGAPackage  = '';
                hB.FPGASpeed    = '';
                hB.FPGAFamily   = 'Zynq UltraScale+';
        end
    case {'ad9081'}
        switch(upper(board))
            case 'ZCU102'
                hB.FPGADevice   = sprintf('xc%s', 'zu9eg-ffvb1156-2-e');
                hB.FPGAPackage  = '';
                hB.FPGASpeed    = '';
                hB.FPGAFamily   = 'Zynq UltraScale+';
        end
end

% Tool Info
hB.SupportedTool = {'Xilinx Vivado'};

% FPGA JTAG chain position
hB.JTAGChainPosition = 2;

%% Add interfaces
% Standard "External Port" interface

