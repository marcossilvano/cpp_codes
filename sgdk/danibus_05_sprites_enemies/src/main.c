#include <genesis.h>

#include "sprite_eng.h"
#include "resources.h"

#define ANIM_STAND      0
#define ANIM_WAIT       1
#define ANIM_WALK       2
#define ANIM_RUN        3
#define ANIM_BRAKE      4
#define ANIM_UP         5
#define ANIM_CROUNCH    6
#define ANIM_ROLL       7

#define WASP_ANIM 0
#define CRAB_ANIM 1

#define SPEED 3
#define MAX_ENEMIES 6

typedef struct GameObject {
	Sprite* sprite;
	s16 x;
	s16 y;
	s16 speed_x;
	s16 speed_y;
	u16 flip;
	u16 anim;
} GameObject;

// function declaration
static void update_player();
static void update_enemies();
static void draw_position();
/*
static Sprite *sonic_sprite;
static s16 sonic_x;
static s16 sonic_y;
static u16 sonic_flip;
static s16 sonic_anim;
*/
static GameObject sonic;
static GameObject enemies[MAX_ENEMIES];

static char text[5];

static void warp_at_screen(GameObject* obj) {
	if (obj->x < -obj->sprite->definition->w) {
		obj->x = VDP_getScreenWidth();	
	}
	else if (obj->x > VDP_getScreenWidth()) {
		obj->x = -obj->sprite->definition->w;
	}
}

static inline void update_player()
{
	u16 value = JOY_readJoypad(JOY_1);

	sonic.speed_x = 0;
	sonic.speed_y = 0;

	if (value & BUTTON_LEFT) {
		sonic.speed_x = -SPEED;
		sonic.flip = TRUE;
		sonic.anim = ANIM_RUN;
	}
	if (value & BUTTON_RIGHT) {
		sonic.speed_x = SPEED;
		sonic.flip = FALSE;
		sonic.anim = ANIM_RUN;
	}
	if (value & BUTTON_UP)
		sonic.y -= SPEED;
	if (value & BUTTON_DOWN)
		sonic.y += SPEED;

	if (!value) {
		sonic.anim = ANIM_STAND;
	}

	// move player
	sonic.x += sonic.speed_x;
	sonic.y += sonic.speed_y;

	// warp at screen bounds
	warp_at_screen(&sonic);

	SPR_setPosition(sonic.sprite, sonic.x, sonic.y);
	SPR_setHFlip(sonic.sprite, sonic.flip);
	SPR_setAnim(sonic.sprite, sonic.anim);
}

static inline void update_wasp(u8 i) {
	enemies[i].x += enemies[i].speed_x;
	
	// POS_Y = CONST + Fn_Sine(value*accelerator) * mod_amplitud
	enemies[i].y = 84 + sinFix16(enemies[i].x * 10) * 1;

	warp_at_screen(&enemies[i]);
}

static inline void update_crab(u8 i) {
	enemies[i].x += enemies[i].speed_x;
	enemies[i].y += enemies[i].speed_y;

	// bounce off screen bounds
	if (enemies[i].x < -enemies[i].sprite->definition->w || enemies[i].x > VDP_getScreenWidth()) {
		enemies[i].speed_x = -enemies[i].speed_x;
	}	
}

static inline void update_enemies() {
	for (u8 i = 0; i < MAX_ENEMIES; i++) {

		if (enemies[i].anim == CRAB_ANIM) {
			update_crab(i);
		} else {
			update_wasp(i);
		}

		SPR_setPosition(enemies[i].sprite, enemies[i].x, enemies[i].y);
		SPR_setHFlip(enemies[i].sprite, (enemies[i].speed_x >=0? TRUE : FALSE));
	}
}

static inline void draw_position()
{
	intToStr(sonic.x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(sonic.y, text, 2);
	VDP_drawText(text, 5, 24);
}

static void init_player() {
	// Initializes Sonic sprite
	sonic.x = 64;
	sonic.y = 155;
	sonic.flip = FALSE;
	sonic.anim = ANIM_STAND;
	VDP_setPalette(PAL2, spr_sonic.palette->data);
	sonic.sprite = SPR_addSprite(&spr_sonic, sonic.x, sonic.y, TILE_ATTR(PAL2, FALSE, FALSE, sonic.flip));
}

static inline void init_enemy(u8 idx, s16 x, s16 y, s16 speed_x, s16 speed_y, u16 anim) {
	enemies[idx].x = x;
	enemies[idx].y = y;
	enemies[idx].speed_x = speed_x;
	enemies[idx].speed_y = speed_y;
	enemies[idx].anim = anim;
	enemies[idx].sprite = SPR_addSprite(&spr_enemy, enemies[idx].x, enemies[idx].y, TILE_ATTR(PAL3, TRUE, FALSE, FALSE));
	SPR_setAnim(enemies[idx].sprite, anim);
}

static inline void init_enemies() {
	VDP_setPalette(PAL3, spr_enemy.palette->data);

	init_enemy(0, 128, 164, 1, 0, CRAB_ANIM);
	
	for (u8 i = 1; i < MAX_ENEMIES; i++) {
		init_enemy(i, 50 * i, 84, -1, 0, WASP_ANIM); 
	}

	SPR_update(); // not necessary, but recommended
}

static inline void init_background() {
	u16 ind = 1; // index for tiles in VRAM (first tile reserved for SGDK)
	
	VDP_setPalette(PAL0, img_bg1.palette->data);
	VDP_setPalette(PAL1, img_bg2.palette->data);
	
	VDP_drawImageEx(VDP_BG_B, &img_bg1, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 0, 0, 0, DMA);
	ind += img_bg1.tileset->numTile;

	VDP_drawImageEx(VDP_BG_A, &img_bg2, TILE_ATTR_FULL(PAL1, 0, 0, 0, ind), 0, 0, 0, DMA);
	ind += img_bg2.tileset->numTile;	
}

int main() {
	SYS_disableInts();

	VDP_setScreenWidth320(); // 320x240
	SPR_init(0, 0, 0);

	// Initializes Background
	init_background();
	init_player();
	init_enemies();

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	VDP_drawText("PLAYER + ENEMIES SAMPLE", 1, 1);
	VDP_drawText("X: ", 2, 23);
	VDP_drawText("Y: ", 2, 24);

	SYS_enableInts();
	while (1) {
		// handle input
		update_player();
		update_enemies();

		draw_position();

		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		//VDP_waitVSync();
		// update VDP scroll
	}

	return 0;
}
