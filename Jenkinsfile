@Library('tfc-lib@adef-ci') _

flags = gitParseFlags()

dockerConfig = getDockerConfig(['MATLAB','Vivado','Internal'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2023b")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['main','hdl_2022_r2']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	try {
		withEnv(['HDLBRANCH='+branchName,'LC_ALL=C.UTF-8','LANG=C.UTF-8']) {
		    checkout scm
		    sh 'git submodule update --init' 
		    sh 'make -C ./CI/scripts build'
		    sh 'make -C ./CI/scripts gen_tlbx'
		}
        } catch(Exception ex) {
		if (branchName == 'hdl_2022_r2') {
		    error('Production Toolbox Build Failed')
		}
		else {
		    unstable('Development Build Failed')
		}
        }
        if (branchName == 'hdl_2022_r2') {
            local_stash('builtSources')
	    sh 'ls -lR'
            archiveArtifacts artifacts: 'hdl/*', followSymlinks: false, allowEmptyArchive: true
        }
    }
}

/////////////////////////////////////////////////////

boardNames = ['daq2','ad9081','ad9434','ad9739a','ad9265', 'fmcjesdadc1','ad9783']
dockerConfig.add("-e HDLBRANCH=hdl_2022_r2")

cstage("HDL Tests", "", flags) {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            cstage("Source", branchName, flags) {
                local_unstash('builtSources')
                sh 'make -C ./CI/scripts test'
                junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
/*
            stage("Synth") {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test_synth'
                junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
*/
            cstage("Installer", branchName, flags) {
                local_unstash('builtSources')
                sh 'rm -rf hdl'
                sh 'make -C ./CI/scripts test_installer'
                junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
        }
    }
}

/////////////////////////////////////////////////////

def deployments = [:];
def board = 'ad9208';
def nodeLabel = 'baremetal && high_memory';
deployments[board] = { node(nodeLabel) {
    cstage("Baremetal HDL Test", "", flags) {
        withEnv(['BOARD='+board,'MLRELEASE=R2023b','HDLBRANCH=hdl_2022_r2','LC_ALL=C.UTF-8','LANG=C.UTF-8']) {
            try {
                cstage("AD9208 HDL Test", "", flags) {
                    echo "Node: ${env.NODE_NAME}"
                    local_unstash('builtSources', '', false)
                    sh 'make -C ./CI/scripts test'
                    junit testResults: 'test/*.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
                }
            }
            finally {
                cleanWs();
            }
        }
    }
}}

parallel deployments

/////////////////////////////////////////////////////

boardNames = ['NonHW']

cstage("NonHW Tests", "", flags) {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            cstage("NonHW", branchName, flags) {
                local_unstash('builtSources')
                sh 'make -C ./CI/scripts run_NonHWTests'
            }
        }
    }
}


/////////////////////////////////////////////////////

classNames = ['DAQ2']

cstage("Hardware Streaming Tests", "", flags) {
    dockerParallelBuild(classNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['HW='+branchName]) {
            local_unstash("builtSources")
            sh 'echo ${HW}'
            // sh 'make -C ./CI/scripts test_streaming'
        }
    }
}

//////////////////////////////////////////////////////

node('docker') {
    cstage('Deploy Development', "", flags) {
        local_unstash('builtSources', '', false)
        uploadArtifactory('HighSpeedConverterToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        cstage('Deploy Production', "", flags) {
            local_unstash('builtSources', '', false)
            uploadArtifactory('HighSpeedConverterToolbox','*.mltbx')
        }
    }
}

//////////////////////////////////////////////////////
// boardNames = ['daq2','ad9081']
// dockerConfig.add("-e HDLBRANCH=hdl_2019_r2")

// stage("HDL Tests") {
//     dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
//         branchName ->
//         withEnv(['BOARD='+branchName]) {
//             stage("Synth") {
//                 unstash "builtSources"
//                 sh 'make -C ./CI/scripts test_synth'
//                 junit testResults: 'test/*.xml', allowEmptyResults: true
//                 archiveArtifacts artifacts: 'test/**/*.log', followSymlinks: false, allowEmptyArchive: true
//             }
//         }
//     }
// }
//
