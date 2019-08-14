# Usage:
#	make <target> MLRELEASE=<MATLAB release version ex: R2018b> HDLBRANCH=<HDL git branch ex: hdl_2018_r1>
# Example
#	make build MLRELEASE=R2018b HDLBRANCH=hdl_2018_r1

SHELL := /bin/bash

MLFLAGS := -nodisplay -nodesktop -nosplash

ifeq ($(MLRELEASE),)
MLRELEASE := R2019a
endif

ifeq ($(OS),Windows_NT)
MLPATH := /cygdrive/c/Program\ Files/MATLAB
MLFLAGS := $(MLFLAGS) -wait
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
MLPATH := /usr/local/MATLAB
endif
ifeq ($(UNAME_S),Darwin)
MLPATH := /Applications
MLRELEASE := MATLAB_${MLRELEASE}.app
endif
endif

ifeq ($(BOARD),)
BOARD :=
endif

ifeq ($(INCLUDE_EXAMPLES),)
INCLUDE_EXAMPLES := 1
endif

GITTAG := $(shell git describe --tags HEAD)

.ONESHELL:
test_streaming:
	cd ../.. ; \
	${MLPATH}/$(MLRELEASE)/bin/matlab $(MLFLAGS) -r "addpath(genpath('test'));runHWTests;"

gen_tlbx:
	${MLPATH}/$(MLRELEASE)/bin/matlab $(MLFLAGS) -r "genTlbx($(INCLUDE_EXAMPLES));exit();"

linter:
	${MLPATH}/$(MLRELEASE)/bin/matlab $(MLFLAGS) -r "linter;exit();"

doc:
	${MLPATH}/$(MLRELEASE)/bin/matlab $(MLFLAGS) -r "cd('../doc');genhtml();exit();"

zip:
	cd ../.. ; \
	mkdir zip ; \
	zip -r zip/AnalogDevicesSensorToolbox_$(GITTAG).zip doc sensor_examples info.xml LICENSE README.md test/*.log
