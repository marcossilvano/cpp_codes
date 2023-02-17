/*
	Task -> RUN (ctrl + shift + B)
	Task -> Clean
*/

#include <genesis.h>

int main()
{
	VDP_drawText("Hello Sega World!", 10, 13);

	while(1)
	{        
		// read input
		// move sprites
		// update hud

		// wait for screen refresh
		VDP_waitVSync();
	}
	return (0);
}
