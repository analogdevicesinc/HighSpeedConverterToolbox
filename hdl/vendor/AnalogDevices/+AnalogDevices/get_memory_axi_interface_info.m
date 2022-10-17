function out = get_memory_axi_interface_info(fpga,project)


switch project
    case 'daq2'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M11_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end

    case 'ad9081'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M11_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    case 'ad9434'
        switch fpga
            case {'ZC706'}
                InterfaceConnection = 'axi_cpu_interconnect/M08_AXI';
                BaseAddress = '0x50000000';
                MasterAddressSpace = 'sys_ps7/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    case 'fmcjesdadc1'
        switch fpga
            case {'ZC706'}
                InterfaceConnection = 'axi_cpu_interconnect/M10_AXI';
                BaseAddress = '0x50000000';
                MasterAddressSpace = 'sys_ps7/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga)); %#ok<*SPERR>
        end
    case 'ad9265'
        switch fpga
            case {'ZC706'}
                InterfaceConnection = 'axi_cpu_interconnect/M08_AXI';
                BaseAddress = '0x50000000';
                MasterAddressSpace = 'sys_ps7/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga));
        end
    case 'ad9739a'
        switch fpga
            case {'ZC706'}
                InterfaceConnection = 'axi_cpu_interconnect/M08_AXI';
                BaseAddress = '0x50000000';
                MasterAddressSpace = 'sys_ps7/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga));
        end
    case 'ad9783'
        switch fpga
            case {'ZCU102'}
                InterfaceConnection = 'axi_cpu_interconnect/M03_AXI';
                BaseAddress = '0x9D000000';
                MasterAddressSpace = 'sys_ps8/Data';
            otherwise
                error(sprintf('Unknown Project FPGA %s/%s',project,fpga));
        end
    otherwise
        error(sprintf('Unknown Project %s',project));
end

out = struct('InterfaceConnection', InterfaceConnection, ...
    'BaseAddress', BaseAddress, ...
    'MasterAddressSpace', MasterAddressSpace);
end
