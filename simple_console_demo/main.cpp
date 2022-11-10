#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <ctime>

#include "console.h"

using namespace std;

void delay(int time) {
    time *= 1000;
    clock_t start = clock();
    while (clock() < start + time);
}

int main()
{
    // start console
    Console::init(1,1);

    int rows = 20;
    int cols = 40;

    for (int k = 0; k < 1000000; k++) {
        Console::set_color_fg256(rand() % 256);
        Console::set_cursor(rand()%rows, rand()%cols);
        printf("█");
    }

    Console::set_cursor(rows+5, 1);
    printf("\n\n");

    return 0;
}