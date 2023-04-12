#include <stdio.h>
#include <exec/types.h>

// mouse button state register
volatile UBYTE *mouse_reg = (volatile UBYTE *) 0xbfe001; 

// bit 6 in mouse_reg indicates button 1
#define MOUSE_BUTTON_1 (1 << 6)

int main(int argc, int** argv) {

    // do nothing, just wait for click
    printf("Waiting for mouse button click...\n");
    while ((MOUSE_BUTTON_1 & *mouse_reg) != 0);
    printf("Mouse clicked!\n");

    return 0;
}