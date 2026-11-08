classdef BuildVerificationTests < matlab.unittest.TestCase
    methods(Test)
        function missingArtifactsFail(testCase)
            folder = tempname;
            mkdir(folder);
            cleanup = onCleanup(@() rmdir(folder, 's')); %#ok<NASGU>
            testCase.verifyError(@() verify_build_artifacts(folder, 'ZCU102'), ...
                'adi:MissingBuildArtifact');
        end

        function artifactsAreBoardSpecific(testCase)
            folder = tempname;
            mkdir(folder);
            cleanup = onCleanup(@() rmdir(folder, 's')); %#ok<NASGU>
            files = {fullfile('vivado_prj.runs','impl_1','system_top.bit'), ...
                fullfile('vivado_prj.sdk','system_top.xsa'), ...
                fullfile('vivado_prj.runs','impl_1','hsx_timing_summary.rpt'), ...
                fullfile('vivado_prj.runs','impl_1','hsx_build_verified.txt')};
            for k = 1:numel(files)
                file = fullfile(folder,'vivado_ip_prj',files{k});
                if ~isfolder(fileparts(file))
                    mkdir(fileparts(file));
                end
                fid = fopen(file,'w');
                fprintf(fid,'fixture');
                fclose(fid);
            end
            verify_build_artifacts(folder, 'VCU118');
            testCase.verifyError(@() verify_build_artifacts(folder, 'ZCU102'), ...
                'adi:MissingBuildArtifact');
            % An old boot file outside this project must not satisfy the check.
            fid = fopen(fullfile(folder,'BOOT.BIN'),'w');
            fprintf(fid,'old boot image');
            fclose(fid);
            testCase.verifyError(@() verify_build_artifacts(folder, 'ZCU102'), ...
                'adi:MissingBuildArtifact');
            file = fullfile(folder,'vivado_ip_prj','boot','BOOT.BIN');
            mkdir(fileparts(file));
            fid = fopen(file,'w');
            fclose(fid);
            testCase.verifyError(@() verify_build_artifacts(folder, 'ZCU102'), ...
                'adi:MissingBuildArtifact');
            fid = fopen(file,'w');
            fprintf(fid,'new boot image');
            fclose(fid);
            verify_build_artifacts(folder, 'ZCU102');
        end
    end
end
