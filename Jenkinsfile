@Library('tfc-lib') _

dockerConfig = getDockerConfig(['MATLAB','Vivado'])
dockerConfig.add("-e MLRELEASE=R2020a")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['master','hdl_2018_r2','hdl_2019_r1']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	try {
		withEnv(['HDLBRANCH='+branchName]) {
		    checkout scm
	            sh 'git submodule update --init'
		    sh 'make -C ./CI/scripts build'
		    sh 'make -C ./CI/scripts gen_tlbx'
		}
        } catch(Exception ex) {
		if (branchName == 'hdl_2018_r2') {
		    error('Production Toolbox Build Failed')
		}
		else {
		    unstable('Development Build Failed')
		}
        }
        if (branchName == 'hdl_2018_r2') {
            stash includes: '**', name: 'builtSources', useDefaultExcludes: false
        }
    }
}

/////////////////////////////////////////////////////

boardNames = ['daq2']
dockerConfig.add("-e HDLBRANCH=hdl_2018_r2")

stage("HDL Tests") {
    dockerParallelBuild(boardNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['BOARD='+branchName]) {
            stage("Source") {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
            stage("Installer") {
                unstash "builtSources"
                sh 'make -C ./CI/scripts test_installer'
		junit testResults: 'test/*.xml', allowEmptyResults: true
                archiveArtifacts artifacts: 'test/logs/*', followSymlinks: false, allowEmptyArchive: true
            }
        }
    }
}


/////////////////////////////////////////////////////

classNames = ['DAQ2']

stage("Hardware Streaming Tests") {
    dockerParallelBuild(classNames, dockerHost, dockerConfig) { 
        branchName ->
        withEnv(['HW='+branchName]) {
            unstash "builtSources"
            sh 'echo ${HW}'
            // sh 'make -C ./CI/scripts test_streaming'
        }
    }
}

//////////////////////////////////////////////////////

node('master') {
    stage('Deploy Development') {
        unstash "builtSources"
        uploadArtifactory('HighSpeedConverterToolbox','*.mltbx')
    }
    if (env.BRANCH_NAME == 'master') {
        stage('Deploy Production') {
            unstash "builtSources"
            uploadFTP('HighSpeedConverterToolbox','*.mltbx')
        }
    }
}

