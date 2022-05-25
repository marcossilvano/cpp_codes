#pragma once

#include "entity.h"

class Player : public Entity
{
private:
    int row;
    int col;
    int xp;
    int xp_to_next_level;
    int level;

public:
    Player(string name, int row, int col, int hp, int max_hp, int xp_to_next_level, Stats stats);
    void print(int screen_row, int screen_col) override;
};
