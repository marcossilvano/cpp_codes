#pragma once

#include "entity.h"

class Enemy : public Entity
{
private:
    string description;
    string grunt;

public:
    Enemy(string name, int hp, int max_hp, string description, string grunt, Stats stats);
    void print(int screen_row, int screen_col) override;
};