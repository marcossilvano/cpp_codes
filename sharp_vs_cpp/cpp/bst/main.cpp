#include "bst.h"

int main(){
    Node n(40, "Quarenta");
    n.print();

    BST arv;

    arv.Inserir(10, "Dez");
    arv.Inserir(20, "Vinte");
    arv.Inserir(30, "Trinta");
    arv.Imprimir();

    arv.BuscaRec(30)->print();
    arv.BuscaIter(30)->print();
}