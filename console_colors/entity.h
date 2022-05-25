#pragma once

#include <iostream>
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

public:
    Entity(string name, int hp, int max_hp, Stats stats);
    virtual void print(int screen_row, int screen_col) = 0; // abstract
};