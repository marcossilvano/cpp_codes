#ifndef _STRUCTS_H_
#define _STRUCTS_H_

#include <genesis.h>
#include "sprite_eng.h"

#define TILE_W 8
#define SCREEN_W 320
#define SCREEN_H 224

#define MAP_W 120* TILE_W
#define MAP_H 50 * TILE_W

#define PAL_PLAYER 		PAL0
#define PAL_LEVEL 		PAL1
#define PAL_BACKGROUND 	PAL2

typedef struct GameObject {
	Sprite* sprite;
	s16 x;
	s16 y;
	s16 screen_x;
	s16 screen_y;
	s16 w;
	s16 h;
	s16 right;
	s16 bottom;
	f16 speed_x;
	f16 speed_y;
	u8 flip;
	u8 anim;
} GameObject;

typedef struct Rect {
	u16 left;
	u16 right;
	u16 bottom;
	u16 top;
} Rect;

extern int hscroll_offset;
extern char text[5];

/*
inline void update_rect(GameObject* obj) {
	obj->rect.left  = obj->x;
	obj->rect.right = obj->x + obj->sprite->definition->w;
	obj->rect.top   = obj->y;
	obj->rect.bottom= obj->y + obj->sprite->definition->h;
}
*/
inline Rect get_rect(int x, int y, int w, int h) {
	return (Rect){x, x+w, y, y+h};
}

#endif // _STRUCTS_H_