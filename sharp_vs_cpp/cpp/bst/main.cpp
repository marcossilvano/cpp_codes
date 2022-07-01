#include "bst.h"

int main(){
    Node n(10, "Dez");

    BST arv;

    arv.Inserir(10, "Dez");
    arv.Inserir(20, "Vinte");
    arv.Inserir(30, "Trinta");
    arv.Imprimir();

    cout << arv.BuscaPreI(30)->valor() << '\n';
    cout << arv.BuscaPreR(30)->valor() << '\n';
}