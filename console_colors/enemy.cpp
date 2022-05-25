#include <iostream>
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
    Console::set_cursor(screen_row, screen_col);
    Console::set_color_fg256(196);
    cout << "🤖";

    Console::set_cursor(screen_row+1, screen_col);
    cout << this->name;

    Console::set_cursor(screen_row+2, screen_col);
    cout << this->description;

    Console::set_cursor(screen_row+3, screen_col);
    cout << this->grunt;
}