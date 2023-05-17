#include <iostream>
#include <vector>

using namespace std;

struct Vector2 {
    float x;
    float y;
};

void structured_binding() {
    pair<int, string> data1 = pair{1, "orange"};

    int x;
    string s;
    auto [x,s] = data1;

    int v[3] = {x, x+2, x+3};
    int a,b,c;
    auto [a,b,c] = v;

    vector<int> v1 = {1,2,3};

    Vector2 p1 = Vector2{5,7};
    float x1,y1;
    auto [x1,y1] = p1;

}

int main() {
    
    return 0;
}