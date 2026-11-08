classdef PackageManifestTests < matlab.unittest.TestCase
    properties
        Root
    end
    methods(TestClassSetup)
        function addScripts(testCase)
            original = path;
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'CI','scripts'));
            testCase.addTeardown(@() path(original));
        end
    end
    methods(TestMethodSetup)
        function createFixture(testCase)
            testCase.Root = tempname;
            mkdir(testCase.Root);
            testCase.addTeardown(@() rmdir(testCase.Root,'s'));
            names = {'LICENSE','README.md','info.xml','CI/doc/ADI_Logo_AWP_Large.png', ...
                '+adi/Version.m','+adi/+common/Debug.m','+adi/+common/.git', ...
                'hdl/common/Contents.m','hdl/vendor/AnalogDevices/plugin.m', ...
                'hdl/vendor/AnalogDevices/vivado/quiet.mk', ...
                'hdl/vendor/AnalogDevices/vivado/HSX_UPSTREAM_COMMIT', ...
                'doc/index.html','hsx_examples/demo/example.m', ...
                'test/nested/build/system_top.bit','CI/scripts/private.m', ...
                'previous.mltbx','hdl/stale.prj','+adi/autosave.asv'};
            for name = names
                file = fullfile(testCase.Root,name{1});
                if ~isfolder(fileparts(file))
                    mkdir(fileparts(file));
                end
                fid = fopen(file,'w');
                fprintf(fid,'fixture');
                fclose(fid);
            end
        end
    end
    methods(Test)
        function excludesBuildArtifactsAndRepositoryMetadata(testCase)
            [files, paths] = toolbox_package_files(testCase.Root,true);
            relative = replace(erase(files,string(testCase.Root)+filesep),'\','/');
            testCase.verifyFalse(any(startsWith(relative,'test/')));
            testCase.verifyEqual(relative(startsWith(relative,'CI/')), "CI/doc/ADI_Logo_AWP_Large.png");
            testCase.verifyFalse(any(endsWith(relative,{'.git','.prj','.asv','.mltbx'})));
            testCase.verifyTrue(any(endsWith(relative,'/quiet.mk')));
            testCase.verifyTrue(any(endsWith(relative,'/HSX_UPSTREAM_COMMIT')));
            testCase.verifyTrue(any(relative == "+adi/+common/Debug.m"));
            testCase.verifyTrue(any(relative == "hsx_examples/demo/example.m"));
            testCase.verifyFalse(any(contains(paths,fullfile('hdl','vendor','AnalogDevices','vivado'))));
        end
        function respectsNoExamplesAndOptionalDocumentation(testCase)
            rmdir(fullfile(testCase.Root,'doc'),'s');
            [files, paths] = toolbox_package_files(testCase.Root,false);
            testCase.verifyFalse(any(contains(files,'hsx_examples')));
            testCase.verifyFalse(any(contains(paths,'hsx_examples')));
            testCase.verifyFalse(any(paths == string(fullfile(testCase.Root,'doc'))));
        end
    end
end
