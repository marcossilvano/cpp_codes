#include <genesis.h>
#include "resources.h"

#define PLANE_W FIX16(256)
#define SCREEN_LINES 224

#define STATE_HORZ_SCROLL 0
#define STATE_VERT_SCROLL 1

// GLOBALS ////////////////////////////////////////////////////

// PLANE B
fix16 offsetB_pos[SCREEN_LINES] = {0}; 
fix16 offsetB_speed[SCREEN_LINES];

// PLANE A
fix16 offsetA_pos[SCREEN_LINES] = {0};
fix16 offsetA_speed = FIX16(2);

// color rotation delay
u8 color_delay = 5;

// FUNCTIONS //////////////////////////////////////////////////

static inline void set_offset_speed(u8 start, u8 len, fix16 speed) {
	if (start+len-1 >= SCREEN_LINES) {
		return;
	}
	for (u8 i = start; i <= start+len-1; i++) {
		offsetB_speed[i] = speed;
	}
}
/*
static inline void reset_scroll() {
	for (u8 i = 0; i < SCREEN_TILES_H; i++) {
		offsetB_pos[i] = 0;
	}

	VDP_setVerticalScrollTile(BG_B, 0, offsetB_pos, SCREEN_TILES_W, CPU);
	VDP_setHorizontalScrollTile(BG_B, 0, offsetB_pos, SCREEN_TILES_H, CPU);
}
*/

static void rotate_color(u8 first_index, u8 last_index, u8 rotate_right) {
	if (color_delay-- == 0) {
		if (!rotate_right) {
			u16 color = VDP_getPaletteColor(first_index);
			for (u8 i = first_index; i < last_index; i++) {
				VDP_setPaletteColor(i, VDP_getPaletteColor(i+1));
			}
			VDP_setPaletteColor(last_index, color);
		} else {
			u16 color = VDP_getPaletteColor(last_index);
			for (u8 i = last_index; i > first_index; i--) {
				VDP_setPaletteColor(i, VDP_getPaletteColor(i-1));
			}
			VDP_setPaletteColor(first_index, color);
		}
		color_delay = 5;
	}   	
}

static inline void draw_text_centered(const char* str, u16 y) {
	VDP_drawTextBG(BG_A, str, (40-strlen(str))/2, y);
}

int main()
{
	VDP_setPalette(PAL0, img_back1.palette->data);
	VDP_setPalette(PAL1, img_back2.palette->data);

	VDP_setPlaneSize(32,32, TRUE);

	u16 ind = 1;
	//u16 ang = 0;
	//u8 state = STATE_HORZ_SCROLL;
    VDP_drawImageEx(BG_B, &img_back1, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	ind += img_back1.tileset->numTile;

    VDP_drawImageEx(BG_A, &img_back2, TILE_ATTR_FULL(PAL1, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	ind += img_back2.tileset->numTile;

	//VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);
	//VDP_setScrollingMode(HSCROLL_TILE , VSCROLL_2TILE);
	VDP_setScrollingMode(HSCROLL_LINE , VSCROLL_PLANE);
    
	draw_text_centered("HORZ LINE SCROLL", 2);
	//draw_text_centered("Press A to switch", 4);

	// initializes speed for each background "slice" 
	set_offset_speed(0, 3*8, FIX16(0.1));
	set_offset_speed(3*8, 10*8, FIX16(0.2));
	set_offset_speed(13*8, 5*8, FIX16(0.4));
	
	for (u8 i = 0; i < 223-144+1; i++) {
		set_offset_speed(i+144, 1, FIX16(0.5 + i * 0.05));
	}

	// vector for final INT values
	s16 values[SCREEN_LINES]; 

	while(1)
    {
		//u16 input = JOY_readJoypad(JOY_1);

		// MOVE PLANE B (background)

		for (u8 i = 0; i < SCREEN_LINES; i++) {
			if (offsetB_pos[i] > PLANE_W) {
				offsetB_pos[i] -= PLANE_W;
			}
			// store next offset in fix16
			offsetB_pos[i] += offsetB_speed[i];
			
			// cast to integer to input on VDP
		 	values[i] = fix16ToInt(offsetB_pos[i]);
		}
		VDP_setHorizontalScrollLine(BG_B, 0, values, SCREEN_LINES, DMA);
		
		// MOVE PLANE A (foreground)
/*
		for (u8 i = 0; i < SCREEN_LINES; i++) {
			if (offsetA_pos[i] > PLANE_W) {
				offsetA_pos[i] -= PLANE_W;
			}
			offsetA_pos[i] += offsetA_speed;

			// cast to integer to input on VDP
		 	values[i] = fix16ToInt(offsetA_pos[i]);
		}
		VDP_setHorizontalScrollLine(BG_A, 0, values, SCREEN_LINES, DMA);
*/
		rotate_color(8, 11, TRUE);
/*
			if (input & BUTTON_A) {
				state = STATE_VERT_SCROLL;
				reset_scroll();
				draw_text_centered("BOTH TILE SCROLL", 2);
				draw_text_centered("Press B to switch", 4);
			}
*/
		SYS_doVBlankProcess();
    }

    return (0);
}
