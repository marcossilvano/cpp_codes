/**
 * Para compilar:
 * ----------------------
 *   CTRL + SHIFT + B   (gera out/rom.bin )
 * 
 * Para fazer:
 * ----------------------
 * - Controle de DOWN, PRESSED e RELEASED para botoes
 * - Fundo com parallax
 * - Carregar TMX e Tileset
 * - Câmera (level maior)
 */
#include <genesis.h>

#include "sprite_eng.h"
#include "resources.h"

#include "structs.h"
#include "player.h"
#include "level.h"

// index for tiles in VRAM (first tile reserved for SGDK)
u16 ind = 1; 
//u16 ind = TILE_USER_INDEX;

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void draw_position() 
{
	intToStr(sonic.x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(sonic.y, text, 2);
	VDP_drawText(text, 5, 24);
}

inline void draw_info()
{
	VDP_drawText("PLATFORMER SAMPLE", 1, 1);
	VDP_drawText("Use DPAD and A", 1, 3);
	
	VDP_drawText("X: ", 2, 23);
	VDP_drawText("Y: ", 2, 24);
}

////////////////////////////////////////////////////////////////////////////
// MAIN CODE

inline void update() {
	PLAYER_update();
}

int main()
{
	VDP_setScreenWidth320();
	//VDP_setPlaneSize(64, 64, TRUE);
	
	LEVEL_init(&ind);
	PLAYER_init(&ind);

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	
	//VDP_setBackgroundColor(PAL_getColor(5));
	//draw_info();
	LEVEL_draw_collision_map();

	while (1)
	{
		// handle input
		update();

		draw_position();
		
		VDP_setHorizontalScroll(BG_B, hscroll_offset);
		//VDP_setVerticalScroll(BG_B, hscroll_offset);
		//hscroll_offset--;

		PLAYER_rotate_colors(24, 27);
		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		// update VDP scroll
	}

	return 0;
}
