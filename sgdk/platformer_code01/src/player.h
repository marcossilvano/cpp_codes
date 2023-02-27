#ifndef _PLAYER_H_
#define _PLAYER_H_

#include <genesis.h>
#include "structs.h"
#include "resources.h"
#include "level.h"

#define ANIM_STAND  0
#define ANIM_RUN    1
#define ANIM_JUMP   2
#define ANIM_FALL   3
#define BLOCK_BLUE	4
#define BLOCK_RED	5

#define FLOOR_Y     146
#define SPEED       3

extern GameObject sonic;

extern u16 sonic_color;
extern bool on_floor;
extern u8 color_delay;

////////////////////////////////////////////////////////////////////////////
// INITIALIZATION

inline void PLAYER_init(u16* ind) {
	sonic.x = 64;
	sonic.y = 155;
	sonic.speed_x = FIX16(0);
	sonic.speed_y = FIX16(0);
	sonic.flip = FALSE;
	SPR_init();
	PAL_setPalette(PAL0, spr_boy.palette->data, CPU);
	sonic.sprite = SPR_addSprite(&spr_boy, sonic.x, sonic.y, TILE_ATTR_FULL(PAL0, TRUE, FALSE, sonic.flip, *ind));
	sonic.w = sonic.sprite->definition->w;
	sonic.h = sonic.sprite->definition->h;

	sonic_color = PAL_getColor(11);

	KLog_U1("Player color: ", PAL_getColor(11));
}

////////////////////////////////////////////////////////////////////////////
// GAME LOOP/LOGIC

inline void PLAYER_update_pos(GameObject* obj) {
	obj->right  = obj->x + obj->w;
	obj->bottom = obj->y + obj->h;
}

inline void PLAYER_check_floor(GameObject* obj) {
	if (LEVEL_tile_at(obj->x + 12, obj->bottom) || LEVEL_tile_at(obj->right - 12, obj->bottom)) {
		if (obj->speed_y >= 0) {
			obj->y = (obj->y) - (obj->bottom % TILE_W);
			on_floor = TRUE;
		} else {
			on_floor = FALSE;
		}
	} else {
		on_floor = FALSE;
	}

}

inline bool PLAYER_on_floor(GameObject* obj) {
	if (obj->y >= FLOOR_Y) {
		obj->y = FLOOR_Y;
		return TRUE;
	} else {
		return FALSE;
	}
}

inline void PLAYER_wrap_bounds(GameObject* obj) {
	// horizontal
	if (obj->x < -obj->w/2) {
		obj->x = SCREEN_W - obj->w/2;	
	}
	else if (obj->x > SCREEN_W - obj->w/2) {
		obj->x = -obj->w/2;
	}
}

inline void PLAYER_animate() {
	// animation
	if (!on_floor) {
		if (sonic.speed_y < 0)
			sonic.anim = ANIM_JUMP;
		else 
		if (sonic.speed_y > 0)
			sonic.anim = ANIM_FALL;
	}
	else {
		if (sonic.speed_x)
			sonic.anim = ANIM_RUN;
		else
			sonic.anim = ANIM_STAND;
	}

	//sonic.anim = BLOCK_BLUE;
}

inline void PLAYER_get_input() {
	u16 value = JOY_readJoypad(JOY_1);

	if (value & BUTTON_LEFT) {
		sonic.speed_x = FIX16(-3);
		sonic.flip = TRUE;
	}
	else
	if (value & BUTTON_RIGHT) {
		sonic.speed_x = FIX16(3);
		sonic.flip = FALSE;
	} 
	else {
		sonic.speed_x = 0;
	}
/*
	if (value & BUTTON_UP) {
		sonic.speed_y = FIX16(-1);
		sonic.flip = TRUE;
	}
	else
	if (value & BUTTON_DOWN) {
		sonic.speed_y = FIX16(1);
		sonic.flip = FALSE;
	} 
	else {
		sonic.speed_y = 0;
	}
*/
	if (value & BUTTON_A && on_floor)
		sonic.speed_y = FIX16(-5);
}

inline void PLAYER_update()
{
	if (LEVEL_wall_at(&sonic)) {
		sonic.anim = BLOCK_RED;
	} else {
		sonic.anim = BLOCK_BLUE;
	}

	PLAYER_check_floor(&sonic);
	if (on_floor) {
		sonic.speed_y = 0;
	} else {
		// gravity
		sonic.speed_y = fix16Add(sonic.speed_y, FIX16(0.3)); 

		// limit falling speed
		if (sonic.speed_y > FIX16(5)) 
			sonic.speed_y = FIX16(5);
	}

	// input
	PLAYER_get_input();

	// movement
	sonic.x = sonic.x + fix16ToInt(sonic.speed_x);
	sonic.y = sonic.y + fix16ToInt(sonic.speed_y);
	PLAYER_update_pos(&sonic);

	// wrap at screen bounds
	PLAYER_wrap_bounds(&sonic);

	// animate
	PLAYER_animate();

	// update VDP
	SPR_setPosition(sonic.sprite, sonic.x, sonic.y);
	SPR_setHFlip(sonic.sprite, sonic.flip);
	SPR_setAnim(sonic.sprite, sonic.anim);
}

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

inline void PLAYER_rotate_colors(u8 first_index, u8 last_index)
{
	if (color_delay-- == 0)
	{
		u16 color = PAL_getColor(first_index);
		for (u8 i = first_index; i < last_index; i++)
		{
			PAL_setColor(i, PAL_getColor(i + 1));
		}
		PAL_setColor(last_index, color);
		color_delay = 5;
	}
}

#endif // _PLAYER_H_