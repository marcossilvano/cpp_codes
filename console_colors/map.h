#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include "console.h"

class Map {
private:
    vector<string> map;
    int rows;
    int cols;

public:
    int get_cols();
    int get_rows();
    void generate(int rows, int cols);
    void set_map(vector<string> map);
    void print(int screen_row, int screen_col);
};
