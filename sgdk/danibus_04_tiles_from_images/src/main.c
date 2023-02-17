#include <genesis.h>
#include "resources.h"

u8 color_delay = 5;

// function prototypes
static void rotate_color(u8 first_index, u8 last_index);

// function definitions
static void rotate_color(u8 first_index, u8 last_index)
{
	if (color_delay-- == 0)
	{
		u16 color = VDP_getPaletteColor(first_index);
		for (u8 i = first_index; i < last_index; i++)
		{
			VDP_setPaletteColor(i, VDP_getPaletteColor(i + 1));
		}
		VDP_setPaletteColor(last_index, color);
		color_delay = 5;
	}
}

// main code
int main()
{
	// to keep track of tiles in VRAM
	// first tile is reserved to SGDK to "paint" the background
	u16 ind = 1;

	// pick up the image palette and assign it to PAL0
	VDP_setPalette(PAL0, moon2.palette->data);
	VDP_setPalette(PAL1, sonic.palette->data);

	// load the image into VRAM and draw it on the screen at position (3,3)
	//VDP_drawImageEx(VDP_PLAN_A, &moon, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 3, 3, 0, CPU);
	// increment ind to 'point' to a free VRAM zone for future tiles
	VDP_drawImageEx(VDP_PLAN_A, &moon2, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 3, 3, 0, CPU);
	ind += moon2.tileset->numTile;
	VDP_drawImageEx(VDP_PLAN_A, &sonic, TILE_ATTR_FULL(PAL1, 0, 0, 0, ind), 3, 10, 0, CPU);
	ind += sonic.tileset->numTile;


	while (1)
	{
		rotate_color(2, 12);

		VDP_waitVSync();
	}

	return 0;
}