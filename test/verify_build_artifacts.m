function verify_build_artifacts(folder, board)
% Only accept artifacts from this workflow's fresh project directory.
project = fullfile(folder, 'vivado_ip_prj');
required = {fullfile('vivado_prj.runs', 'impl_1', 'system_top.bit'), ...
    fullfile('vivado_prj.sdk', 'system_top.xsa'), ...
    fullfile('vivado_prj.runs', 'impl_1', 'hsx_timing_summary.rpt'), ...
    fullfile('vivado_prj.runs', 'impl_1', 'hsx_build_verified.txt')};
if ~contains(lower(board), 'vcu118')
    required{end+1} = fullfile('boot', 'BOOT.BIN');
end
for k = 1:numel(required)
    artifact = fullfile(project, required{k});
    info = dir(artifact);
    assert(~isempty(info) && info.bytes > 0, 'adi:MissingBuildArtifact', ...
        'Missing or empty build artifact: %s', artifact);
end
end
