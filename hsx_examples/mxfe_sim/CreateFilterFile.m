% Create an example 192 length filter and generate filter file for hardware
pfir = adi.sim.AD9081.PFIRDesigner;
pfir.Mode = 'SingleInphase';
N = 192;
taps = randn(1,N).*2^6;
% Find best tap quantization for given filter
[config,tapsInt16,qt] = adi.AD9081.utils.DesignPFilt(taps,pfir.Mode,N);
% Update model
pfir.Taps = qt;
pfir.TapsWidthsPerQuad = config;
% Create filter file
pfir.ToFile();