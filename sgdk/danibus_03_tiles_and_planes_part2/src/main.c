#include <genesis.h>

#define TILE01 1

// tile 8x8 pixels (each pixel uses 4 bits)
// size 8x8x4 = 256 bits = 32 bytes
const u32 tile[8]=
{
		0x00111100, // 4 bits per pixel x 8 pixels wide = 32 bits per line
		0x01144110,
		0x11244211,
		0x11244211,
		0x11222211,
		0x11222211,
		0x01122110,
		0x00111100
};

const u32 tile2[8]=
{
		0x07070707, // 4 bits per pixel x 8 pixels wide = 32 bits per line
		0x07070707,
		0x06060606,
		0x06060606,
		0x05050505,
		0x05050505,
		0x04040404,
		0x04040404
};

u8 color_delay = 5;

static void handle_input() {
	u16 input = JOY_readJoypad(JOY_1);

	if (input & BUTTON_LEFT) {
		//text_x--;
		//str[0] = 'L';
	} else
	if (input & BUTTON_RIGHT) {
		//text_x++;
		//str[0] = 'R';
	}
}

static void rotate_color(u8 first_index, u8 last_index) {
	if (color_delay-- == 0) {
		u16 color = VDP_getPaletteColor(first_index);
		for (u8 i = first_index; i < last_index; i++) {
			VDP_setPaletteColor(i, VDP_getPaletteColor(i+1));
		}
		VDP_setPaletteColor(last_index, color);
		color_delay = 5;
	}   	
}

int main()
{
	JOY_init();
	
	// 0-62: one color in the 4 palettes
	VDP_setPaletteColor(22, RGB24_TO_VDPCOLOR(0x0098e5)); // light blue
	VDP_setBackgroundColor(22);
	
	// load tile in VRAM at index 1
	// if we load on position 0, it will fill the entire background with the tile
	VDP_loadTileData( (const u32 *)tile2, TILE01, 1, 0); // 0 = NO DMA

	// set the tile in the map data
	//VDP_setTileMapXY( VDP_PLAN_A, TILE01, i+5, j+5);

	VDP_fillTileMapRect( VDP_PLAN_A, TILE_ATTR_FULL(PAL2, 0, 0, 0, TILE01), 5, 5, 30, 18);

	while(1)
	{     
		// rotate some color from 3rd palette (32-47)
		rotate_color(36, 39);
/*
		if (color_delay-- == 0) {
			u16 color = VDP_getPaletteColor(36);
			for (u8 i = 36; i < 39; i++) {
				VDP_setPaletteColor(i, VDP_getPaletteColor(i+1));
			}
			VDP_setPaletteColor(39, color);
			color_delay = 5;
		}   		
*/
		// read input
		handle_input();
		// move sprites
		
		// update hud
		//for (u8 i = 0; i <= 224; i += 1) {	
		VDP_drawText("Hello SEGA World!", 11, 13);
		//}

		// wait for screen refresh
		VDP_waitVSync();
	}
	return (0);
}
