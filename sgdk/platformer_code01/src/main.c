/**
 * Para compilar & rodar:
 * ----------------------
 *   CTRL + SHIFT + B   (gera out/rom.bin )
 *   [F1], Run Task, Run Gens
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

s16 map_scroll_x = 0;
s16 map_scroll_y = 0;

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void draw_position()  {
	intToStr(player.x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(player.y, text, 2);
	VDP_drawText(text, 5, 24);
}

inline void draw_info() {
	VDP_drawText("PLATFORMER SAMPLE", 1, 1);
	VDP_drawText("Use DPAD and A", 1, 3);
	
	VDP_drawText("X: ", 2, 23);
	VDP_drawText("Y: ", 2, 24);
}

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void rotate_colors(u8 first_index, u8 last_index, s8 direction) {
	if (color_delay-- == 0) {
		u16 last_color = PAL_getColor(first_index);
		for (u8 i = first_index; i != last_index; i += direction) {
			PAL_setColor(i, PAL_getColor(i + direction));
		}
		PAL_setColor(last_index, last_color);
		color_delay = 5;	
	}
}

inline void rotate_colors_left(u8 left_index, u8 right_index) {
	rotate_colors(left_index, right_index, 1);
}

inline void rotate_colors_right(u8 left_index, u8 right_index) {
	rotate_colors(right_index, left_index, -1);
}


////////////////////////////////////////////////////////////////////////////
// MAIN CODE

inline void CAMERA_follow(GameObject* obj) {
	map_scroll_x = obj->x - SCREEN_W/2;
	map_scroll_y = obj->y - SCREEN_H/2;
	
	map_scroll_x = clamp(map_scroll_x, 0, map_scroll_x - MAP_W);
	map_scroll_y = clamp(map_scroll_y, 0, map_scroll_y - MAP_H);
}

inline void update() {
/**
 * 
 * REMOVER DUPLICATAS NOS TILES 8X8
 * ATUALIZAR A LISTA DE TILES QUE SAO CHAO!
 * 
 */


	PLAYER_update();
	//SPR_setPosition(player.sprite, player.x - map_scroll_x, player.y - map_scroll_y);

	CAMERA_follow(&player);
/*
	u16 value = JOY_readJoypad(JOY_1);
	
	if (value & BUTTON_LEFT) {
		map_scroll_x -= 3;
		map_scroll_x = clamp(map_scroll_x, 0, map_scroll_x - MAP_W);
	}
	else
	if (value & BUTTON_RIGHT) {
		map_scroll_x += 3;
		map_scroll_x = clamp(map_scroll_x, 0, map_scroll_x - MAP_W);
	} 

	MAP_scrollTo(map, map_scroll_x, map_scroll_y); 
*/
	
}

int main()
{
	VDP_setScreenWidth320();
	//VDP_setPlaneSize(64, 64, TRUE);
	
	LEVEL_init(&ind);
	SPR_init();
	PLAYER_init(&ind);

	// Initilizes text UI
	VDP_setTextPalette(PAL_LEVEL);
	
	//VDP_setBackgroundColor(PAL_getColor(5));
	draw_info();
	//LEVEL_draw_collision_map();

	while (1)
	{
		// handle input
		update();

		draw_position();
		
		//VDP_setHorizontalScroll(BG_B, hscroll_offset);
		//VDP_setVerticalScroll(BG_B, hscroll_offset);
		//hscroll_offset--;

		rotate_colors_right(PAL_LEVEL*16+4, PAL_LEVEL*16+7);
		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		// update VDP scroll
	}

	return 0;
}
