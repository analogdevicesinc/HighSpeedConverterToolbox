classdef PFIRDesigner < adi.sim.common.PFilter
    %PFIRDesigner PFIR designer for AD9081
    properties
        %OutputFilename Output Filename
        %   Filename of generated filter file to be loaded by MxFE driver
        OutputFilename = 'ad9081_pfir.cfg'
        %ADCTarget ADC Target
        %   Target ADCs to apply PFilt configuration to. Options are:
        %   'adc_pair_0'   - Update ADC0 and ADC1 PFilt
        %   'adc_pair_1'   - Update ADC2 and ADC3 PFilt
        %   'adc_pair_all' - Update ADC0, ADC1, ADC2, ADC3 PFilt
        ADCTarget = 'adc_pair_all';
        %MemoryTarget Memory Target
        %   Target PFilt memory/pages to apply PFilt configuration to. Options are:
        %   'page_0'   - Apply PFilt config to page table 0
        %   'page_1'   - Apply PFilt config to page table 1
        %   'page_2'   - Apply PFilt config to page table 2
        %   'page_3'   - Apply PFilt config to page table 3
        %   'page_all' - Apply PFilt config to all pages
        MemoryTarget = 'page_all';
    end
    
    properties(Hidden, Constant)
        Version = '0.0.1';
        ADCTargetSet =  matlab.system.StringSet({'adc_pair_0',...
            'adc_pair_1','adc_pair_all'});
        MemoryTargetSet =  matlab.system.StringSet({'page_0','page_1',...
            'page_2','page_3','page_all'});
        FileModes = {...
            'disabled disabled',...          %'NoFilter'
            'real_n disabled',...            %'SingleInphase'
            'disabled real_n',...            %'SingleQuadrature'
            'real_n2 real_n2',...            %'DualReal'
            'complex_half real_n2',...       %'HalfComplexSumInphase'
            'real_n2 complex_half',...       %'HalfComplexSumQuadrature'
            'complex_full complex_full',...  %'FullComplex'
            'matrix matrix'};                %'Matrix'
    end
    
    methods(Access = protected, Hidden)
        function mode = ModeLookup(obj)
            idx = obj.ModeSet.getIndex(obj.Mode);
            mode = obj.FileModes{idx};
        end
        
        function WriteTaps(obj, fid)
            
            taps = int16(obj.Taps);
            
            switch obj.Mode
                case 'NoFilter'
                    error('NoFilter selected. No filter file required');
                case {'SingleInphase','SingleQuadrature'}
                    for k=1:192
                        fprintf(fid,'%d\n',taps(1,k));
                    end
                case {'DualReal','HalfComplexSumInphase','HalfComplexSumQuadrature'}
                    for k=1:192/2
                        fprintf(fid,'%d %d\n',taps(1,k),taps(2,k));
                    end
                case 'FullComplex'
                    for k=1:192/3
                        fprintf(fid,'%d %d\n',taps(1,k),taps(2,k));
                    end
                case 'Matrix'
                    for k=1:192/4
                        fprintf(fid,'%d %d %d %d\n',taps(1,k),taps(2,k),taps(3,k),taps(4,k));
                    end
            end
        end
        
    end
    
    
    methods
        function obj = PFIRDesigner(varargin)
            setProperties(obj,nargin,varargin{:});
        end
        
        function ToFile(obj)
            
            [filters,taps] = size(obj.Taps);
            switch obj.Mode
                case 'NoFilter'
                    error('NoFilter selected. No filter file required');
                case {'SingleInphase','SingleQuadrature'}
                    N = 1;
                case {'DualReal','HalfComplexSumInphase','HalfComplexSumQuadrature'}
                    N = 2;
                case 'FullComplex'
                    N = 3;
                case 'Matrix'
                    N = 4;
            end
            obj.checkFilterDescription(filters,taps,N);
            
            fid = fopen(obj.OutputFilename,'w');
            str = char(obj.Version);
            fprintf(fid, '#Version %s\n', str);
            
            str = '#Mode: <imode> <qmode> ;mode = [disabled|real_n4|real_n2|matrix|complex_full|complex_half|real_n]';
            fprintf(fid, '%s\n', str);
            fprintf(fid, 'mode: %s\n', obj.ModeLookup());
            
            str = '#Gain: <ix> <iy> <qx> <qy> ;gain = [-12|-6|0|6|12]';
            fprintf(fid, '%s\n', str);
            g1 = obj.Gains;
            fprintf(fid, 'gain: %d %d %d %d\n', ...
                g1(1), g1(2), g1(3), g1(4));
            
            str = '#dest: < adc_pair_0|adc_pair_1|adc_pair_all> < page_0|page_1|page_2|page_3|page_all>';
            fprintf(fid, '%s\n', str);
            fprintf(fid, 'dest: %s %s\n', obj.ADCTarget, obj.MemoryTarget);
            
            obj.WriteTaps(fid)
            
            fclose(fid);
            fprintf('PFIR configuration file generated: %s\n',obj.OutputFilename);
        end
        
    end
end

