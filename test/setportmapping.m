function mdl = setportmapping(mode,ReferenceDesignName,board_name)

% ! this script will work with test models that have 16 data ports and 4
% boolean ports

if contains(lower(ReferenceDesignName),'daq2')
    dev = 'DAQ2';
    mdl = 'testModel_RxTx64';
    portWidthRX = 64;
    portWidthTX = 64;
elseif contains(lower(ReferenceDesignName),'ad9081')
    dev = 'AD9081';
    mdl = 'testModel';
    portWidthRX = 16;
    portWidthTX = 16;
elseif contains(lower(ReferenceDesignName),'ad9434')
    dev = 'AD9434';
    mdl = 'testModel_Rx12Tx12';
    portWidthRX = 12;
else
    error('Unknown device');
end

load_system(mdl);

% First set all ports to NIS
for k=1:16
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterfaceMapping', '');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterfaceMapping', '');
end

for k = 1:4
    hdlset_param([mdl,'/HDL_DUT/validIn',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/validIn',num2str(k)], 'IOInterfaceMapping', '');
    hdlset_param([mdl,'/HDL_DUT/validOut',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/validOut',num2str(k)], 'IOInterfaceMapping', '');
end


filePath = '../CI/ports.json';
str = fileread(filePath);
val = jsondecode(str);

fn = fieldnames(val);

for k = 1:numel(fn)
    x = val.(fn{k});
    if (strcmp(x.chip, dev))
        inIndex = 1;
        outIndex = 1;
        validInIndex = 1;
        validOutIndex = 1;
        if (mode == "rx") || (mode == "rxtx")
            rx = x.ports.rx;
            for indexRx = 1:numel(rx)
                element = rx(indexRx);
                if(element.type == "data")
                    if(element.input == "true")
                        hdlset_param([mdl,'/HDL_DUT/in',num2str(inIndex)], 'IOInterface', [element.m_name,' [0:',num2str(portWidthRX-1),']']);
                        hdlset_param([mdl,'/HDL_DUT/in',num2str(inIndex)], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
                        inIndex = inIndex + 1;
                    else
                        hdlset_param([mdl,'/HDL_DUT/out',num2str(outIndex)], 'IOInterface', [element.m_name,' [0:',num2str(portWidthRX-1),']']);
                        hdlset_param([mdl,'/HDL_DUT/out',num2str(outIndex)], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
                        outIndex = outIndex + 1;
                    end
                elseif (element.type == "valid")                   
                    if(element.input == "true")
                        hdlset_param([mdl,'/HDL_DUT/validIn',num2str(validInIndex)], 'IOInterface', element.m_name);
                        hdlset_param([mdl,'/HDL_DUT/validIn',num2str(validInIndex)], 'IOInterfaceMapping', '[0]');
                        validInIndex = validInIndex + 1;
                    else
                        hdlset_param([mdl,'/HDL_DUT/validOut',num2str(validOutIndex)], 'IOInterface', element.m_name);
                        hdlset_param([mdl,'/HDL_DUT/validOut',num2str(validOutIndex)], 'IOInterfaceMapping', '[0]');
                        validOutIndex = validOutIndex + 1;
                    end
                end
            end
    
        end
        if (mode == "tx") || (mode == "rxtx")
            tx = x.ports.tx;
            if (mode == "tx")
                inIndex = 1;
                outIndex = 1;
            end
            for indexTx = 1:numel(tx)
                element = tx(indexTx);
                if(element.type == "data")
                    if(element.input == "true")
                        hdlset_param([mdl,'/HDL_DUT/in',num2str(inIndex)], 'IOInterface', [element.m_name,' [0:',num2str(portWidthTX-1),']']);
                        hdlset_param([mdl,'/HDL_DUT/in',num2str(inIndex)], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
                        inIndex = inIndex + 1;
                    else
                        hdlset_param([mdl,'/HDL_DUT/out',num2str(outIndex)], 'IOInterface', [element.m_name,' [0:',num2str(portWidthTX-1),']']);
                        hdlset_param([mdl,'/HDL_DUT/out',num2str(outIndex)], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
                        outIndex = outIndex + 1;
                    end
                elseif (element.type == "valid")                   
                    if(element.input == "true")
                        hdlset_param([mdl,'/HDL_DUT/validIn',num2str(validInIndex)], 'IOInterface', element.m_name);
                        hdlset_param([mdl,'/HDL_DUT/validIn',num2str(validInIndex)], 'IOInterfaceMapping', '[0]');
                        validInIndex = validInIndex + 1;
                    else
                        hdlset_param([mdl,'/HDL_DUT/validOut',num2str(validOutIndex)], 'IOInterface', element.m_name);
                        hdlset_param([mdl,'/HDL_DUT/validOut',num2str(validOutIndex)], 'IOInterfaceMapping', '[0]');
                        validOutIndex = validOutIndex + 1;
                    end
                end
            end
        end
    end
end
  