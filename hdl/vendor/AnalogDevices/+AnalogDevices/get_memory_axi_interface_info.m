function out = get_memory_axi_interface_info(fpga,project)


switch project
    case 'daq2'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M09_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    case 'ad9081'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M09_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    case 'ad9783'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M03_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    otherwise
        error(sprintf('Unknown Project %s',project)); %#ok<*SPERR>
end

out = struct('InterfaceConnection', InterfaceConnection, ...
    'BaseAddress', BaseAddress, ...
    'MasterAddressSpace', MasterAddressSpace);
end