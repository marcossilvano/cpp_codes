#pragma once

#include <iostream>
#include <string>

using namespace std;

class Node{
    public:
        Node(const int chave, string valor, Node* esq=nullptr, Node* dir=nullptr)
            : m_chave{chave}, m_valor{valor}, m_esq{esq}, m_dir{dir} {}

        int chave() { return m_chave; }
        void chave(int chv) { m_chave = chv; }

        string valor() { return m_valor; }
        void valor(string val) { m_valor = val; };
        
        Node* esq() { return m_esq; }
        
        Node* dir() { return m_dir; }

    private:
        int m_chave;
        string m_valor;
        Node* m_esq;
        Node* m_dir;

    friend class BST;
};

class BST{
    public:
        BST()
            : raiz{nullptr} {}

        void Inserir(int chave, string valor){
            raiz = Inserir(raiz, chave, valor);
        }

        void Imprimir(){
            Imprimir(raiz, 0, 'r');
        }
        
    private:
        void Imprimir(Node* n, int nivel, char lado){
            if(n == nullptr)
                return;

            for(int i = 0; i < nivel; i++)
                cout << "--> ";

            cout << "(" << n->chave() << ") => " << n->valor() << " [" << lado << "]\n";

            Imprimir(n->esq(), nivel+1, 'e');
            Imprimir(n->dir(), nivel+1, 'd');
        }

        Node* Inserir(Node* n, int chave, string valor){   
            if(n == nullptr)
                return new Node(chave, valor, nullptr, nullptr);
  
            if(chave < n->chave())
                n->m_esq = Inserir(n->esq(), chave, valor);
            else if(chave > n->chave())
                n->m_dir = Inserir(n->dir(), chave, valor);
            else n->m_valor = valor;
  
            return n;
        }

        Node* raiz;
};