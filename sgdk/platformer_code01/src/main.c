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
#define ANIM_RUN        1
#define ANIM_JUMP       2
#define ANIM_FALL       3

#define FLOOR_Y 146
#define SPEED 3

#define ILE_SIZE 16
#define SCREEN_X 320
#define SCREEN_Y 224

// function declaration
void handle_input();
void draw_position();

typedef struct GameObject {
	Sprite* sprite;
	s16 x;
	s16 y;
	f16 speed_x;
	f16 speed_y;
	u8 flip;
	u8 anim;
} GameObject;

GameObject sonic;
bool on_floor = FALSE;

Map* map;
u8 collision_map[SCREEN_X/TILE_SIZE][SCREEN_Y/TILE_SIZE] = {0}; // size of screen

int hscroll_offset = 0;
char text[5];
u8 color_delay = 5;

// index for tiles in VRAM (first tile reserved for SGDK)
u16 ind = 1; 
//u16 ind = TILE_USER_INDEX;

////////////////////////////////////////////////////////////////////////////
// FUNCTIONS

inline bool is_on_floor(GameObject* obj) {
	if (obj->y >= FLOOR_Y) {
		obj->y = FLOOR_Y;
		return TRUE;
	} else {
		return FALSE;
	}
}

inline void wrap_at_bounds(GameObject* obj) {
	if (obj->x < -obj->sprite->definition->w/2) {
		obj->x = VDP_getScreenWidth() - obj->sprite->definition->w/2;	
	}
	else if (obj->x > VDP_getScreenWidth() - obj->sprite->definition->w/2) {
		obj->x = -obj->sprite->definition->w/2;
	}
}

inline void animate_player() {
	// animation
	if (sonic.speed_y < 0)
		sonic.anim = ANIM_JUMP;
	else 
	if (sonic.speed_y > 0)
		sonic.anim = ANIM_FALL;
	else
	if (sonic.speed_x)
		sonic.anim = ANIM_RUN;
	else
		sonic.anim = ANIM_STAND;
}

inline void get_player_input() {
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

	if (value & BUTTON_A && on_floor)
		sonic.speed_y = FIX16(-5);
}

void handle_input()
{
	// gravity
	on_floor = is_on_floor(&sonic);
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
	get_player_input();

	// movement
	sonic.x = sonic.x + fix16ToInt(sonic.speed_x);
	sonic.y = sonic.y + fix16ToInt(sonic.speed_y);

	// wrap at screen bounds
	wrap_at_bounds(&sonic);

	// animate
	animate_player();

	// update VDP
	SPR_setPosition(sonic.sprite, sonic.x, sonic.y);
	SPR_setHFlip(sonic.sprite, sonic.flip);
	SPR_setAnim(sonic.sprite, sonic.anim);
}

////////////////////////////////////////////////////////////////////////////
// DRAWING AND FX

static void draw_info()
{
	VDP_drawText("PLATFORMER SAMPLE", 1, 1);
	VDP_drawText("Use DPAD and A", 1, 3);

	VDP_drawText("X: ", 2, 23);
	intToStr(sonic.x, text, 2);
	VDP_drawText(text, 5, 23);

	VDP_drawText("Y: ", 2, 24);
	intToStr(sonic.y, text, 2);
	VDP_drawText(text, 5, 24);
}

static void rotate_colors(u8 first_index, u8 last_index)
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

////////////////////////////////////////////////////////////////////////////
// MAIN CODE

inline void init_map() {
	PAL_setPalette(PAL1, level1_palette.data, DMA);
	VDP_loadTileSet(&level1_tileset, ind, DMA);
	map = MAP_create(&level1_map, BG_A, TILE_ATTR_FULL(PAL1, FALSE, FALSE, FALSE, ind));
	ind += level1_tileset.numTile;
	KLog_U1("tileset tiles ", level1_tileset.numTile);
	MAP_scrollToEx(map, 0, 0, TRUE);

	VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);
}

inline void init_player() {
	sonic.x = 64;
	sonic.y = 155;
	sonic.speed_x = FIX16(0);
	sonic.speed_y = FIX16(0);
	sonic.flip = FALSE;
	SPR_init();
	PAL_setPalette(PAL0, spr_boy.palette->data, CPU);
	sonic.sprite = SPR_addSprite(&spr_boy, sonic.x, sonic.y, TILE_ATTR_FULL(PAL0, FALSE, FALSE, sonic.flip, ind));
}

int main()
{
	// Initializes to 320x240px
	VDP_setScreenWidth320();
	
	// Initializes Map
	init_map();

	// Initializes player sprite
	init_player();

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	//VDP_setBackgroundColor(PAL_getColor(5));

	while (1)
	{
		// handle input
		handle_input();

		draw_info();
		
		VDP_setHorizontalScroll(BG_B, hscroll_offset);
		//VDP_setVerticalScroll(BG_B, hscroll_offset);
		//hscroll_offset--;

		rotate_colors(24, 27);
		// update physics
		// update animations
		// update sprites
		SPR_update();

		SYS_doVBlankProcess();
		// update VDP scroll
	}

	return 0;
}
