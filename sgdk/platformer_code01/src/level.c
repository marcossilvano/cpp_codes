#include "level.h"

Map* map;
u8 collision_map[SCREEN_W/TILE_W][SCREEN_H/TILE_W] = {0}; // size of screen

fix16 offset_mask[SCREEN_H/TILE_W] = {0}; // 224 px / 8 px = 28
fix16 offset_speed[SCREEN_H/TILE_W];
