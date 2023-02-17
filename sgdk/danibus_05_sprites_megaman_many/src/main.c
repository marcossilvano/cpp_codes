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

#define PLAYER_ANIM_STAND 0
#define PLAYER_ANIM_WALK  1

#define WASP_ANIM 0
#define CRAB_ANIM 1

#define SPEED 1

#define MAX_ENEMIES 70

#define MAX_ANIM_TABLE 1 // for now, just 1 sprite beeing allocated (Megaman)
#define TABLE_INDEX_MEGAMAN 0

typedef struct GameObject {
	Sprite* sprite;
	s16 x;
	s16 y;
	s16 speed_x;
	s16 speed_y;
	u16 flip;
	u16 anim;
	u8 data[];
} GameObject;

// GLOBALS ///////////////////////////////////////////////////

// function declaration
static void update_player();
static void draw_position();

static GameObject sonic;
static GameObject megaman[MAX_ENEMIES];

// animation index tables for sprites fully loaded (static VRAM loading)
u16** anim_tables[MAX_ANIM_TABLE];

static char text[5];

static u16 ind; // index for tiles loading in VRAM

// FUNCTIONS /////////////////////////////////////////////////

static inline void KLog_memory() {
	KLog_U1("MEMORY:  ", MEM_getFree()+MEM_getAllocated());
	KLog_U1("  Free:  ", MEM_getFree());
	KLog_U1("  Alloc: ", MEM_getAllocated());
}
/*
static void warp_at_screen(GameObject* obj) {
	if (obj->x < -obj->sprite->definition->w) {
		obj->x = VDP_getScreenWidth();	
	}
	else if (obj->x > VDP_getScreenWidth()) {
		obj->x = -obj->sprite->definition->w;
	}
}
*/
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

	if (value & BUTTON_UP) {
		sonic.speed_y = -SPEED;
		sonic.anim = 2;
	} else
	if (value & BUTTON_DOWN) {
		sonic.speed_y = SPEED;
		sonic.anim = 3;
	}

	if (value & BUTTON_LEFT) {
		sonic.speed_x = -SPEED;
		sonic.flip = TRUE;
		sonic.anim = 1;
	}else
	if (value & BUTTON_RIGHT) {
		sonic.speed_x = SPEED;
		sonic.flip = FALSE;
		sonic.anim = 1;
	}

/**
	if (value & BUTTON_A) {
		SPR_setPriority(sonic.sprite, 1);
	} else
	if (value & BUTTON_B) {
		SPR_setPriority(sonic.sprite, 0);
	}
*/
	// move player
	sonic.x += sonic.speed_x;
	sonic.y += sonic.speed_y;

	// warp at screen bounds
	//warp_at_screen(&sonic);

	if (sonic.speed_x == 0 && sonic.speed_y == 0) {
		sonic.anim = 0;
	}

	SPR_setPosition(sonic.sprite, sonic.x, sonic.y);
	SPR_setHFlip(sonic.sprite, sonic.flip);
	SPR_setAnim(sonic.sprite, sonic.anim);
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
	intToStr(SPR_getNumActiveSprite()+1, text, 1);
	VDP_drawText(text, 10, 3);
}

static void frame_changed(Sprite* sprite) {
    // Use the 'sprite anim table' index (stored in data field)
	//  - There is one for each sprite type
    //  - Get VRAM tile index for the animation of this sprite passed as function parameter

	//				anim_tables[which_sprite][which_animation][which_frame]
    u16 tile_index = anim_tables[sprite->data][sprite->animInd][sprite->frameInd];
    
	// manually set tile index for the current frame (preloaded in VRAM)
    SPR_setVRAMTileIndex(sprite, tile_index);
}

static inline void log_sprite(const SpriteDefinition* spr_def) {
	KLog_U1("numAnimation: ", spr_def->numAnimation); 
	KLog_U1("maxNumTile: ", spr_def->maxNumTile); 

	for (u8 i = 0; i < spr_def->numAnimation; i++) {
		Animation* anim = spr_def->animations[i];

		KLog_U3("  animation=", i, "  timer=", anim->frames[0]->timer, "  frames=", anim->numFrame);
		for (u8 j = 0; j < anim->numFrame; j++) {
			AnimationFrame* frame = anim->frames[j];
			KLog_U2("     frame=", frame, "  tileset=", frame->tileset);

			for (u8 k = 0; k < frame->numSprite; k++) {
				KLog_U1("      VDPSpriteTiles=", frame->frameVDPSprites[k].numTile);
			}
		}
	}
}

