#/bin/bash
	#
#OAR -l nodes=1/core=64,walltime=260:0:0
        #
#OAR -n Bounded_fault
        #
#OAR -O Bounded_fault.%jobid%.out
        #
#OAR -E Bounded_fault.%jobid%.err
        #
#OAR -p ib='QDR'
        #
#OAR -t besteffort



source /Softs/env_intel_12.1.csh
sh ./Script_for_looped_cases.sh
exit $?
