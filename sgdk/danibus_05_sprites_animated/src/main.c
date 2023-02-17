/**
 * Para compilar:
 * ----------------------
 *   CTRL + SHIFT + B
 *   (gera out/rom.bin )
 */

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

#define SPEED 3

// function declaration
static void handle_input();
static void draw_position();

static Sprite *sonic_sprite;
static s16 sonic_x;
static s16 sonic_y;
static u16 sonic_flip;
static s16 sonic_anim;

static char text[5];

static void handle_input()
{
	u16 value = JOY_readJoypad(JOY_1);

	if (value & BUTTON_LEFT) {
		sonic_x -= SPEED;
		sonic_flip = TRUE;
		sonic_anim = ANIM_RUN;
	}
	if (value & BUTTON_RIGHT) {
		sonic_x += SPEED;
		sonic_flip = FALSE;
		sonic_anim = ANIM_RUN;
	}
	if (value & BUTTON_UP)
		sonic_y -= SPEED;
	if (value & BUTTON_DOWN)
		sonic_y += SPEED;

	if (!value) {
		sonic_anim = ANIM_STAND;
	}

	// warp at screen bounds
	if (sonic_x < -sonic_sprite->definition->w) {
		sonic_x = VDP_getScreenWidth();	
	}
	else if (sonic_x > VDP_getScreenWidth()) {
		sonic_x = -sonic_sprite->definition->w;
	}

	SPR_setPosition(sonic_sprite, sonic_x, sonic_y);
	SPR_setHFlip(sonic_sprite, sonic_flip);
	SPR_setAnim(sonic_sprite, sonic_anim);
}

static void draw_position()
{
	intToStr(sonic_x, text, 2);
	VDP_drawText(text, 5, 23);

	intToStr(sonic_y, text, 2);
	VDP_drawText(text, 5, 24);
}

int main()
{
	// Initializes to 320x240px
	VDP_setScreenWidth320();

	// Initializes Background
	u16 ind = 1; // index for tiles in VRAM (first tile reserved for SGDK)
	VDP_setPalette(PAL1, img_bg.palette->data);
	VDP_drawImageEx(VDP_PLAN_B, &img_bg, TILE_ATTR(PAL1, 1, 0, 0), 0, 0, 1, CPU);
	ind += img_bg.tileset->numTile;

	// Initializes Sonic sprite
	sonic_x = 64;
	sonic_y = 155;
	sonic_flip = FALSE;
	SPR_init(0, 0, 0);
	VDP_setPalette(PAL0, spr_sonic.palette->data);
	sonic_sprite = SPR_addSprite(&spr_sonic, sonic_x, sonic_y, TILE_ATTR(PAL0, FALSE, FALSE, sonic_flip));

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	VDP_drawText("ANIMATED SPRITE SAMPLE", 1, 1);
	VDP_drawText("Use DPAD to move", 1, 3);
	VDP_drawText("X: ", 2, 23);
	VDP_drawText("Y: ", 2, 24);

	while (1)
	{
		// handle input
		handle_input();

		draw_position();

		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		// update VDP scroll
	}

	return 0;
}
