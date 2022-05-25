#include <vector>
#include <string>
#include <algorithm>

#include "entity.h"
#include "console.h"

Entity::Entity(string name, int hp, int max_hp, Stats stats) 
{
    this->name = name;
    this->hp = hp;
    this->max_hp = max_hp;
    this->stats = stats;
}

void Entity::set_sprite(vector<string> sprite, int sprite_color) 
{
    this->sprite = sprite;
    this->sprite_color = sprite_color;
}

void Entity::print_stats(int screen_row, int screen_col) {
    int row = screen_row;

    Console::set_color_fg256(33);
    Console::set_cursor(row++, screen_col);
    cout << "Damage:   " << stats.damage;

    Console::set_cursor(row++, screen_col);
    cout << "Defense:  " << stats.defense;

    Console::set_cursor(row++, screen_col);
    cout << "Accuracy: " << stats.accuracy;

    Console::set_cursor(row++, screen_col);
    cout << "Dexterity:" << stats.dexterity;

    Console::set_cursor(row++, screen_col);
    cout << "Critical: " << stats.critical;
}

void Entity::print_sprite(int screen_row, int screen_col) {
    int row = screen_row;

    Console::set_color_fg256(sprite_color);

    for_each(sprite.begin(), sprite.end(), [&](string line) { 
        Console::set_cursor(row++, screen_col);
        cout << line; 
    });    
}