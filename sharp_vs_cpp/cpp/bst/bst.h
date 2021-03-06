#pragma once

#include <iostream>
#include <string>

// auto property
#define PROPERTY(T, var) private: T m_##var; public: inline T var() {return m_##var;} public: inline void var(T x) {m_##var = x;}

using namespace std;

class Node{
    PROPERTY(int, chave)
    PROPERTY(string, valor)
    PROPERTY(Node*, esq)
    PROPERTY(Node*, dir)
    
    public:
        Node(const int chave, string valor, Node* esq=nullptr, Node* dir=nullptr) {
            m_chave = chave;
            m_valor = valor;
            m_esq = esq;
            m_dir = dir;
        }

        string Str() {
            return string("(") + to_string(m_chave) + ") => " + m_valor;
        }

        void Imprimir() {
            cout << Str() << '\n';
        }

    friend class BST;
};
/*
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
*/

class BST{
    public:
        BST() {
            m_raiz = nullptr;
        }

        ~BST() {
            DestroiRec(m_raiz);
            m_raiz = nullptr;
        }

        void Inserir(int chave, string valor){
            m_raiz = Inserir(m_raiz, chave, valor);
        }

        void Imprimir(){
            Imprimir(m_raiz, 0, 'r');
        }

        Node* BuscaRec(int chave){
            return BuscaRec(m_raiz, chave);
        }

        Node* BuscaIter(int chave){
            return BuscaIter(m_raiz, chave);
        }

    private:
        void DestroiRec(Node* n) {
            if (n != nullptr) {
                DestroiRec(n->esq());
                DestroiRec(n->dir());
                delete n;
            }
        }

        void Imprimir(Node* n, int nivel, char lado){
            if(n == nullptr)
                return;

            for(int i = 0; i < nivel; i++)
                cout << "--> ";

            cout << n->Str() << " [" << lado << "]\n";

            Imprimir(n->esq(), nivel+1, 'e');
            Imprimir(n->dir(), nivel+1, 'd');
        }

        Node* Inserir(Node* n, int chave, const string& valor){   
            if(n == nullptr)
                return new Node(chave, valor);
  
            if(chave < n->chave())
                n->m_esq = Inserir(n->esq(), chave, valor);
            else if(chave > n->chave())
                n->m_dir = Inserir(n->dir(), chave, valor);
            else n->m_valor = valor;
  
            return n;
        }

        Node* BuscaRec(Node* n, int chave) {
            if (n == nullptr || chave == n->chave())
                    return n;
            
            if (chave < n->chave())
                return BuscaRec(n->esq(), chave);
            else
                return BuscaRec(n->dir(), chave);
        }

        Node* BuscaIter(Node* n, int chave) {
            while (n != nullptr && chave != n->chave()) {
                if (chave < n->chave())
                    n = n->esq();
                else
                    n = n->dir();
            }
            return n;
        }

        Node* m_raiz;
};