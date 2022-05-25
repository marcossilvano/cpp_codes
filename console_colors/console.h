#pragma once

#include <iostream>
#include <string>
#include "color.h"

using namespace std;

class Console
{
public:
    static void init(int start_row, int start_col);

    static void hide_cursor();
    static void show_cursor();

    static void set_cursor(int row, int col);
    static void get_cursor(int& row, int& col);
    
    static void set_color(Color color);
    static void set_color_fg256(int color);
    static void set_color_bg256(int color);
    static void set_color_rgb(int r, int g, int b);
    static void reset_color();
    
    static void clear_screen();

private:
    static int row;
    static int col;
};

/*
    class Cursor {
    private:
        int row;
        int col;
    public:
        void set(int row, int col);
        void set(Cursor cursor);

        Cursor get();
        void get(int& row, int& col);
    };

    Cursor cursor;

*/