#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include "console.h"
#include "map.h"
#include "enemy.h"

class Game {
public:
    int level;
    Map map;
    int rows;
    int cols;
    int run;
};


int main()
{
    // start console
    Console::init(1,1);

    Console::set_color(Color::FG_Green);
    cout << "Hello Console" << endl;
    Console::reset_color();

    Map map;
    //map.generate(20,20);
    map.set_map(
        {
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "XC    X   XC               CX     XC    X",
            "XXX X X X XXXXXXXXX XXX XXXXX X X XXX X X",
            "X   X X X         X XC  X     X X     X X",
            "X XXX X XXXXXXXXX X XXXXX XXXXX XXXXXXX X",
            "X   X   XC    X   X X     XCX   XC   CX X",
            "XXX XXXXXXX X X XXX X XXXXX X XXXXX XXX X",
            "XCX       X X X XC  X X     X X     X   X",
            "X XXXXXXX X X X XXX X X X X X X X XXX XXX",
            "X X       XCX X   X X XCX XCX X X     XCX",
            "X X XXXXXXXXX XXX X X XXX XXX X XXXXXXX X",
            "X XSX       X   X X X   X X   X   XC    X",
            "X XXX XXXXX XXX X X XXX X X XXXXX XXXXX X",
            "X     X   X   X X X       X X  CX       X",
            "XXXXX X X XXX X X XXXXXXX X X XXXXXXXXX X",
            "X     XCX     X X       XCX X X   X     X",
            "X XXXXXXXXX XXX XXXXXXX XXX X X X X XXXXX",
            "X X   X   X   X       X X   X   X   X   X",
            "X X X X X XXX XXXXX X X X XXX XXXXXXX X X",
            "X X X X X   X       X X X X   X  EX   X X",
            "X X X X XXX XXXXXXXXX X X X XXX XXX XXX X",
            "X X X   X   X   XC    X X X   X     X   X",
            "X X XXXXX XXX X XXXXXXX X XXX XXXXXXX X X",
            "X      CX     X           XC          XCX",
            "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"      
        }
    );

    Game game;
    game.map = map;
    Enemy e = Enemy("Robot", 70, 100, "A Robot", "I Am Robot", {40, 10, 30, 5, 60});

    // printá
    map.print(3,3);
    e.print(3, 100);

    Console::set_cursor(210, 1);

    return 0;
}