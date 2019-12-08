#include <stdio.h>
#include <time.h>
#include "cnn.h"
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "socal/socal.h"
#include "socal/hps.h"

#include "../hal_bsp/system.h"

#define NUM_IMAGES 100
#define IMAGE_SIZE 784

bool datumValid(Datum datum) {
    return datum.x->rank == 2 && datum.x->shape[0] == IMAGE_SIZE && datum.x->shape[1] == 1
           && datum.y->rank == 2 && datum.y->shape[0] == 10 && datum.y->shape[1] == 1;
}


#define FPGABRIDGEBASE  0xc0000000 
#define FPGABRIDGESPAN   0x8000000
#define NIOSREQ 0x1
#define HPSREQ  0x2

static volatile unsigned *pio_0;
static volatile unsigned *pio_1;

void reset_handshake(int pattern) {
  unsigned p = alt_read_word(pio_1);
  p = p & ~pattern;
  alt_write_word(pio_1, p);
}

void set_handshake(int pattern) {
  unsigned p = alt_read_word(pio_1);
  p = p | pattern;
  alt_write_word(pio_1, p);
}

int isreset_handshake(int pattern) {
  unsigned p = alt_read_word(pio_1);
  return ((p & pattern) == 0);
}
	  
int isset_handshake(int pattern) {
  unsigned p = alt_read_word(pio_1);
  return ((p & pattern) != 0);
}


char printSymbol(float x) {
    if (x <= 0.01) {
        return ' ';
    } else if (x < 0.3) {
        return '.';
    } else if (x < 0.4) {
        return ',';
    } else if (x < 0.5) {
        return '-';
    } else if (x < 0.6) {
        return '+';
    } else if (x < 0.7) {
        return '=';
    } else if (x < 0.8) {
        return 'x';
    } else if (x < 0.9) {
        return 'X';
    } else {
        return 'M';
    }
}

void printMnistDatum(Datum datum) {
    if (datumValid(datum)) {
        printf("O~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~O\n");
        for (int i = 0; i < 28; i++) {
            printf("| ");
            for (int j = 0; j < 28; j++) {
                printf("%c", printSymbol(datum.x->data[i*28 + j]));
            }
            printf(" |\n");
        }

        int label = -1;
        for (int i = 0; i < 10; i++) {
            if (datum.y->data[i] == 1) {
                label = i;
                break;
            }
        }

        printf("O~~~~~~~~~ Number: %d ~~~~~~~~~~O\n", label);
    } else {
        printf("[printDatum]: Invalid datum\n");
        exit(100);
    }
}
//Pointer to images, labels, and trainingcoeff. 
 volatile char *testimage;
 volatile unsigned *testlabel;
 volatile unsigned *trainingcoef;


int main() {
// load images
  
  int fd;
  void *virtual_base;

  printf("Opening shared-memory channel to NIOS\n");
  
  if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
    printf( "ERROR: could not open \"/dev/mem\"...\n" );
    return( 1 );
  }
  virtual_base = mmap( NULL,
           FPGABRIDGESPAN,
           ( PROT_READ | PROT_WRITE ),
           MAP_SHARED,
           fd,
           FPGABRIDGEBASE );  
  if( virtual_base == MAP_FAILED ) {
    printf( "ERROR: mmap() failed...\n" );
    close( fd );
    return(1);
  }
  pio_0 = virtual_base + (PIO_0_BASE);
  pio_1 = virtual_base + (PIO_1_BASE);
  while (isset_handshake(HPSREQ))
  usleep(10);  // wait for clear from NIOS, if set
 volatile unsigned *temp;
  int cont=0;
  while (1) {
    // wait for request from NIOS
    while (isreset_handshake(NIOSREQ))
     usleep(10); 
		cont++;
	temp = (unsigned*) (virtual_base + alt_read_word(pio_0));
    printf("cont: %d\n",cont);
	
	if(cont == 1)
	testimage = (char*) temp;
    else if(cont==2)
	testlabel = temp;
	else if(cont==3)
	{
		trainingcoef=temp;
		cont=0;
		printf("transfer complete\n");
		break;
	}
    set_handshake(HPSREQ);
    while (isset_handshake(NIOSREQ))
      usleep(10);

    // clear HPS handshake
    reset_handshake(HPSREQ);
	
  }  
	
	// load images form the address sent by the NIOS [testimage] 
  Tensor **imagearray;
  unsigned int tensorShapeImage[] = {IMAGE_SIZE, 1};
  imagearray = calloc(NUM_IMAGES, sizeof(Tensor*));
  for (int img = 0; img < NUM_IMAGES; img++) {
    Tensor* imgTensor = newTensor(2, tensorShapeImage);
    for (int c = 0; c < IMAGE_SIZE; c++) {
      imgTensor->data[c] = (float) ((float) testimage[img * IMAGE_SIZE + c] / 255.0);
    }
    imagearray[img] = imgTensor;
  }

  // load labels from the address sent by the NIOS [testlabel]
  Tensor **labelarray;
  unsigned int tensorShapeLabel[] = {10, 1};
  labelarray = calloc(NUM_IMAGES, sizeof(Tensor*));
  for (int img = 0; img < NUM_IMAGES; img++) {
    Tensor* labelTensor = newTensor(2, tensorShapeLabel);
    unsigned int index[] = {0, 0};
    index[0] = testlabel[img];
    *getElement(labelTensor, index) = 1;
    labelarray[img] = labelTensor;
  }
// Form data stucture
  Datum* testData = calloc(NUM_IMAGES, sizeof(Datum));
  for (int img = 0; img < NUM_IMAGES; img++) {
    testData[img] = (Datum) {
			     .x = imagearray[img],
			     .y = labelarray[img]
    };
  }
  free(imagearray);
  free(labelarray);

  // Initialize neural network
  unsigned int nnShape[] = {784, 16, 16, 10};
  NeuralNet* nn = newNeuralNet(4, nnShape, MeanSquaredError);
  
  loadMemNeuralNet(nn);
  unsigned totalerrors = 0;
  unsigned verbose = 0;// printing off as HPS is just a coprocessor here
  
  for (unsigned i = 0; i<NUM_IMAGES; i++) {
    Datum datum = testData[i];
    if (verbose) {
      printMnistDatum(datum);
    }    
    copyTensor(datum.x, nn->input);
    forwardPass_accelerate(nn);
    if (verbose) {
      printf("Test Number %d: Network prediction: %d  Expected: %d  Confidence: %f%%\n",
	     i,
	     argmax(nn->output),
	     argmax(datum.y),
	     100*nn->output->data[argmax(nn->output)]);
    }
    if (argmax(nn->output) != argmax(datum.y)) {
      totalerrors++;
    }   
  }
  printf("Complete. %d total errors\n", totalerrors);
  freeNeuralNet(nn);
  temp=&totalerrors;// send the error to NIOS.	
  set_handshake(HPSREQ);
   while (isset_handshake(NIOSREQ))
   usleep(10);
   reset_handshake(HPSREQ);
   while (isreset_handshake(NIOSREQ))
	usleep(10); 
	temp = (unsigned*) (virtual_base + alt_read_word(pio_0));// onchip memory
	*temp=totalerrors;
	 set_handshake(HPSREQ);
    while (isset_handshake(NIOSREQ))
      usleep(10);
    reset_handshake(HPSREQ);	
	return 0; 
}
  


