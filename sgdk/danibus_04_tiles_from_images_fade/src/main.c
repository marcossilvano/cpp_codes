#include "genesis.h"
#include "resources.h"

// function declaration
static void handleInput();

static u16 posX;
static char text[2];
static u8 bright;

// vector where we will copy the colors of the palette/s
//  IT IS NOT THE PALETTE, it is a vector and modifying it does not modify the palette
static u16 full_palette[64] = {0};

static void do_fade() {
	if (!bright)
		PAL_fadeIn(0, 63, full_palette, 20, FALSE);
	else 
		PAL_fadeOut(0, 63, 20, FALSE);

	bright = !bright;
}

int main()
{

	// to keep track of tiles in VRAM
	// Tiles in VRAM from the 2nd pos (1st tile to paint the background)
	u16 ind = 1;
	bright = FALSE;

	// disable access to the VDP
	/*
	Temporarily disables any type of interrupt (Vertical, Horizontal and External) when
	VDP, that way we can 'touch' it at will without an interruption stopping what we are
	doing and leave half the work
	*/
	SYS_disableInts();

	// Initializes to 320x240px
	VDP_setScreenWidth320();

	// We put the WHOLE PALETTE (4 palettes) in black to do a fade_in (from black screen to normal screen)
	VDP_setPaletteColors(0, (u16 *)palette_black, 64); // palette_black is from SGDK

	// load images into VRAM and increment ind
	VDP_drawImageEx(VDP_PLAN_B, &moon2, TILE_ATTR_FULL(PAL0, FALSE, FALSE, FALSE, ind), 5, 7, FALSE, DMA);
	ind += moon2.tileset->numTile;
	VDP_drawImageEx(VDP_PLAN_A, &sonic, TILE_ATTR_FULL(PAL1, FALSE, FALSE, FALSE, ind), 20, 7, FALSE, DMA);
	ind += sonic.tileset->numTile;

	// We re-enable the VDP interrupts
	SYS_enableInts();

	// build the final palette from image's palettes
	memcpy(&full_palette[0], moon2.palette->data, 16 * 2);
	memcpy(&full_palette[16], sonic.palette->data, 16 * 2);

	// FADE IN
	/* PAL_fadeIn(from_color, to_color, pal_final, num_frames, asyn)
	This function fades-in from current palette to final palette
	from_color = 0, to_color=63 (all palette)
	'asyn' =0 or FALSE --> The program stops until the fade-in is finished
	'asyn' =0 or TRUE --> The program continues while the fade-in is done
	*/
	// Try changing TRUE and FALSE
//	PAL_fadeIn(0, 63, full_palette, 30, FALSE);
//	bright = true;
	do_fade();

	VDP_drawText("FADE AND INPUT SAMPLE",2,1);
	VDP_drawText("Press START to fade",2,3);
	VDP_drawText("UDLRABCSXYZM",5,19);
	VDP_drawText("JOY 1",3,17);

	while (1)
	{
		// handle input
		// update physics
		// update animations
		// update sprites
		// SYS_doVBlankProcess();
		// update VDP scroll
		
		// read controls, always called once per frame
		handleInput();
	
		SYS_doVBlankProcess();
	}

	return 0;
}

static void printChar(char c, u16 state) {
	text[0] = c;
	text[1] = 0; // NULL
	if (state) {
		//VDP_drawText(text, posX, 10);
		VDP_drawText("*", posX, 18);
	}
	posX += 1;
}

static void handleInput()
{
	u16 value = JOY_readJoypad(JOY_1);
	u16 type = JOY_getJoypadType(JOY_1);
	posX = 5;

	VDP_clearTextArea(5,18,12,1);

	printChar('U', value & BUTTON_UP);
	printChar('D', value & BUTTON_DOWN);
	printChar('L', value & BUTTON_LEFT);
	printChar('R', value & BUTTON_RIGHT);
	printChar('A', value & BUTTON_A);
	printChar('B', value & BUTTON_B);
	printChar('C', value & BUTTON_C);
	printChar('S', value & BUTTON_START);
	if (type == JOY_TYPE_PAD6)
	{
		printChar('X', value & BUTTON_X);
		printChar('Y', value & BUTTON_Y);
		printChar('Z', value & BUTTON_Z);
		printChar('M', value & BUTTON_MODE);
	}

	if (value & BUTTON_START) {
		do_fade();
	}
}