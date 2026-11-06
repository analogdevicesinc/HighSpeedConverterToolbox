function [files, matlabPaths] = toolbox_package_files(root, examples)
% Explicit roots keep CI, test outputs and previous installers out of packages.
files = string(fullfile(root, {'LICENSE','README.md','info.xml', ...
    fullfile('CI','doc','ADI_Logo_AWP_Large.png')}))';
folders = {'+adi','hdl'};
matlabPaths = string({root; fullfile(root,'hdl','common'); ...
    fullfile(root,'hdl','vendor','AnalogDevices')});
if isfolder(fullfile(root,'doc'))
    folders{end+1} = 'doc';
    matlabPaths(end+1) = fullfile(root,'doc');
end
if examples
    folders{end+1} = 'hsx_examples';
    examplePaths = string(strsplit(genpath(fullfile(root,'hsx_examples')), pathsep));
    matlabPaths = [matlabPaths; examplePaths(strlength(examplePaths)>0)'];
end
for k = 1:numel(folders)
    entries = dir(fullfile(root,folders{k},'**','*'));
    entries = entries(~[entries.isdir]);
    files = [files; string(fullfile({entries.folder},{entries.name}))']; %#ok<AGROW>
end
% Match MATLAB's repository/project exclusions, including submodule .git files.
normalized = replace(files, '\', '/');
excluded = contains(normalized, '/.git/') | endsWith(normalized, '/.git') | ...
    contains(normalized, '/.svn/') | contains(normalized, '/.buildtool/') | ...
    contains(normalized, '/resources/project/') | endsWith(normalized, '.prj') | ...
    endsWith(normalized, '.asv') | endsWith(normalized, '.mltbx') | endsWith(normalized, '~');
files = unique(files(~excluded));
matlabPaths = unique(matlabPaths);
end
