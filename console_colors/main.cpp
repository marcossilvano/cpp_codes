#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

#include "console.h"
#include "map.h"
#include "enemy.h"
#include "player.h"

int main()
{
    // start console
    Console::init(1,1);

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

    Enemy enemy = Enemy("BORG", 70, 100, "Insect from outer space", "Come with me if you wanna die!", {40, 10, 30, 5, 60});
    enemy.set_sprite(
        {
            " o            o ",
            "  \\          /  ",
            "   \\        /   ",
            "     :-'""'-:    ",
            " .-'  ____  `-. ",
            "( (  (_()_)  ) )",
            " `-.   ^^   .-' ",
            "    `._==_.'    ",
            "     __)(___    "
        }, 93
    );
    Player player = Player("JACK",2,2,30,30,50, {8, 5, 7, 5, 4});
    player.set_sprite(
        {
            "       __",
            "   _  |@@|",
            "  / \\ \\--/ __",
            "  ) O|----|  |   __",
            " / / \\ }{ /\\ )_ / _\\",
            " )/  /\\__/\\ \\__O (__",
            "|/  (--/\\--)    \\__/",
            "/   _)(  )(_",
            "   `---''---`"
           }, 34
    );

    // draw everything
    map.print(3,3);
    player.print(3, 90);
    enemy.print(3, 115);

    Console::set_cursor(210, 1);
    cout << endl;

    return 0;
}