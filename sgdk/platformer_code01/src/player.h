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

extern GameObject player;

extern bool on_floor;

////////////////////////////////////////////////////////////////////////////
// INITIALIZATION

inline void PLAYER_init(u16* ind) {
	player.x = 64;
	player.y = 144;
	player.speed_x = 0;
	player.speed_y = 0;
	player.flip = FALSE;
	PAL_setPalette(PAL_PLAYER, spr_boy.palette->data, CPU);
	player.sprite = SPR_addSprite(&spr_boy, player.x, player.y, TILE_ATTR_FULL(PAL0, TRUE, FALSE, player.flip, *ind));
	player.w = player.sprite->definition->w;
	player.h = player.sprite->definition->h;
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
		if (player.speed_y < 0)
			player.anim = ANIM_JUMP;
		else 
		if (player.speed_y > 0)
			player.anim = ANIM_FALL;
	}
	else {
		if (player.speed_x)
			player.anim = ANIM_RUN;
		else
			player.anim = ANIM_STAND;
	}

	//sonic.anim = BLOCK_BLUE;
}

inline void PLAYER_get_input() {
	u16 value = JOY_readJoypad(JOY_1);

	if (value & BUTTON_LEFT) {
		player.speed_x = FIX16(-3);
		player.flip = TRUE;
	}
	else
	if (value & BUTTON_RIGHT) {
		player.speed_x = FIX16(3);
		player.flip = FALSE;
	} 
	else {
		player.speed_x = 0;
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
		player.speed_y = FIX16(-5);
}

inline void PLAYER_update()
{
	if (LEVEL_wall_at(&player)) {
		player.anim = BLOCK_RED;
	} else {
		player.anim = BLOCK_BLUE;
	}

	PLAYER_check_floor(&player);
	if (on_floor) {
		player.speed_y = 0;
	} else {
		// gravity
		player.speed_y = fix16Add(player.speed_y, FIX16(0.3)); 

		// limit falling speed
		if (player.speed_y > FIX16(5)) 
			player.speed_y = FIX16(5);
	}

	// input
	PLAYER_get_input();

	// movement
	player.x = player.x + fix16ToInt(player.speed_x);
	player.y = player.y + fix16ToInt(player.speed_y);
	PLAYER_update_pos(&player);

	// wrap at screen bounds
	PLAYER_wrap_bounds(&player);

	// animate
	PLAYER_animate();

	// update VDP/SGDK
	SPR_setPosition(player.sprite, player.x, player.y);
	SPR_setHFlip(player.sprite, player.flip);
	SPR_setAnim(player.sprite, player.anim);
}

#endif // _PLAYER_H_