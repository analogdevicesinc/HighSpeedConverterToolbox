%% Signal Generation

clear all; close all;

%% Initialize DUT
x = quadApollo('ip:192.168.2.1'); % create quadApollo Object
x.initialize;                % Initialize quadApollo

% Setup antenna model
arraySize = [4 4];
spacing = freq2wavelen(11e9)/2;
c = physconst('LightSpeed');
ura = phased.URA('Size', arraySize, 'ElementSpacing', [spacing spacing]);

% Configure quadApollo NCOs
fc = 10.42e9;
x.setTxNCOFreq('Main', fc .* ones(1,16))
x.setRxNCOFreq('Main', (fc-12.8e9) .* ones(1,16))

calData = x.rx(); 
calweights = sourceCalibration(calData,[0,0],ura,fc,1);
calweights = rad2deg(angle(calweights));


% Generate source signals
nSamples = 8192;

%% --- Ask user for jammer angles (supports multiple) ---
defaultStr = "10,30"; % one jammer at [az=10, el=30]
ansStr = inputdlg( ...
    {'Enter jammer az,el pairs (deg). Example: 10,30; -20,10'}, ...
    'Jammer Angles', 1, {char(defaultStr)});
jamAngs = parseAnglePairs(ansStr);   % 2xN matrix (az;el)

% Targets of interest (TOI) — initial (will be randomized in live loop)
toiAngs = [-30;-60];
toiScale = 500;
toiSig = toiScale * exp(1i * (rand(nSamples,1) - 0.5) * 2*pi);

% Jammers (user-specified above)
jamScale = 8000;
nJammers = size(jamAngs,2);
jamSig   = jamScale * exp(1i * (rand(nSamples,nJammers) - 0.5) * 2*pi); % one col per jammer

% Simulate received signals using plane wave model
jamOnlyWave = ura.collectPlaneWave(jamSig, jamAngs, fc);  % supports multiple jammers
jamOnlyWave(:,1) = jamOnlyWave(:,1)*exp(1i*pi);
toiOnlyWave = ura.collectPlaneWave(toiSig, toiAngs, fc);
toiOnlyWave(:,1) = toiOnlyWave(:,1)*exp(1i*pi);
comboWave = jamOnlyWave + toiOnlyWave;

%% Collect data prior to calibration

% Put board into loopback mode
x.calBrdAdjacentLoopback;

% Collect jam only signal
x.txWaveform(jamOnlyWave);
pause(0.1);
jamSigRxPrecal = x.rx();

% Collect combined signal
x.txWaveform(comboWave);
pause(0.1);
comboSigRxPrecal = x.rx();

%% Perform calibration

[txPhaseOffset, rxPhaseOffset] = x.systemCal;
x.setTxNCOPhase('Main',(wrapTo180(txPhaseOffset))*1e3);
x.setRxNCOPhase('Main',rxPhaseOffset*1e3);

%% Collect data after calibration (LIVE LOOP)

% Put board into loopback mode (once for the live run)
x.calBrdAdjacentLoopback;

% Live updates: TOI randomizes; jammers stay at user-entered angles
% (Use Ctrl-C to stop; figures are reused by analyzeCollectedData)
while true
    % Randomize TOI angles each iteration: [-90, +90] deg (az, el)
    toiAngs = (rand(2,1)*180 - 90);

    % Fresh random complex baseband per jammer (columns)
    nJammers = size(jamAngs,2);
    jamSig   = jamScale * exp(1i * (rand(nSamples,nJammers) - 0.5) * 2*pi);

    % New TOI signal
    toiSig = toiScale * exp(1i * (rand(nSamples,1) - 0.5) * 2*pi);

    % Plane waves for current angles
    jamOnlyWave = ura.collectPlaneWave(jamSig, jamAngs, fc);
    jamOnlyWave(:,1) = jamOnlyWave(:,1)*exp(1i*pi);
    toiOnlyWave = ura.collectPlaneWave(toiSig, toiAngs, fc);
    toiOnlyWave(:,1) = toiOnlyWave(:,1)*exp(1i*pi);
    comboWave = jamOnlyWave + toiOnlyWave;

    % Jam-only capture
    x.txWaveform(jamOnlyWave);
    pause(0.05);
    jamSigRx = x.rx();

    % Combined capture
    x.txWaveform(comboWave);
    pause(0.05);
    comboSigRx = x.rx();

    % Analyze & update existing figures (function uses persistent axes)
    analyzeCollectedData(ura,jamAngs,toiAngs,jamSigRx,comboSigRx,toiSig,fc);
    %analyzeCollectedData(ura,jamAngs,toiAngs,jamSigRx,comboSigRx,fc);

    drawnow limitrate;   % smooth UI updates without reopening figures
    % pause(0.02);       % optional: slow the update rate
