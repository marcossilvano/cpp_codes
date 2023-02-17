#include <genesis.h>

#include "sprite_eng.h"
#include "resources.h"
#include "kdebug.h"
#include "tools.h"
#include "timer.h"

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

#define MAX_ENEMIES 10

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
static void draw_position();
/*
static Sprite *sonic_sprite;
static s16 sonic_x;
static s16 sonic_y;
static u16 sonic_flip;
static s16 sonic_anim;
*/
static GameObject sonic;
static GameObject megaman[MAX_ENEMIES];

static char text[5];

static u16 ind; // index for tiles loading in VRAM

static inline void KLog_memory() {
	KLog_U1("MEMORY:  ", MEM_getFree()+MEM_getAllocated());
	KLog_U1("  Free:  ", MEM_getFree());
	KLog_U1("  Alloc: ", MEM_getAllocated());
}

static void warp_at_screen(GameObject* obj) {
	if (obj->x < -obj->sprite->definition->w) {
		obj->x = VDP_getScreenWidth();	
	}
	else if (obj->x > VDP_getScreenWidth()) {
		obj->x = -obj->sprite->definition->w;
	}
}

static void bounce_off_screen(GameObject* obj) {
	// bounce off screen bounds
	if (obj->x < 0 || (obj->x + obj->sprite->definition->w) > VDP_getScreenWidth()) {
		obj->speed_x = -obj->speed_x;
	}	

	if (obj->y < 0 || (obj->y + obj->sprite->definition->h) > VDP_getScreenHeight()) {
		obj->speed_y = -obj->speed_y;
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
	}else
	if (value & BUTTON_RIGHT) {
		sonic.speed_x = SPEED;
		sonic.flip = FALSE;
	}
	if (value & BUTTON_UP) {
		sonic.y -= SPEED;
	} else
	if (value & BUTTON_DOWN) {
		sonic.y += SPEED;
	}

	if (value & BUTTON_A) {
		SPR_setPriority(sonic.sprite, 1);
	} else
	if (value & BUTTON_B) {
		SPR_setPriority(sonic.sprite, 0);
	}

	// move player
	sonic.x += sonic.speed_x;
	sonic.y += sonic.speed_y;

	// warp at screen bounds
	//warp_at_screen(&sonic);

	SPR_setPosition(sonic.sprite, sonic.x, sonic.y);
}

static inline void update_megaman() {
	for (u8 i = 0; i < MAX_ENEMIES; i++) {
		megaman[i].x += megaman[i].speed_x;
		megaman[i].y += megaman[i].speed_y;

		bounce_off_screen(&megaman[i]);

		SPR_setPosition(megaman[i].sprite, megaman[i].x, megaman[i].y);
	}
}

static inline void draw_position()
{
	intToStr(sonic.x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(sonic.y, text, 2);
	VDP_drawText(text, 5, 24);
}

static inline void init_megaman() {
/*
	Shadow/Hightlight Mode:
	Any plane or sprite with low priority will become shadowed.

	[1] Planes -> sprites (hightlight)
	Any sprites (low priority) that pass under a transparent tile (hight priority) will be highlighted;
	
	[2] Sprites -> planes (hightlight/shadow)
	The planes (high priority) under a sprite (high priority) with PAL3 color 15 will become shadowed; 
	The planes (any priority) under a sprite with (equal or higher priority) PAL3 color 14 will become highlighted;
*/

/*
	When S/H mode is enabled, any sprite pixels that are set to palette 3 color 15 will become
	transparent and the plane pixels under them will become shadowed. Similarly, if set to 
	palette 3 color 14, the pixels under them will become highlighted.
	under color 15 -> shadowed
	under color 14 -> highlighted
*/
	VDP_setPalette(PAL2, spr_megaman.palette->data);

//	SPR_loadAllFrames(&spr_megaman, ind, NULL);
//	SPR_setFrameChangeCallback(megaman.sprite, &frameChanged);
//	ind += spr_megaman.maxNumTile;

	for (u8 i = 0; i < MAX_ENEMIES; i++) {
		megaman[i].x = random() % (VDP_getScreenWidth() - spr_megaman.w);
		megaman[i].y = random() % (VDP_getScreenHeight() - spr_megaman.h);

		megaman[i].speed_x = random() % 3 - 1;
		megaman[i].speed_y = random() % 3 - 1;

		u8 priority = random() % 2;

		megaman[i].sprite = SPR_addSprite(&spr_megaman, megaman[i].x, megaman[i].y, TILE_ATTR(PAL2, priority, FALSE, FALSE));	
//		megaman.sprite = SPR_addSpriteEx(&spr_megaman, (i+1)*50, 50, TILE_ATTR_FULL(PAL2, FALSE, FALSE, FALSE, ind), ind, SPR_FLAG_AUTO_VISIBILITY | SPR_FLAG_AUTO_SPRITE_ALLOC);	
//		SPR_setVisibility(megaman.sprite, TRUE);
//		SPR_setFrame(megaman.sprite, 0);
	}
}

static void init_player() {
	// Initializes Sonic sprite
	sonic.x = 64;
	sonic.y = 155;
	sonic.flip = FALSE;
	sonic.anim = ANIM_STAND;
	VDP_setPalette(PAL3, spr_sonic_sh.palette->data);
	sonic.sprite = SPR_addSprite(&spr_sonic_sh, sonic.x, sonic.y, TILE_ATTR(PAL3, FALSE, FALSE, sonic.flip));
}


static inline void init_background() {
	VDP_setPalette(PAL0, img_bg1.palette->data);
	VDP_setPalette(PAL1, img_bg2.palette->data);
	
	VDP_drawImageEx(BG_B, &img_bg1, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 0, 0, 0, DMA);
	ind += img_bg1.tileset->numTile;

	VDP_drawImageEx(BG_A, &img_bg2, TILE_ATTR_FULL(PAL1, 1, 0, 0, ind), 20, 0, 0, DMA);
	ind += img_bg2.tileset->numTile;	
}

int main() {
	SYS_disableInts();

	VDP_setScreenWidth320(); // 320x240
	SPR_init(0, 0, 0);

	VDP_setHilightShadow(TRUE);

	KLog_memory();

//	VDP_showFPS(FALSE);

	// Initializes Background
	ind = 1; // first position to load a tile in VRAM
	init_background();
	init_player();
	init_megaman();

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	VDP_drawText("BG A (prio=1) ", 21, 25);

	VDP_drawText("SHADOW HIGHLIGHT  ", 1, 24);
	VDP_drawText("BG B (prio=0)     ", 1, 25);
	VDP_drawText("Press A/B priority", 1, 26);

	SYS_enableInts();

	KLog_memory();

	while (1) {
		// handle input
		update_player();
//		update_megaman();

//		draw_position();

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
