#include <iostream>
#include <stdlib.h>
#include <vector>
#include <string>

using namespace std;

void Swap(int &a, int &b)
{
    int temp = a;
    a = b;
    b = temp;
}

int *GetArray(int n)
{
    int *vec = new int[n];
    for (int i = 0; i < n; i++)
    {
        vec[i] = rand() % n + 1;
    }
    return vec;
}

vector<int> GetVector(int n) 
{
    vector<int> vec(n);
    for (int i = 0; i < n; i++)
    {
        vec.push_back(rand() % n + 1);
    }
    return vec;
}

void PrintArray(int n, int* vec)
{
    cout << "  ";

    for (int i = 0; i < n; i++)
    {
        cout << vec[i] << ' ';
    }
    cout << '\n';
}

void PrintVector(vector<int>& vec)
{
    cout << "  ";

    for (auto elem : vec)
    {
        cout << elem << ' ';
    }
    cout << '\n';
}

int main()
{
    cout << "\nPASSAGEM DE PARÂMETRO POR REFERÊNCIA\n";
    // passagem por referência
    int x = 5;
    int y = 10;
    Swap(x, y);
    cout << "  x: " << x << " y: " << y << '\n';

    cout << "\nALOCANDO E MANIPULANDO ARRAYS EM FUNÇÕES\n";
    // alocando e retornando vetor de função
    int *v = GetArray(10);
    vector<int> v2 = GetVector(10);

    // passando referência de array para função
    // array é "reference type"
    PrintArray(10, v);
    delete[] v;
    
    PrintVector(v2);

    cout << "\nESTRINGUES!\n";

    string s1 = "Hello";
    string s2 = s1 + " " + "World!";
    cout << ' ' << s2 << '\n';

    return 0;
}