#include <genesis.h>

#include "sprite_eng.h"
#include "resources.h"

// function declaration
static void handle_input();
static void draw_position();

static Sprite *sonic_sprite;
static s16 sonic_x;
static s16 sonic_y;
static u16 sonic_flip;

static char text[5];

static void handle_input()
{
	u16 value = JOY_readJoypad(JOY_1);

	if (value & BUTTON_LEFT) {
		sonic_x--;
		sonic_flip = TRUE;
	}
	if (value & BUTTON_RIGHT) {
		sonic_x++;
		sonic_flip = FALSE;
	}
	if (value & BUTTON_UP)
		sonic_y--;
	if (value & BUTTON_DOWN)
		sonic_y++;

	SPR_setPosition(sonic_sprite, sonic_x, sonic_y);
	SPR_setHFlip(sonic_sprite, sonic_flip);
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
	sonic_x = 0;
	sonic_y = 50;
	sonic_flip = FALSE;

	// Initializes to 320x240px
	VDP_setScreenWidth320();

	// Initializes sprites in SGDK
	SPR_init(0, 0, 0);

	VDP_setPalette(PAL1, img_sonic.palette->data);

	sonic_sprite = SPR_addSprite(&img_sonic, sonic_x, sonic_y, TILE_ATTR(PAL1, FALSE, FALSE, TRUE));

	VDP_setTextPalette(PAL1);
	VDP_drawText("SPRITE SAMPLE", 1, 1);
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
