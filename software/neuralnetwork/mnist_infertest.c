#include <stdio.h>
#include <time.h>
#include "cnn.h"
#include <stdlib.h>
#include "system.h"
#include "sys/alt_timestamp.h"

#include "imagecoef.h"

#define NUM_IMAGES 100
#define IMAGE_SIZE 784

bool datumValid(Datum datum) {
    return datum.x->rank == 2 && datum.x->shape[0] == IMAGE_SIZE && datum.x->shape[1] == 1
           && datum.y->rank == 2 && datum.y->shape[0] == 10 && datum.y->shape[1] == 1;
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

int main() {
  unsigned long long ticks;
  unsigned long long lap;

  alt_timestamp_start();

  // load images
  Tensor **imagearray;
  unsigned int tensorShapeImage[] = {IMAGE_SIZE, 1};
  imagearray = calloc(NUM_IMAGES, sizeof(Tensor*));  // 100 images
  for (int img = 0; img < NUM_IMAGES; img++) {
    Tensor* imgTensor = newTensor(2, tensorShapeImage);
    for (int c = 0; c < IMAGE_SIZE; c++) {
      imgTensor->data[c] = (float) ((float) testimage[img * IMAGE_SIZE + c] / 255.0);
    }
    imagearray[img] = imgTensor;
  }

  // load labels
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

  // you can set verbose to 1 to generate debug output and intermediate stats
  // keep verbose to 0 to kee silent  
  unsigned verbose = 1;
  
  volatile unsigned int *HEX = (unsigned int *) PIO_0_BASE;
  volatile unsigned int *LED = (unsigned int *) PIO_1_BASE;

  //---------------- start measurement
  ticks = alt_timestamp();
  
  for (unsigned i = 0; i<100; i++) {
    Datum datum = testData[i];

    if (verbose) {
      printMnistDatum(datum);
    }
    
    copyTensor(datum.x, nn->input);
    forwardPass(nn);

    if (verbose) {
      printf("Test Number %d: Network prediction: %d  Expected: %d  Confidence: %f%%\n",
	     i,
	     argmax(nn->output),
	     argmax(datum.y),
	     100*nn->output->data[argmax(nn->output)]);
    }

    *HEX = (((i/10) % 10) << 20) |
              (((i % 10)) << 16) |
       (argmax(nn->output) % 10) |
       ((argmax(datum.y) % 10) << 8);
    
    if (argmax(nn->output) != argmax(datum.y)) {
      totalerrors++;
    }

    lap = alt_timestamp() - ticks;
    if (verbose)
      printf("Lap cycles: %llu\n", lap);
    
    *LED = (1 << totalerrors) - 1;
  }

  *HEX = 0xEEE000 | totalerrors;

  //---------------- end measurement
  ticks = alt_timestamp() - ticks;

  printf("Complete. %d total errors\n", totalerrors);
  printf("Total cycles: %llu\n", ticks);

  freeNeuralNet(nn);
}

