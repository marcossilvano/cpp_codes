#ifndef _LEVEL_H_
#define _LEVEL_H_

#include <genesis.h>
#include "structs.h"
#include "resources.h"

extern Map* map;
extern u8 collision_map[SCREEN_W/TILE_W][SCREEN_H/TILE_W]; // size of screen

extern fix16 offset_mask[SCREEN_H/TILE_W]; // 224 px / 8 px = 28
extern fix16 offset_speed[SCREEN_H/TILE_W];

////////////////////////////////////////////////////////////////////////////
// INITIALIZATION

inline void LEVEL_generate_collision_map() {
	for (u8 x = 0; x < SCREEN_W/TILE_W; x++) {
		for (u8 y = 0; y < SCREEN_H/TILE_W; y++) {
			collision_map[x][y] = (MAP_getTile(map, x*TILE_W/8, y*TILE_W/8) && 0x07FF? 1 : 0);
		}
	}	
}

inline void LEVEL_init(u16* ind) {
	PAL_setPalette(PAL1, level1_palette.data, DMA);
	VDP_loadTileSet(&level1_tileset, *ind, DMA);
	map = MAP_create(&level1_map, BG_B, TILE_ATTR_FULL(PAL1, FALSE, FALSE, FALSE, *ind));
	*ind += level1_tileset.numTile;
	MAP_scrollTo(map, 0, 0); // MAP_scrollToEx?

	VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);

	LEVEL_generate_collision_map();
}

////////////////////////////////////////////////////////////////////////////
// GAME LOOP/LOGIC

inline u8 LEVEL_tile_at(u16 x, u16 y) {
	return collision_map[x/TILE_W][y/TILE_W];
}

inline u8 LEVEL_wall_at(GameObject* obj) {
	for (u16 x = obj->x; x <= obj->x + obj->sprite->definition->w ; x += TILE_W) {
	// for (u16 x = obj->x; x <= obj->x + 32; x += 8) {
		for (u16 y = obj->y; y <= obj->y + obj->sprite->definition->h; y += TILE_W) {
		// for (u16 y = obj->y; y <= obj->y + 32; y += 8) {
			if (LEVEL_tile_at(x, y) == 1)
				return TRUE;
		}
	}
	return FALSE;
}

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void LEVEL_draw_collision_map() {
	for (u8 x = 0; x < SCREEN_W/TILE_W; x++) {
		for (u8 y = 0; y < SCREEN_H/TILE_W; y++) {
			if (collision_map[x][y] != 0) {
				intToStr(collision_map[x][y], text, 1);
				// TILE_W/8 = how many hardware tiles are being used for a game tile
				VDP_drawText(text, x*TILE_W/8, y*TILE_W/8); 
			} else {
				VDP_drawText(" ", x*TILE_W/8, y*TILE_W/8); 
			}
		}
	}
}


#endif // _LEVEL_H_