static inline void init_megaman() {
	VDP_setPalette(PAL2, spr_megaman.palette->data);

	for (u8 i = 0; i < MAX_ENEMIES; i++) {
		megaman[i].x = random() % (VDP_getScreenWidth() - spr_megaman.w);
		megaman[i].y = random() % (VDP_getScreenHeight() - spr_megaman.h);

		megaman[i].speed_x = random() % 3 - 1;
		megaman[i].speed_y = random() % 3 - 1;

		//u8 priority = random() % 2;
		u8 priority = 1;
	
//		megaman[i].sprite = SPR_addSprite(&spr_megaman, megaman[i].x, megaman[i].y, TILE_ATTR(PAL2, priority, FALSE, FALSE));	
//        // disable auto tile upload for enemies sprites as we will pre-load all animation frams in VRAM for them
//        SPR_setAutoTileUpload(megaman[i].sprite, FALSE);

		megaman[i].sprite = SPR_addSpriteEx(&spr_megaman, megaman[i].x, megaman[i].y, 
							TILE_ATTR_FULL(PAL2, priority, FALSE, FALSE, ind), -1, // sprite table index (ignored) 
							SPR_FLAG_AUTO_VISIBILITY | SPR_FLAG_AUTO_SPRITE_ALLOC);
							

        // set frame change callback for enemies so we can update tile index easily
        SPR_setFrameChangeCallback(megaman[i].sprite, &frame_changed);
        // store sprite 'animation table' index in sprite's 'data' field (available to use as needed)
		// it is needed in frame_changed function
        megaman[i].sprite->data = TABLE_INDEX_MEGAMAN;
	}
	u16 total_tiles;
	//SPR_loadAllFrames(&spr_megaman, ind, &total_tiles);
	anim_tables[TABLE_INDEX_MEGAMAN] = SPR_loadAllFrames(&spr_megaman, ind, &total_tiles);
	ind += total_tiles;
/**/
//	SPR_logProfil();
//	SPR_logSprites();
}

/**
 * @brief Creates a new SpriteDefinition with added animations
 * 
 * @param spr_def Original SpriteDefinition provided by rescomp
 * @return SpriteDefinition New SpriteDeficton with added animations 
 */
static SpriteDefinition create_new_animations(const SpriteDefinition* spr_def, u8 numAnimation) {
	SpriteDefinition spr_copy = *spr_def;
	
	// remove current animation list
	free(spr_copy.animations[0]); // first animation
	free(spr_copy.animations);	  // list of animations
	
	// allocate a new list of animations
	spr_copy.numAnimation = 0;
	spr_copy.animations = (Animation**) malloc(numAnimation * sizeof(Animation*));

	return spr_copy;
}

static void add_new_animation(SpriteDefinition* spr_def, AnimationFrame** all_frames, u8 anim_index, 
						  u8 loop, u8 num_frames, u8* frame_indexes) {

	Animation* anim = (Animation*) malloc(sizeof(Animation));

	anim->numFrame = num_frames;
	anim->loop = loop;
	anim->frames = (AnimationFrame**) malloc(num_frames * sizeof(AnimationFrame*)); // list of frames

	for (u8 i = 0; i < num_frames; i++) {
		anim->frames[i] = all_frames[frame_indexes[i]];
	}

	spr_def->animations[anim_index] = anim;
	spr_def->numAnimation++;
/*
	SpriteDefinition
		u16 	 w
		u16 	 h
		Palette* palette
		u16 	numAnimation
		u16 	maxNumTile
		u16 	maxNumSprite
		Animation** animations
			u8 	numFrame
			u8 	loop
			AnimationFrame** frames
				u8 	numSprite
				u8 	timer
				TileSet * 	tileset
				Collision * collision
				FrameVDPSprite 	frameVDPSprites []
*/
}

static void init_player() {
/*
	// there is only one row with all sprite frames
	// copy the address of the frames address array
	AnimationFrame** all_frames = spr_sonic.animations[0]->frames;

	// hacks the SpriteDefinition struct and add animations
	SpriteDefinition spr_sonic_new = create_new_animations(&spr_sonic, 2);

	u8 anim_stand[] = {1,5,1,5};
	add_new_animation(&spr_sonic_new, all_frames, PLAYER_ANIM_STAND, TRUE, 4, anim_stand);
	
	u8 anim_walk[] = {0,1,2,3,4,5,6,7};
	add_new_animation(&spr_sonic_new, all_frames, PLAYER_ANIM_WALK, TRUE, 8, anim_walk);

	log_sprite(&spr_sonic_new);
*/
	// Initializes Sonic sprite
	sonic.x = 64;
	sonic.y = 155;
	sonic.flip = FALSE;
	sonic.anim = ANIM_STAND;
	VDP_setPalette(PAL3, spr_sonic.palette->data);
	sonic.sprite = SPR_addSprite(&spr_sonic, sonic.x, sonic.y, TILE_ATTR(PAL3, TRUE, FALSE, sonic.flip));
	SPR_setAnim(sonic.sprite, 0);

	log_sprite(&spr_sonic);
}

static inline void init_background() {
	VDP_setPalette(PAL0, img_bg1.palette->data);
	VDP_setPalette(PAL1, img_bg3.palette->data);
	
	VDP_drawImageEx(BG_B, &img_bg1, TILE_ATTR_FULL(PAL0, 1, 0, 0, ind), 0, 0, 0, DMA);
	ind += img_bg1.tileset->numTile;

	VDP_drawImageEx(BG_A, &img_bg3, TILE_ATTR_FULL(PAL1, 1, 0, 0, ind), 0, 0, 0, DMA);
	ind += img_bg3.tileset->numTile;	
}

int main() {
	SYS_disableInts();

	VDP_setScreenWidth320(); // 320x240
	SPR_init(0, 0, 0);

	//VDP_setHilightShadow(TRUE);

	//KLog_memory();

//	VDP_showFPS(FALSE);

	// Initializes Background
	ind = 1; // first position to load a tile in VRAM
	init_background();
	init_megaman();
	//log_sprite(&spr_megaman);
	init_player();

	// Initilizes text UI
	VDP_setTextPalette(PAL1);
	VDP_drawText("SPRITE STRESS TEST  ", 1, 2);
	VDP_drawText("sprites: ", 1, 3);

	SYS_enableInts();

	//KLog_memory();

	while (1) {
		// handle input
		update_player();
		update_megaman();

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
