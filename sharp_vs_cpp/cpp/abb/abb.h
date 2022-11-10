#pragma once

#include <iostream>

template <typename K, typename V>
class ABB;

template <typename K, typename V>
class ABB_Node{

public:
    
    ABB_Node(const K& chave, const V& valor, ABB_Node* esq, ABB_Node* dir)
        : m_chave{chave}, m_valor{valor}, m_esq{esq}, m_dir{dir} {}

    const K& chave() const { return m_chave; }
    const V& valor() const { return m_valor; }
    ABB_Node* esq() { return m_esq; }
    ABB_Node* dir() { return m_dir; }

    friend class ABB<K,V>;

private:
    K m_chave;
    V m_valor;
    ABB_Node* m_esq;
    ABB_Node* m_dir;
    
};

template <typename K, typename V>
class ABB{

public:

    ABB() 
    : raiz{nullptr} {}

    ABB(ABB& arv) = delete;
    ABB(ABB&& argv) = delete;

    void Inserir(const K& chave, const V& valor){
        raiz = Inserir(raiz, chave, valor);
    }

    void Imprimir(){
        Imprimir(raiz, 0, 'r');
    }
    
private:

    void Imprimir(ABB_Node<K,V>* n, int nivel, char lado){
        using namespace std;
        if(n == nullptr)
            return;
        for(int i = 0; i < nivel; i++)
            cout << "--> ";
        cout << "(" << n->chave() << ") => " << n->valor() << " [" << lado << "]\n";
        Imprimir(n->esq(), nivel+1, 'e');
        Imprimir(n->dir(), nivel+1, 'd');
    }

    ABB_Node<K,V>* Inserir(ABB_Node<K,V>* n, const K& chave, const V& valor){   
        if(n == nullptr)
            return new ABB_Node<K, V>(chave, valor, nullptr, nullptr);
        if(chave < n->chave())
            n->m_esq = Inserir(n->esq(), chave, valor);
        else if(chave > n->chave())
            n->m_dir = Inserir(n->dir(), chave, valor);
        else n->m_valor = valor;
        return n;
    }

    ABB_Node<K,V>* raiz;
};