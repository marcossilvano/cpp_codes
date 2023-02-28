/**
 * Para compilar:
 * ----------------------
 *   CTRL + SHIFT + B   (gera out/rom.bin )
 * 
 * Para fazer:
 * ----------------------
 * @todo Carregar TMX e Tileset
 * @todo Câmera (level maior)
 * @todo Adicionar obstaculos
 * @todo Adicionar inimigos
 * @todo Fundo com parallax
 * @todo Impedir que saia pelo topo da tela
 * @todo Controle de DOWN, PRESSED e RELEASED para botoes
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
u8 color_delay = 5;

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void draw_position() 
{
	intToStr(player.x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(player.y, text, 2);
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
// DRAWING AND FX

inline void PLAYER_rotate_colors_left(u8 left_index, u8 right_index) {
	if (color_delay-- == 0) {
		u16 color = PAL_getColor(left_index);
		for (u8 i = left_index; i < right_index; i++) {
			PAL_setColor(i, PAL_getColor(i + 1));
		}
		PAL_setColor(right_index, color);
		color_delay = 5;
	}
}

inline void PLAYER_rotate_colors_right(u8 left_index, u8 right_index) {
	if (color_delay-- == 0) {
		// color: 4 
		// 4 1 2 3 ->
		// i
		u16 color = PAL_getColor(right_index);
		for (u8 i = right_index; i > left_index; i--) {
			PAL_setColor(i, PAL_getColor(i - 1));
		}
		PAL_setColor(left_index, color);
		color_delay = 5;
	}
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
	SPR_init();
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

		PLAYER_rotate_colors_right(24, 27);
		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		// update VDP scroll
	}

	return 0;
}
