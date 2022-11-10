using System;

class Node {
    public int Key { get; set; }
    public Node Next { get; set; }

    public Node(int key, Node next = null) {
        Key = key;
        Next = next;
    }
}

class LinkedList {
    public Node First { get; set; }
    
    public LinkedList() {
        First = null;
    }
    
    public void PushFront(Node node)
    {
        node.Next = First;
        First = node;
    }
    
    public void Print()
    {
        Console.Write("  ");
        Node node = First;
        while (node != null)
        {
            Console.Write("[{0}] -> ", node.Key);    
            node = node.Next;
        }
        Console.WriteLine("NULL");
    }
}