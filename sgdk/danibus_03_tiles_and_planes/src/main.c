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

int main()
{
	JOY_init();
	// load tile in VRAM at index 1
	// if we load on position 0, it will fill the entire background with the tile
	VDP_loadTileData( (const u32 *)tile, TILE01, 1, 0); // 0 = NO DMA

	// set the tile in the map data
	//VDP_setTileMapXY( VDP_PLAN_A, TILE01, i+5, j+5);

	VDP_fillTileMapRect( VDP_PLAN_A, TILE_ATTR_FULL(PAL2, 0, 0, 0, TILE01), 5, 5, 30, 18);

	while(1)
	{        	
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
