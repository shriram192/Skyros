#!/bin/bash

r_medium='data'
r_time=60 # time in seconds to run each single point in the graph
r_cluster='us-east-1' # aws region
r_user='sa84' # aws user
r_system='vr' #VR for all protocol variants including Skyros
workload='m' #mixed all

# n: numclients -- for this experiment, we need to try different number of clients
# i: iteration -- paper reported average of 3 runs. For reasonable experimental times for AE, we will just do one run
# code: orig - original paxos, rtop - skyros

n=10 # 10 clients for this experiment

# wp: write percentages
# in this experiment, non-nilext is 10% of total writes (traces ensure this)
# In the trace file, E: non-nilext, U: nilext, R: read (you can cat, grep, wc -l to check fractions of different ops)

# initial setup
#chmod 0400 ../../pems/$r_cluster.pem

./update_sources.py

# paxos
code=orig
for wp in 0.1 0.3 0.5 0.7 0.9; do
for i in 1; do
        # set the batch parameter to 20 batched Paxos...this is the value for which paxos performed the best
        ../../remote-throughput.py --medium $r_medium --code $code --time $r_time --run $i --cluster $r_cluster --sync no --user $r_user --workload $workload --num_nodes 5 --target_system_name $r_system --sync_rep_factor 3 --num_clients $n --leader_reads yes --batch 20 --workload_trace_prefix w$wp.uniform
        sleep 2
done
done

rm -rf ./mw*orig*
mv ../../mw*orig* .

# skyros
code=rtop
for wp in 0.1 0.3 0.5 0.7 0.9; do
for i in 1; do
        ../../remote-throughput.py --medium $r_medium --code $code --time $r_time --run $i --cluster $r_cluster --sync no --user $r_user --workload $workload --num_nodes 5 --target_system_name $r_system --sync_rep_factor 3 --num_clients $n --leader_reads yes --batch 64 --workload_trace_prefix w$wp.uniform
        sleep 2
done
done

rm -rf ./mw*rtop*
mv ../../mw*rtop* .

./plot_graphs.sh