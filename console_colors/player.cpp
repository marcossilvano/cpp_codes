#include "player.h"

Player::Player(string name, int row, int col, int hp, int max_hp, int xp_to_next_level, Stats stats) 
    : Entity(name, hp, max_hp, stats)
{
    this->row = row;
    this->col = col;
    
    this->level = 0;
    this->xp = 0;
    this->xp_to_next_level = xp_to_next_level;
}

// overrides Entity::print()
void Player::print(int screen_row, int screen_col)
{

}
