#include <genesis.h>

u8 text_x = 10;
u8 text_y = 13;
char str[] = "Hello SEGA World!";

static void handle_input() {
	u16 input = JOY_readJoypad(JOY_1);

	if (input & BUTTON_LEFT) {
		if (text_x > 0)
			text_x--;
		//str[0] = 'L';
	} else
	if (input & BUTTON_RIGHT) {
		if (text_x < 40-17)
			text_x++;
		//str[0] = 'R';
	}
}

int main()
{
	JOY_init();

	VDP_drawText("PRESS LEFT/RIGHT", 2, 2);

	while(1)
	{        
		// read input
		handle_input();
		// move sprites
		
		//VDP_clearTextArea(0, 0, 320, 224);
		VDP_clearTextArea(text_x-1, 5, 17+2, 23-5+1);

		// update hud
		for (u8 i = 5; i <= 23; i += 1) {	
			VDP_drawText(str, text_x, i);
		}

		// wait for screen refresh
		//VDP_waitVSync();
		SYS_doVBlankProcess();
	}
	return (0);
}
