# Usage:
#	make <target> MLRELEASE=<MATLAB release version ex: R2018b> HDLBRANCH=<HDL git branch ex: hdl_2018_r1>
# Example
#	make build MLRELEASE=R2018b HDLBRANCH=hdl_2018_r1

SHELL := /bin/bash

MLFLAGS := -nodisplay -nodesktop -nosplash
MATLAB_BIN ?= matlab
MATLAB_RELEASE_ASSERT = actual=regexprep(version('-release'),'^R',''); expected=regexprep('$(MLRELEASE)','^R',''); assert(strcmpi(actual,expected),'Expected MATLAB %s, found %s',expected,actual);

ifeq ($(MLRELEASE),)
MLRELEASE := R2025b
endif

ifeq ($(HDLBRANCH),)
HDLBRANCH := hdl_2026_r1
endif

ifeq ($(OS),Windows_NT)
MLFLAGS := $(MLFLAGS) -wait
endif

ifeq ($(BOARD),)
BOARD :=
endif

ifeq ($(INCLUDE_EXAMPLES),)
INCLUDE_EXAMPLES := 1
endif

GITTAG := $(shell git describe --tags HEAD 2>/dev/null || printf 'untagged')

.ONESHELL:
build:
	# Uses the HDLBRANCH variable
	bash build_bsp.sh

add_libad9361:
	cd ../.. ; \
	mkdir deps ; \
	cd deps ; \
	mkdir linux ; \
	cd linux ; \
	wget http://swdownloads.analog.com/cse/travis_builds/master_latest_libad9361-iio-trusty.tar.gz ; \
	tar xvf *.tar.gz ; \
	mv usr/local/lib/* . ; \
	mv usr/local/include ../ ; \
	rm -rf usr ; \
	rm *.tar.gz ; \
	cd .. ; \
	mkdir osx ; \
	cd osx ; \
	wget http://swdownloads.analog.com/cse/travis_builds/master_latest_libad9361-iio-osx_10.12.tar.gz ; \
	tar xvf *.tar.gz ; \
	cd ad9361* ; \
	mv usr/local/lib/ad9361.framework/Versions/Current/ad9361 ../libad9361.dylib ; \
	cd .. ; \
	rm -rf ad9361-*-Darwin ; \
	rm *.tar.gz ; \
	cd .. ; \
	mkdir win ; \
	cd win ; \
	wget "https://github.com/analogdevicesinc/libad9361-iio/releases/download/v0.2/libad9361-0.2-win64.zip" -O lib.zip ; \
	unzip lib.zip ; \
	mv libad9361-win64/* . ; \
	rm -rf libad9361-win64 ; \
	rm *.h ; \
	rm lib.zip

test_installer:
	cd ../.. ; \
	cp *.mltbx test/ ; \
	cp hdl/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m ; \
	sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" test/hdlcoder_board_customization_local.m ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) cd('test');runInstallerTests('$(BOARD)');"

test:
	cd ../.. ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) cd('test');runTests('$(BOARD)');"

test_streaming:
	cd ../.. ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) addpath(genpath('test'));addpath(genpath('deps'));runHWTests;"

run_NonHWTests:
	cd ../.. ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) addpath(genpath('test'));runNonHWTest;"

test_evm:
	cd ../.. ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) addpath(genpath('test'));addpath(genpath('deps'));hwTestRunner;"

test_modem:
	cd ../.. ; \
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) addpath(genpath('hdl'));cd('targeting');addpath(genpath('modem-qpsk'))"

test_synth:
	bash synth_designs.sh $(BOARD)
gen_tlbx:
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) genTlbx($(INCLUDE_EXAMPLES));exit();"

linter:
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) linter;exit();"

doc:
	$(MATLAB_BIN) $(MLFLAGS) -batch "$(MATLAB_RELEASE_ASSERT) cd('../doc');genhtml();exit();"

zip:
	cd ../.. ; \
	mkdir zip ; \
	zip -r zip/AnalogDevicesBSP_$(GITTAG).zip deps doc hdl hil_models targeting info.xml LICENSE README.md test/*.log
