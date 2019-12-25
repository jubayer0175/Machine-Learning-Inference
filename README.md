# Design optimization by hardware/software codesign
This design is one of the fastest designs submitted for the codesign challenge poject [ECE 4530 Fall 2019]
In a very simiple term the problem description is as follows: 
You have a neural net that can reconize 100 images from MNIST dataset in 6 billions cycles. The processor is a NIOS-II/e running in 50MHZ clock in Cylcone V FPGA. The design needs to be optimized for speed and area. 

### Problem description:  
https://rijndael.ece.vt.edu/ece4530f19/homework/challenge.html



# Running

*   Load the .sof file from  \codesign-challenge-jubayer0175\exampleniossdram.sof using
*   NIOS shell: nios2-configure-sof -d 2 exampleniossdram.sof
*   Open a NIOS terminal in another NIOS shell: nios2-terminal
*   Load the NIOS software: cd \nios_v2_neuralnetwork\
*   NIOS shell: nios2-download main.elf --go
*   Load the mnist_infertest file to the HPS from the software\ hps_v2_neuralnetwork\
*   Run the mnist_infertest file in the HPS.


