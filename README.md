#running
Load the .sof file from  \codesign-challenge-jubayer0175\exampleniossdram.sof using 
NIOS shell: nios2-configure-sof -d 2 exampleniossdram.sof
Open a NIOS terminal in another NIOS shell: nios2-terminal
Load the NIOS software: cd \nios_v2_neuralnetwork\
NIOS shell: nios2-download main.elf --go
Load the mnist_infertest file to the HPS from the software\ hps_v2_neuralnetwork\
Run the mnist_infertest file in the HPS.
