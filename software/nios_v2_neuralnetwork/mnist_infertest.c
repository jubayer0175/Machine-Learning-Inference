#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#ifndef NONIOS
#include "system.h"
#include "sys/alt_timestamp.h"
#endif
#include "cnn.h"
#include <string.h>
#include <unistd.h>
#include "altera_avalon_pio_regs.h"
#include "imagecoef.h"
#include "trainingcoef.h"

// store error in this shared memory. 
unsigned int __attribute__((section (".onchipdata"))) *error;

#define NIOSREQ 0x1
#define HPSREQ  0x2
//Handshake functions

void reset_handshake(int pattern) {
  unsigned p = IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE);
  p = p & ~pattern;
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, p);
}

void set_handshake(int pattern) {
  unsigned p = IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE);
  p = p | pattern;
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, p);
}

int isreset_handshake(int pattern) {
  unsigned p = IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE);
  return ((p & pattern) == 0);
}
	  
int isset_handshake(int pattern) {
  unsigned p = IORD_ALTERA_AVALON_PIO_DATA(PIO_1_BASE);
  return ((p & pattern) != 0);
} 	  

 
int main() {
  unsigned long ticks;
  alt_timestamp_start();
 IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, (int) testimage);  
  // reset handshake
  reset_handshake(NIOSREQ);
  reset_handshake(HPSREQ);
  usleep(500);
//-------------------Below this line initiates NISO-to-HPS
printf("Please initiate processing by starting HPS\n");
set_handshake(NIOSREQ);
while (isreset_handshake(HPSREQ));
//----------------- processing started & start timer
ticks = alt_timestamp();
//tranfer image address
reset_handshake(NIOSREQ);
while (isset_handshake(HPSREQ));
//-----------------send labels
IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, (int) testlabel);			      
set_handshake(NIOSREQ);
while (isreset_handshake(HPSREQ));
reset_handshake(NIOSREQ);
while (isset_handshake(HPSREQ));
//------------------send trainingcoeff
IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, (int) trainingcoef1);			      
set_handshake(NIOSREQ);
while (isreset_handshake(HPSREQ));
ticks = alt_timestamp() - ticks;
printf("Done processing: Total cycles: %lu\n", ticks);
reset_handshake(NIOSREQ);
while (isset_handshake(HPSREQ));  
//-------------------------- get the errors. 
IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, (int) error);			      
set_handshake(NIOSREQ);
while (isreset_handshake(HPSREQ));
printf("Errors: %d\n", *error);
reset_handshake(NIOSREQ);
while (isset_handshake(HPSREQ));
}

