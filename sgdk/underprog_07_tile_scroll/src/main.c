#include <genesis.h>
#include "resources.h"

#define PLANE_W FIX16(256)
#define SCREEN_TILES_H 224/8 // 28 tiles 8x8
#define SCREEN_TILES_W 320/16// 20 meta-tiles 16x16

#define STATE_HORZ_SCROLL 0
#define STATE_VERT_SCROLL 1

fix16 offset_mask[SCREEN_TILES_H] = {0}; // 224 px / 8 px = 28
fix16 offset_speed[SCREEN_TILES_H];

static inline void set_offset_speed(u8 start, u8 len, fix16 speed) {
	if (start+len-1 >= SCREEN_TILES_H) {
		return;
	}
	for (u8 i = start; i <= start+len-1; i++) {
		offset_speed[i] = speed;
	}
}

static inline void reset_scroll() {
	for (u8 i = 0; i < SCREEN_TILES_H; i++) {
		offset_mask[i] = 0;
	}

	VDP_setVerticalScrollTile(BG_B, 0, offset_mask, SCREEN_TILES_W, CPU);
	VDP_setHorizontalScrollTile(BG_B, 0, offset_mask, SCREEN_TILES_H, CPU);
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
	u16 ang = 0;
	u8 state = STATE_HORZ_SCROLL;
    //VDP_drawImageEx(BG_A, &img_back2, TILE_ATTR_FULL(PAL1, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	//ind += img_back2.tileset->numTile;

    VDP_drawImageEx(BG_B, &img_back1, TILE_ATTR_FULL(PAL0, 0, 0, 0, ind), 0, 0, FALSE, DMA);
	ind += img_back1.tileset->numTile;

	//VDP_setScrollingMode(HSCROLL_PLANE, VSCROLL_PLANE);
	VDP_setScrollingMode(HSCROLL_TILE , VSCROLL_2TILE);
    
	draw_text_centered("HORZ TILE SCROLL", 2);
	draw_text_centered("Press A to switch", 4);

	set_offset_speed(0, 3, FIX16(0.1));
	set_offset_speed(3, 10, FIX16(0.2));
	set_offset_speed(13, 5, FIX16(0.4));
	for (u8 i = 0; i < 10; i++) {
		set_offset_speed(i+18, 1, FIX16(0.5 + i * 0.3));
	}

	s16 values[SCREEN_TILES_H];

	while(1)
    {
		u16 input = JOY_readJoypad(JOY_1);

		if (state == STATE_HORZ_SCROLL) {

			for (u8 i = 0; i < SCREEN_TILES_H; i++) {
				if (offset_mask[i] > PLANE_W) {
					offset_mask[i] -= PLANE_W;
				}
				// store next offset in fix16
				offset_mask[i] += offset_speed[i];
				
				// cast to integer to input on VDP
				values[i] = fix16ToInt(offset_mask[i]);
			}

			VDP_setHorizontalScrollTile(BG_B, 0, values, SCREEN_TILES_H, CPU);

			if (input & BUTTON_A) {
				state = STATE_VERT_SCROLL;
				reset_scroll();
				draw_text_centered("BOTH TILE SCROLL", 2);
				draw_text_centered("Press B to switch", 4);
			}

		} else
		if (state == STATE_VERT_SCROLL) {
			VDP_setVerticalScrollTile(BG_B, 0, offset_mask, SCREEN_TILES_W, CPU);
			VDP_setHorizontalScrollTile(BG_B, 0, offset_mask, SCREEN_TILES_H, CPU);
			
			for (u8 i = 0; i < 20; i++) {
				// POS_Y = CONST + Fn_Sine(value*accelerator) * mod_amplitud
				offset_mask[i] = sinFix16((i*3+ang) * 14) / 8;
			}
			ang+=1;

			if (input & BUTTON_B) {
				state = STATE_HORZ_SCROLL;
				reset_scroll();
				draw_text_centered("HORZ TILE SCROLL", 2);
				draw_text_centered("Press A to switch", 4);
			}
		}

		SYS_doVBlankProcess();
    }

    return (0);
}
