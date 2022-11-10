#include <iostream>
#include "console.h"

using namespace std;

void Console::init(int start_row, int start_col)
{
    clear_screen();
    set_cursor(start_row, start_col);
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
    cout << "\033[" << row << ';' << col << 'H';
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

void Console::reset_color()
{
    set_color(Color::Reset);
}

void Console::clear_screen()
{
    cout << "\033[2J";
}

/*
void Console::set_color_rgb(int r, int g, int b) 
{
    cout << "\033[38;2;" << r << ';' << g << ';' << b << "m";
}
*/