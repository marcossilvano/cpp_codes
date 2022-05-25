#include <iostream>
#include "console.h"

using namespace std;

int Console::row = 1;
int Console::col = 1;

void Console::init(int start_row, int start_col)
{
    row = start_row;
    col = start_col;
    clear_screen();
    set_cursor(row, col);
}

void Console::hide_cursor()
{
    cout << "\033[?25l";
}

void Console::show_cursor()
{
    cout << "\033[?25h";
}

void Console::set_cursor(int row, int col)
{
    Console::row = row;
    Console::col = col;
    cout << "\033[" << row << ';' << col << 'H';
}

void Console::get_cursor(int& row, int& col) 
{
    row = Console::row;
    col = Console::col;
}

void Console::set_color(Color color)
{
    cout << "\033[" << (int)color << 'm';
}

void Console::set_color_fg256(int color) 
{
    cout << "\033[38:5:" << color << "m";
}

void Console::set_color_bg256(int color) 
{
    cout << "\033[48:5:" << color << "m";
}

void Console::set_color_rgb(int r, int g, int b) 
{
    cout << "\033[38;2;" << r << ';' << g << ';' << b << "m";
}

void Console::reset_color()
{
    set_color(Color::Reset);
}

void Console::clear_screen()
{
    cout << "\033[2J";
}
