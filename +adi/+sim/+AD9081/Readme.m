%% General Information
% All models are implemented as System Objects within the MATLAB language,
% are namespaced under adi.sim, and have separate instantiations of RX
% and TX paths.
%
% All models are instantiated as follows:
% rx = adi.sim.<part name>.<Rx or Tx>;
% Example usage:
% rx = adi.sim.AD9081.Rx;

%% Part Models
% AD9081 Rx Path: adi.sim.AD9081.Rx
% AD9081 Tx Path: adi.sim.AD9081.Tx
% -- Model Information --
% - Not supported -
%   - RX: Complex-to-real conversions are not implemented
%   - RX: Configurable delays after PFilt are not implemented
%   - RX/TX: Delays are not modeled
%   - TX: PA protect and ramp up/down are not implemented
%   - RX/TX: Configurable phase of NCOs are not modeled
% - Baseline tests -
%   - Tests are automated with command: runtests('AD9081Tests')
%   - Make sure all the necessary code is on path
% - Examples
%   - See script ExampleAD9081Rx.m
%   - See script ExampleAD9081RxPFilter.m

%% Authors
% Travis Collins <travis.collins@analog.com>

%% License
% License details are provided in LICENSE file.