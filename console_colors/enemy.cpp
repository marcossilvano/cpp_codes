#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include "enemy.h"
#include "console.h"

Enemy::Enemy(string name, int hp, int max_hp, string description, string grunt, Stats stats)
    : Entity(name, hp, max_hp, stats)
{
    this->description = description;
    this->grunt = grunt;
}

void Enemy::print(int screen_row, int screen_col)
{
    int row = screen_row;

    print_sprite(row, screen_col);
    row += sprite.size() + 1;

    Console::set_color_fg256(89);
    Console::set_cursor(row++, screen_col);
    cout << name << ": ";
    
    Console::set_cursor(row++, screen_col);
    cout << "  " << description;

    Console::set_cursor(row++, screen_col);
    cout << "  \"" << grunt << "\"";

    row++;
    print_stats(row, screen_col);
}