# Preserve the current upstream project flow, including transceiver generation.
source [file join [file dirname [info script]] adi_project_xilinx_upstream.tcl]

# A transceiver helper launches a separate Vivado process with no MATLAB project.
# Do not let parent-only flags suppress project creation or synthesis there.
if {[llength [info procs adi_xcvr_project]]} {
    if {[llength [info procs adi_xcvr_project_upstream]]} {
        rename adi_xcvr_project_upstream {}
    }
    rename adi_xcvr_project adi_xcvr_project_upstream
    proc adi_xcvr_project {parameters_for_make} {
        set parent_flags [dict create]
        # Outer toolbox make arguments (e.g. BOARD=daq2) must not become
        # transceiver configuration parameters or alter its output directory.
        foreach flag {ADI_MATLAB ADI_SKIP_SYNTHESIS MAKEFLAGS MAKEOVERRIDES MFLAGS MAKELEVEL GNUMAKEFLAGS} {
            if {[info exists ::env($flag)]} {
                dict set parent_flags $flag $::env($flag)
                unset ::env($flag)
            }
        }
        # project-xilinx.mk reverses parameter order at even MAKELEVEL values.
        # The upstream Tcl helper constructs paths for a nested (odd) make.
        set ::env(MAKELEVEL) 1
        try {
            adi_xcvr_project_upstream $parameters_for_make
        } finally {
            unset ::env(MAKELEVEL)
            dict for {flag value} $parent_flags {
                set ::env($flag) $value
            }
        }
    }
}
