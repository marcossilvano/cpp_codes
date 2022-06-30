#include "bst.h"

int main(){
    Node n(10, "Dez", nullptr, nullptr);

    BST arv{};

    arv.Inserir(10, "Dez");
    arv.Inserir(20, "Vinte");
    arv.Inserir(30, "Trinta");
    arv.Imprimir();
}