#include "map.h"
#include "console.h"

void Map::generate(int rows, int cols)
{
    map = vector<string>(cols, string(rows, 'X'));
}

void Map::set_map(vector<string> map)
{
    this->map = map;
}

void Map::print(int screen_row, int screen_col)
{
    int row = screen_row;
    Console::set_cursor(screen_row, screen_col);

    for_each(map.begin(), map.end(), [&](string line)
        { 
            Console::set_color(Color::FG_Green);
            Console::set_cursor(row, screen_col);
            for_each(line.begin(), line.end(), [](char ch) {
                switch (ch)
                {
                    case 'X': 
                        Console::set_color_fg256(rand()%3 + 19);
                        cout << "██"; 
                    break;
                    case 'C': cout << "🗳 "; break;
                    case 'S': cout << "⛺"; break;
                    case 'E': cout << "⛩ "; break;
                    default:  cout << "  "; break;
                }
            }); 
            row++; 
        });

    Console::reset_color();
    cout << endl;
}

int Map::get_cols()
{
    return map[0].size();
}

int Map::get_rows()
{
    return map.size();
}
