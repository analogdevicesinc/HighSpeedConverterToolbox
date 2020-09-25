set cdir [pwd]
set sdk_loc $cdir/vivado_prj.sdk

### Create create_pmufw_project.tcl
set hwdsgn [open_hw_design $sdk_loc/system_top.hdf]
generate_app -verbose -hw $hwdsgn -os standalone -proc psu_pmu_0 -app zynqmp_pmufw -compile -sw pmufw -dir pmufw
quit
