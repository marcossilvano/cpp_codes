#include <genesis.h>
#include "resources.h"

#define PLANE_W FIX16(256)

int main()
{
	fix16 offset_a = FIX16(0);
	fix16 offset_b = FIX16(0);
	fix16 speed_x = FIX16(-1);

	VDP_setPalette(PAL0, img_back1.palette->data);
	VDP_setPalette(PAL1, img_back2.palette->data);

	VDP_setPlaneSize(32,32, TRUE);

	u16 ind = 1;
    VDP_drawImageEx(BG_A, &img_back2, TILE_ATTR_FULL(PAL1, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	ind += img_back2.tileset->numTile;

    VDP_drawImageEx(BG_B, &img_back1, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	ind += img_back1.tileset->numTile;

	VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);
    
	while(1)
    {
		offset_a += speed_x;
		offset_b += speed_x/2;
		
		if (offset_a < PLANE_W) {
			offset_a += PLANE_W;
		}
		if (offset_b < PLANE_W) {
			offset_b += PLANE_W;
		}
		
		// must be done after SYS_doVBlankProcess?
		VDP_setHorizontalScroll(BG_A, fix16ToInt(offset_a));
		VDP_setHorizontalScroll(BG_B, fix16ToInt(offset_b));
		//VDP_waitVSync();

		SYS_doVBlankProcess();
    }
    return (0);
}