end



%% ------------ local helper ------------
function angMat = parseAnglePairs(ansStr)
% Parse "az,el; az,el; ..." into a 2xN double matrix. Clamps to [-90,90].
    if isempty(ansStr) || ~iscell(ansStr), ansStr = {''}; end
    s = strtrim(ansStr{1});
    if isempty(s)
        angMat = [10;30]; % fallback default
        return;
    end
    parts = regexp(s,';','split');
    az = []; el = [];
    for k = 1:numel(parts)
        nums = sscanf(parts{k},'%f,%f');
        if numel(nums)~=2, continue; end
        az(end+1) = nums(1); %#ok<AGROW>
        el(end+1) = nums(2); %#ok<AGROW>
    end
    if isempty(az)
        angMat = [10;30]; % fallback default
    else
        % Clamp to valid scan range
        az = max(-90, min(90, az));
        el = max(-90, min(90, el));
        angMat = [az; el];
    end
end

function analyzeCollectedData(array,jamAngs,toiAng,jamOnlyWave,comboWave,expWave,fc)

% Get number of jammers and targets of interest
nJammers = size(jamAngs,2);
nTois = size(toiAng,2);

% Direction of Arrival Estimation using MUSIC
music = phased.MUSICEstimator2D(SensorArray=array, ...
    OperatingFrequency=fc, ...
    AzimuthScanAngles=-90:90,...
    ElevationScanAngles=-90:90,...
    NumSignalsSource="Property", ...
    NumSignals=nJammers+nTois);

% Plot MUSIC spectrum
resp = music(comboWave);
plotMusicSpectrum(resp, music.AzimuthScanAngles, music.ElevationScanAngles, toiAng, jamAngs);

bs = phased.BeamscanEstimator2D(SensorArray=array,...
    OperatingFrequency=fc,...
    AzimuthScanAngles=-90:90,...
    ElevationScanAngles=-90:90);

% Plot beamscan spectrum
resp2 = bs(comboWave);
plotBeamscanSpectrum(resp2, bs.AzimuthScanAngles, bs.ElevationScanAngles, toiAng, jamAngs);

% Beamforming
ps = phased.PhaseShiftBeamformer(SensorArray=array, ...
    OperatingFrequency=fc, ...
    Direction=toiAng, ...
    WeightsOutputPort=true);
[pssig,psWeights] = ps(comboWave);

mvdr = phased.MVDRBeamformer(SensorArray=array, ...
    OperatingFrequency=fc, ...
    Direction=toiAng, ...
    TrainingInputPort=true, ...
    WeightsOutputPort=true);
[mvdrsig,mvdrWeights] = mvdr(comboWave, jamOnlyWave);

% Visualizations
plotPsPattern(array, fc, psWeights, toiAng, jamAngs);           % (no gains)
plotMvdrPattern(array, fc, mvdrWeights, toiAng, jamAngs);       % (adds gains sidebar)
plotMvdrPatternRectAz(array, fc, mvdrWeights, toiAng, jamAngs);  % 1D az sweep @ TOI elevation
plotMvdrPatternRectEl(array, fc, mvdrWeights, toiAng, jamAngs);  % 1D el sweep @ TOI azimuth


% Visualize matched filter correlation between bf signal and toi
plotToiCorrelation(expWave,{pssig,mvdrsig},{'Phase Shift Beamformer','MVDR Beamformer'});

%% -------------------- helpers --------------------

function plotMusicSpectrum(resp, azAngles, elAngles, toiAng, jamAngs)
    % Reuse (or create) a figure named 'MUSIC Spectrum' with a tagged axes
    [f, ax, htxt] = getFig('MUSIC Spectrum', 'musicAxes', true);

    cla(ax); hold(ax,"on");
    imagesc(ax,azAngles,elAngles,mag2db(resp));
    title(ax,'MUSIC Spectrum');
    scatter(ax, toiAng(1,:),toiAng(2,:), 'filled', 'DisplayName','Source Location');
    scatter(ax, jamAngs(1,:), jamAngs(2,:), 'filled', 'DisplayName','Jammer Location');
    xlabel(ax,'Azimuth Angle'); ylabel(ax,'Elevation Angle');
    ylim(ax,[min(elAngles) max(elAngles)]);
    xlim(ax,[min(azAngles) max(azAngles)]);
    legend(ax,'show','Location','southoutside');

    set(htxt,'String', angleSidebarText(toiAng, jamAngs));
