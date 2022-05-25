#include "entity.h"

Entity::Entity(string name, int hp, int max_hp, Stats stats) 
{
    this->name = name;
    this->hp = hp;
    this->max_hp = max_hp;
    this->stats = stats;
}
