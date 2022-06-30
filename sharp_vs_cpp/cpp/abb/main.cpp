#include "abb.h"

int main(int argc, char** argv){

    ABB_Node<int, int> n(10, 10, nullptr, nullptr);

    ABB<int,int> arv{};

    arv.Inserir(10, 10);
    arv.Inserir(20, 20);
    arv.Inserir(30, 30);
    arv.Imprimir();

    ABB<std::string,int> a2;
    a2.Inserir("cebolinha", 1);
    a2.Inserir("abobrinha", 3);
    a2.Inserir("couve", 4);
    a2.Inserir("cenoura", 4);
    a2.Inserir("vagem", 4);
    a2.Imprimir();
}