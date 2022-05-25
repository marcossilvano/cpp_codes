#pragma once

#include <iostream>
#include <vector>
#include <string>

using namespace std;

class Stats
{
public:
    int damage;
    int defense;
    int accuracy;
    int dexterity;
    int critical;
};

class Entity
{
protected:
    string name;
    int hp;
    int max_hp;
    Stats stats;

    vector<string> sprite;
    int sprite_color;

public:
    Entity(string name, int hp, int max_hp, Stats stats);

    void set_sprite(vector<string> sprite, int sprite_color);
    void print_sprite(int screen_row, int screen_col);
    void print_stats(int screen_row, int screen_col);

    virtual void print(int screen_row, int screen_col) = 0; // abstract
};