end

function plotBeamscanSpectrum(resp, azAngles, elAngles, toiAng, jamAngs)
    % Reuse (or create) a figure named 'MUSIC Spectrum' with a tagged axes
    [f, ax, htxt] = getFig('Beamscan Spectrum', 'musicAxes', true);

    cla(ax); hold(ax,"on");
    imagesc(ax,azAngles,elAngles,mag2db(resp));
    title(ax,'Beamscan Spectrum');
    scatter(ax, toiAng(1,:),toiAng(2,:), 'filled', 'DisplayName','Source Location');
    scatter(ax, jamAngs(1,:), jamAngs(2,:), 'filled', 'DisplayName','Jammer Location');
    xlabel(ax,'Azimuth Angle'); ylabel(ax,'Elevation Angle');
    ylim(ax,[min(elAngles) max(elAngles)]);
    xlim(ax,[min(azAngles) max(azAngles)]);
    legend(ax,'show','Location','southoutside');

    set(htxt,'String', angleSidebarText(toiAng, jamAngs));
end

function plotPsPattern(array, fc, weights, toiAng, jamAngs)
    tstr = "Phase Shift Beam-Pattern";
    plotBeamPattern(array,fc,weights,toiAng,jamAngs,tstr,"");
end


function plotMvdrPattern(array, fc, weights, toiAng, jamAngs)
    % Compute per-DOA gains (dB) and pass as extra sidebar text
    toiGainDb = pattern(array, fc, toiAng(1), toiAng(2), ...
                        Weights=weights, CoordinateSystem='rectangular');
    jamGainDb = zeros(1,size(jamAngs,2));
    for k = 1:size(jamAngs,2)
        jamGainDb(k) = pattern(array, fc, jamAngs(1,k), jamAngs(2,k), ...
                               Weights=weights, CoordinateSystem='rectangular');
    end
    extra = gainsSidebarText(toiGainDb, jamGainDb);
    plotBeamPattern(array,fc,weights,toiAng,jamAngs,"MVDR Beam-Pattern",extra);
end

