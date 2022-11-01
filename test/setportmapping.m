function mdl = setportmapping(mode,ReferenceDesignName,board_name)

%mdl = 'testModel';
numChannels = 2;

if mod(numChannels,2)~=0
    error('Channels must be multiple of 2');
end

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
    numChannels = 8;
else
    error('Unknown device');
end

load_system(mdl);

% First set all ports to NIS
% should be set acording to the test model used
for k=1:16
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterfaceMapping', '');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterfaceMapping', '');
end

% should be set acording to the test model used
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
        
% switch mode
%     case 'tx'
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', ['IP Data 0 IN [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', ['IP Data 1 IN [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', [dev,' DAC Data 0 OUT [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', [dev,' DAC Data 1 OUT [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         if numChannels==4
%             hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', ['IP Data 2 IN [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', ['IP Data 3 IN [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', [dev,' DAC Data 2 OUT [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', [dev,' DAC Data 3 OUT [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         end
%     case 'rx'
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', [dev,' ADC Data  AXI AD9680 TPL ADC DATA 0 IN [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', [dev,' ADC Data  AXI AD9680 TPL ADC DATA 1 IN [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', ['IP Data  AXI AD9680 CPACK FIFO WR DATA 0 OUT [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', ['IP Data  AXI AD9680 CPACK FIFO WR DATA 1 OUT [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         if numChannels==4
%              hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', [dev,' ADC Data 2 IN [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', [dev,' ADC Data 3 IN [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', ['IP Data 2 OUT [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', ['IP Data 3 OUT [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         end
%     case 'rxtx'
%         % RX
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', [dev,' ADC Data 0 IN [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', [dev,' ADC Data 1 IN [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', ['IP Data 0 OUT [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', ['IP Data 1 OUT [0:',num2str(portWidthRX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%         % TX
%         hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', ['IP Data 0 IN [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', ['IP Data 1 IN [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', [dev,' DAC Data 0 OUT [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', [dev,' DAC Data 1 OUT [0:',num2str(portWidthTX-1),']']);
%         hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         
%         
%         if numChannels==4
%             hdlset_param([mdl,'/HDL_DUT/in5'], 'IOInterface', [dev,' ADC Data 2 IN [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in5'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in6'], 'IOInterface', [dev,' ADC Data 3 IN [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in6'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out5'], 'IOInterface', ['IP Data 2 OUT [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out5'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out6'], 'IOInterface', ['IP Data 3 OUT [0:',num2str(portWidthRX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out6'], 'IOInterfaceMapping', ['[0:',num2str(portWidthRX-1),']']);
% 
%             hdlset_param([mdl,'/HDL_DUT/in7'], 'IOInterface', ['IP Data 2 IN [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in7'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in8'], 'IOInterface', ['IP Data 3 IN [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/in8'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out7'], 'IOInterface', [dev,' DAC Data 2 OUT [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out7'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out8'], 'IOInterface', [dev,' DAC Data 3 OUT [0:',num2str(portWidthTX-1),']']);
%             hdlset_param([mdl,'/HDL_DUT/out8'], 'IOInterfaceMapping', ['[0:',num2str(portWidthTX-1),']']);
%         end
%         
%     otherwise
%         error('Unknown mode');
%end
