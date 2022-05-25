#include "player.h"
#include "console.h"

Player::Player(string name, int row, int col, int hp, int max_hp, int xp_to_next_level, Stats stats) 
    : Entity(name, hp, max_hp, stats)
{
    this->row = row;
    this->col = col;
    
    this->level = 1;
    this->xp = 0;
    this->xp_to_next_level = xp_to_next_level;
}

// overrides Entity::print()
void Player::print(int screen_row, int screen_col)
{
    int row = screen_row;

    print_sprite(row, screen_col);
    row += sprite.size() + 1;

    Console::set_color_fg256(28);
    Console::set_cursor(row++, screen_col);
    cout << name << ": ";
    
    Console::set_cursor(row++, screen_col);
    cout << "   lvl: " << level;

    Console::set_cursor(row++, screen_col);
    cout << "   xp:  " << xp << '/' << xp_to_next_level;

    row++;
    print_stats(row, screen_col);
}