function plotMvdrPatternRectAz(array, fc, weights, toiAng, jamAngs)
    % 1D azimuth sweep at fixed elevation (TOI elevation), matches 2D grid exactly.
    [~, ax] = getFig('MVDR Beam Pattern (Az Cut)', 'mvdrRectAzAxes', false);

    azAngles = -90:90;            % keep in sync with 2D plot
    elAngles = -90:90;
    elCut = toiAng(2);
    [~, elIdx] = min(abs(elAngles - elCut));

    % Compute 2D on same grid, then slice the exact row
    respDb2D = pattern(array, fc, azAngles, elAngles, ...
                       Weights=weights, CoordinateSystem='rectangular');
    respSlice = respDb2D(elIdx, :);

    h = getappdata(ax,'mvdrRectAz');
    if isempty(h) || ~isfield(h,'resp') || ~isvalid(h.resp)
        cla(ax); hold(ax,"on");
        h.resp = plot(ax, azAngles, respSlice, 'LineWidth',1.5, 'DisplayName','MVDR response');
        h.toi  = xline(ax, toiAng(1), '--g', 'TOI', 'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
        nj = size(jamAngs,2);
        h.jams = gobjects(1,nj);
        for k = 1:nj
            h.jams(k) = xline(ax, jamAngs(1,k), '--r', sprintf('JAM%d',k), ...
                              'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
        end
        grid(ax,'on'); xlabel(ax,'Azimuth (deg)'); ylabel(ax,'Gain (dB)');
        title(ax, sprintf('MVDR Azimuth Cut  |  El cut = %+.1f° (grid idx %d)', elAngles(elIdx), elIdx));
        legend(ax,'Location','best');
    else
        set(h.resp, 'XData', azAngles, 'YData', respSlice);
        h.toi.Value = toiAng(1);
        nj = size(jamAngs,2);
        if numel(h.jams) ~= nj || any(~isvalid(h.jams))
            try, delete(h.jams(ishandle(h.jams))); catch, end
            h.jams = gobjects(1,nj);
            for k = 1:nj
                h.jams(k) = xline(ax, jamAngs(1,k), '--r', sprintf('JAM%d',k), ...
                                  'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
            end
        else
            for k = 1:nj, h.jams(k).Value = jamAngs(1,k); end
        end
        ax.Title.String = sprintf('MVDR Azimuth Cut  |  El cut = %+.1f° (grid idx %d)', elAngles(elIdx), elIdx);
    end
    setappdata(ax,'mvdrRectAz',h);
end

function plotMvdrPatternRectEl(array, fc, weights, toiAng, jamAngs)
    % 1D elevation sweep at fixed azimuth (TOI azimuth), matches 2D grid exactly.
    [~, ax] = getFig('MVDR Beam Pattern (El Cut)', 'mvdrRectElAxes', false);

    azAngles = -90:90;            % keep in sync with 2D plot
    elAngles = -90:90;
    azFix = toiAng(1);
    [~, azIdx] = min(abs(azAngles - azFix));

    % Compute 2D on same grid, then slice the exact column
    respDb2D = pattern(array, fc, azAngles, elAngles, ...
                       Weights=weights, CoordinateSystem='rectangular');
    respSlice = respDb2D(:, azIdx).';   % row vector

    h = getappdata(ax,'mvdrRectEl');
    if isempty(h) || ~isfield(h,'resp') || ~isvalid(h.resp)
        cla(ax); hold(ax,"on");
        h.resp = plot(ax, elAngles, respSlice, 'LineWidth',1.5, 'DisplayName','MVDR response');
        h.toi  = xline(ax, toiAng(2), '--g', 'TOI', 'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
        nj = size(jamAngs,2);
        h.jams = gobjects(1,nj);
        for k = 1:nj
            h.jams(k) = xline(ax, jamAngs(2,k), '--r', sprintf('JAM%d',k), ...
                              'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
        end
        grid(ax,'on'); xlabel(ax,'Elevation (deg)'); ylabel(ax,'Gain (dB)');
        title(ax, sprintf('MVDR Elevation Cut  |  Az fix = %+.1f° (grid idx %d)', azAngles(azIdx), azIdx));
        legend(ax,'Location','best');
    else
        set(h.resp, 'XData', elAngles, 'YData', respSlice);
        h.toi.Value = toiAng(2);
        nj = size(jamAngs,2);
        if numel(h.jams) ~= nj || any(~isvalid(h.jams))
            try, delete(h.jams(ishandle(h.jams))); catch, end
            h.jams = gobjects(1,nj);
            for k = 1:nj
                h.jams(k) = xline(ax, jamAngs(2,k), '--r', sprintf('JAM%d',k), ...
                                  'LabelVerticalAlignment','bottom', 'HandleVisibility','off');
            end
        else
            for k = 1:nj, h.jams(k).Value = jamAngs(2,k); end
        end
        ax.Title.String = sprintf('MVDR Elevation Cut  |  Az fix = %+.1f° (grid idx %d)', azAngles(azIdx), azIdx);
    end
    setappdata(ax,'mvdrRectEl',h);
end




function plotBeamPattern(array,fc,weights,toiAng,jamAngs,tstr,extraText)
    % Reuse (or create) a figure by title (tstr) with a tagged axes
    nameStr = char(tstr);                                    % ensure char
    axTag   = ['beamAxes_' matlab.lang.makeValidName(nameStr)];  % valid tag
    [f, ax, htxt] = getFig(nameStr, axTag, true);


    cla(ax); hold(ax,"on");
    azAngles = -90:90; elAngles = -90:90;
    respDb = pattern(array,fc,azAngles,elAngles,Weights=weights,CoordinateSystem='rectangular');

    imagesc(ax,azAngles,elAngles,respDb);
    scatter(ax, toiAng(1,:),toiAng(2,:), 'filled', 'DisplayName','Source Location');
    scatter(ax, jamAngs(1,:), jamAngs(2,:), 'filled', 'DisplayName','Jammer Location');

    xlabel(ax,'Azimuth Angle (deg)'); ylabel(ax,'Elevation Angle (deg)');
    title(ax, tstr); colorbar(ax); view(ax,[0 90]);
    ylim(ax,[min(elAngles) max(elAngles)]); xlim(ax,[min(azAngles) max(azAngles)]);
    legend(ax,'show','Location','southoutside');

    % Sidebar text: angles + optional gains (for MVDR)
    baseTxt = angleSidebarText(toiAng, jamAngs);
    if ~isempty(extraText)
        set(htxt,'String', sprintf('%s\n%s', baseTxt, extraText));
    else
        set(htxt,'String', baseTxt);
    end
end



function txt = angleSidebarText(toiAng, jamAngs)
    deg = char(176);
    txt = sprintf('TOI (az, el):\n[%+.1f%s, %+.1f%s]\n\nJammers:\n', ...
        toiAng(1),deg, toiAng(2),deg);
    for k = 1:size(jamAngs,2)
        txt = sprintf('%s[%+.1f%s, %+.1f%s]\n', txt, jamAngs(1,k),deg, jamAngs(2,k),deg);
    end
end

function txt = gainsSidebarText(toiGainDb, jamGainDb)
    % Build an extra block for MVDR gains
    txt = sprintf('Gains (MVDR, dB):\nTOI: %+.1f dB\n', toiGainDb);
    for k = 1:numel(jamGainDb)
        txt = sprintf('%sJAM%d: %+.1f dB\n', txt, k, jamGainDb(k));
    end
end

function plotToiCorrelation(expWave,bfsignals,bfalgorithms)
    % Reuse (or create) a figure named 'Correlation: TOI vs Beamformed Outputs'
    [~, ax] = getFig('Correlation: TOI vs Beamformed Outputs', 'corrAxes', false);

    cla(ax); hold(ax,"on");
    nSignals = numel(bfsignals);
    for iSig = 1:nSignals
        sig = bfsignals{iSig}(:);
        exp = expWave(:);
        [c,lags] = xcorr(exp, sig);
        c_db = mag2db(abs(c) / max(abs(c) + eps));
        plot(ax, lags, c_db, 'DisplayName', bfalgorithms{iSig});
    end
    title(ax,'Correlation With Target-Only Estimate');
    ylabel(ax,'Correlation (dB)');
    xlabel(ax,'Sample Delay');
    legend(ax,'Location','best');
    grid(ax,'on');
end



end

function [f, ax, htxt] = getFig(figName, axTag, withSidebar)
% Find-or-create a figure by name and a tagged axes inside it.
% Returns: figure handle f, axes handle ax, and (optionally) a right sidebar textbox htxt.

    % Find existing figure by name
    f = findobj(0,'Type','figure','Name',figName);
    if isempty(f) || ~ishandle(f)
        f = figure('Name',figName,'NumberTitle','off','Color','w');
    end

    % Find existing axes by tag
    ax = findobj(f,'Type','axes','-and','Tag',axTag);
    if isempty(ax) || ~ishandle(ax)
        clf(f);  % clear figure if we’re creating axes fresh
        ax = axes('Parent',f,'Tag',axTag);
        if withSidebar
            set(ax,'Position',[0.08 0.12 0.68 0.8]); % leave room for sidebar
        end
    end

    % Optional sidebar textbox (created once per figure)
    htxt = [];
    if withSidebar
        htxt = findobj(f,'Type','textboxshape','Tag',[axTag '_sidebar']);
        if isempty(htxt) || ~ishandle(htxt)
            htxt = annotation(f,'textbox','Units','normalized', ...
                'Position',[0.78 0.12 0.20 0.76], ...
                'Tag',[axTag '_sidebar'], ...
                'EdgeColor','none','BackgroundColor','w', ...
                'FontSize',10,'HorizontalAlignment','left');
        end
    end
end

function calweights = sourceCalibration(sig,trueAoa,array,fc,refel)

arguments
    sig (:,:) % This is the captured signal
    trueAoa (2,1) % This is the actual angle of arrival in (Az;El)
    array % This is the model of the array used to capture data
    fc (1,1) % This is the carrier frequency being used to capture data
    refel (1,1) % This is the reference element used to calibrate to
end

% Get the expected steering vector
svobj = phased.SteeringVector(SensorArray=array);
sv = svobj(fc,trueAoa);
svnorm = sv/sv(refel);

% Get the complex amplitude between each channel and the reference channel
refsig = sig(:,refel);
weights = transpose(sig)/transpose(refsig);

calweights = svnorm./weights;


end


