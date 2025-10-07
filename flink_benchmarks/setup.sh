# wireshark
# ssh -X to get into it (forwards it to remote node so that you can use GUI on your machine)
sudo apt-get update
sudo apt install wireshark
sudo wireshark

# Flink setup  (follow experiment-scripts readme)
git clone git@github.com:EEStrmCmptng/flink-benchmarks.git
git clone git@github.com:EEStrmCmptng/flink-simplified.git

sudo apt install maven
