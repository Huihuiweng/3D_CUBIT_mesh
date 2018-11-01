import sys
# Please set up the path for CUBIT (or Trelis)
# Instead, you could set up the path from ~/.bashrc 
sys.path.append('/opt/linux64/Trelis-14.0/bin/')

import cubit
try:
    #cubit.init([""])
    cubit.init(["-noecho","-nojournal"])
except:
    pass

for i in range(len(sys.argv)):                        # read parameter from shell(contain the prefix)
  if(sys.argv[i].find("-p")==0):
    P1=sys.argv[i+1]
input_file = P1


###  Read the CUBIT journal and playback it.
with open(input_file) as f:
    content = f.readlines()
for line in content:
    cubit.cmd(line)

