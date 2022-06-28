using System;
using System.Collections.Generic;

struct Person
{
    public int id;
    public string name;
}

class Program
{
    static void Swap(ref int a, ref int b) 
    {
        int temp = a;
        a = b;
        b = temp;
    }
    
    static int[] GetArray(int n) 
    {
        int[] vec = new int[n];
        Random rand = new Random();
        for (int i = 0; i < n; i++)
        {
            vec[i] = rand.Next(n) + 1;
        }
        return vec;
    }

    static List<int> GetList(int n) 
    {
        List<int> vec = new List<int>();
        Random rand = new Random();
        for (int i = 0; i < n; i++)
        {
            vec.Add(rand.Next(n) + 1);
        }
        return vec;
    }
    
    static void PrintArray(int[] vec)
    {
        Console.Write("  ");
        foreach (var elem in vec) 
        {
            Console.Write("{0} ", elem);
        }
        Console.WriteLine();
    }

    static void PrintArray2(int[] vec)
    {
        Console.Write("  ");
        for (int i = 0; i < vec.Length; i++)
        {
            Console.Write("{0} ", vec[i]);
        }
        Console.WriteLine();
    }
    
    static void PrintPerson(ref Person p)
    {
        Console.WriteLine("  id: {0} name: {1}", p.id, p.name);
    }

    static void Main()
    {
        Console.WriteLine("\nPASSAGEM DE PARÂMETRO POR REFERÊNCIA");
        // passagem por referência
        int x = 5;
        int y = 10;
        Swap(ref x, ref y);
        Console.WriteLine ("  x:{0} y:{1}", x, y);
        
        Console.WriteLine("\nALOCANDO E MANIPULANDO ARRAYS EM FUNÇÕES");
        // alocando e retornando vetor de função
        int[] v = GetArray(10);
        
        // passando referência de array para função
        // array é "reference type"
        PrintArray(v);

        Console.WriteLine("\nTRABALHANDO COM STRUCTS");
        // struct é "value type" 
        Person p;
        p.id = 5;
        p.name = "John Doe";
        PrintPerson(ref p);

        Console.WriteLine("\nTESTE COM TAD SIMPLES: LINKED_LIST");
        // lista encadeada
        LinkedList list = new LinkedList();
        list.Print();

        for (int i = 5; i > 0; i--) 
        {
            list.PushFront(new Node(i));
        }
        list.Print();

        Console.WriteLine();
    }
}