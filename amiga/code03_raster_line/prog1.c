#include <stdio.h>

#include <exec/types.h>
#include <hardware/custom.h>

extern struct Custom custom;

volatile UBYTE *mouse_reg = (volatile UBYTE *) 0xbfe001;       // mouse button state register
volatile UBYTE *raster_vpos_reg = (volatile UBYTE *) 0xdff006; // vertical refresh position register

#define MOUSE_BUTTON_1  1 << 6 // bit 6 in mouse_reg indicates button 1
#define COLOR_WHITE     0xfff
#define COLOR_WBENCH_BG 0x05a
#define TOP_POS         0x40
#define BOTTOM_POS      0xf0

int main(int argc, int** argv) {

    UBYTE pos = 0xac;
    BYTE inc = 1; 

    // do nothing, just wait for click
    printf("RASTER LINE MOVEMENT\n");
    printf("Click to exit\n");
    while ((MOUSE_BUTTON_1 & *mouse_reg) != 0) {
        while (*raster_vpos_reg != 0xff); // wait until vblank

        while (*raster_vpos_reg != pos);  // wait until position reached
        custom.color[0] = COLOR_WHITE;

        while (*raster_vpos_reg == pos);  // wait while on the target position
        custom.color[0] = COLOR_WBENCH_BG;

        // check for screen bounds
        if (pos <= TOP_POS || pos >= BOTTOM_POS)  inc = -inc;

        // change line position
        pos += inc;
    }
    printf("Mouse clicked!\n");

    return 0;
}