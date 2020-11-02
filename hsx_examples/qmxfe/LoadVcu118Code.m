function status = LoadVcu118Code(xsctpath, tclpath)
    % LOADFPGACODE Loads FPGA and MicroBlaze images to VCU118
    % Returns -1 if file doesn't exist
    % Returns xsct return value otherwise
    % 0 indicates successful load

    % Default argument values
    if nargin < 2
        % Making my life easier
        xsctpath = "C:\Xilinx\Vitis\2019.2\bin\xsct.bat";
        tclpath = "C:\QuadMxFE\MxFE_Quad_VCU118_v015-2\run.tcl";
    end

    % Check paths exist
    if ~isfile(xsctpath) || ~isfile(tclpath)
        status = -1;
        return;
    end
    
    % Change MATLAB working directory to location of TCL script
    [filepath, name, ext] = fileparts(tclpath);
    oldfolder = cd(filepath);
    
    % Run system call to command XSCT to source run.tcl
    % This TCL script loads the FPGA bitstream and boots Linux
    status = system(strcat(xsctpath, " ", name, ext));

    % Return MATLAB working directory to original location
    cd(oldfolder);
end