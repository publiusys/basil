# wireshark
# ssh -X to get into it (forwards it to remote node so that you can use GUI on your machine)
sudo apt-get update
sudo apt install wireshark
sudo wireshark

# Flink setup  (follow experiment-scripts readme)
git clone git@github.com:EEStrmCmptng/flink-benchmarks.git
git clone git@github.com:EEStrmCmptng/flink-simplified.git

sudo apt install maven

# PSSH for following the readme
sudo apt install python-pip
pip install parallel-ssh
pssh -h hosts.txt -l sorenle -i "git clone git@github.com:EEStrmCmptng/eeflink.git"
# https://linux.die.net/man/1/pssh

# ^^ okay i give up on this for now but whats a good way to run commands on multiple remote servers at once 