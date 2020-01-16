function [config,taps,quantizedTaps] = DesignPFilt(taps,mode,realModeLength)

% Checks
switch mode
    case {'SingleInphase','DualReal','SingleQuadrature'}
        if nargin<3
            error('Must supply required length for non-crossbar filters');
        end
        if realModeLength == 192
            N = 192;
        elseif realModeLength == 192
            N = 96;
        else
            error('For independent filters (non-complex) lengths must be 96 or 192');
        end
    case {'HalfComplexSumInphase','HalfComplexSumQuadrature'}
        N = 96;
    case 'FullComplex'
        N = 64;
    case 'Matrix'
        N = 48;
end

if length(taps)>N
    error(['Max possible taps is ',num2str(N)]);
end

% Scale taps
taps = taps./max(abs(taps));
taps = taps.*(2^(16-1));

%% Find best possible configuration that maintains precision
[config, quantizedTaps] = findBestBitArrangement(taps,N);


end


% function [mode,quantizedTaps] = findBestBitArrangement(taps,N)
% 
% reps = N/(192/4);
% 
% tapGroups = {};
% for k=1:4:N
%     tapGroups = [tapGroups(:)',{taps(k:k+3)}];
% end
% 
% % Arrange
% Taps16bit = [16,16,16];
% 
% N = N/4;
% Taps16bitAll = repmat(Taps16bit,1,reps);
% L = length(Taps16bitAll);
% PossibleCasts = [];
% loops = N-L;
% for leading12s = 0:L
%     for offset16 = 0:loops-L
%         PossibleCast = zeros(1,N);
%         % Place 16 bit markers
%         start = 1+leading12s+offset16; last = L+leading12s+offset16;
%         PossibleCast(start:last) = 16;
%         % Place 12 bit markers
%         PossibleCast(start-leading12s:start-1) = 12;
%         PossibleCast(last+1:last+L-leading12s) = 12;
%         % Place 6 bit markers
%         PossibleCast(PossibleCast==0) = 6;
%         PossibleCasts = [PossibleCasts; PossibleCast]; %#ok<*AGROW>
%     end
% end
% 
% error = zeros(size(PossibleCasts,1),1);
% for leading12s = 1:size(PossibleCasts,1)
%     for group = 1:length(tapGroups)
%         config = PossibleCasts(leading12s,group);
%         tg = tapGroups{group};
%         diff = abs( double(fi(tg,1,config,config-16)) - double(tg));
%         error(leading12s) = error(leading12s) + sum(diff);
%     end
% end
% 
% [~,bestCast] = min(error);
% plot(sort(error));
% 
% mode = PossibleCasts(bestCast,:);
% 
% %% Apply new types to taps
% quantizedTaps = length(taps);
% for group = 1:length(tapGroups)
%     config = PossibleCasts(bestCast,group);
%     tg = tapGroups{group};
%     quantizedTaps( (group-1)*4+1 : group*4) = int16((fi(tg,1,config,config-16)));
% end
% 
% end