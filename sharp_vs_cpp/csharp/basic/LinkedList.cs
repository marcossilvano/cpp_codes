using System;

class LinkedList {
    public Node first;
    
    public LinkedList() 
    {
        first = null;
    }
    
    public void PushFront(Node node)
    {
        node.next = first;
        first = node;
    }
    
    public void Print()
    {
        Console.Write("  ");
        Node node = first;
        while (node != null)
        {
            Console.Write("[{0}] -> ", node.key);    
            node = node.next;
        }
        Console.WriteLine("NULL");
    }
}

class Node {
    public int key;
    public Node next;

    public Node(int key) : 
        this(key, null) {
    }

    public Node(int key, Node next)
    {
        this.key = key;
        this.next = next;
    }
}
