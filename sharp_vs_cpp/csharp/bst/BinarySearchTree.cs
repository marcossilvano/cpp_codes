using System;

public class Node {
    public int Key { get; set; }
    public String Value { get; set; }
    public Node Left { get; set; }
    public Node Right { get; set; }

    public Node(int key, string value, Node left = null, Node right = null) {
        Key = key;
        Value = value;
        Left = left;
        Right = right;
    }

    public override String ToString() {
        return "(" + Key.ToString() + ") => " + Value;
    }

    public void Print() {
        Console.Write("{0}\n", ToString());
    }
}

public class BST{
    private Node root;

    public BST() {
        root = null;
    }

    public void Insert(int key, string value){
        root = Insert(root, key, value);
    }

    public void Print(){
        Print(root, 0, 'r');
    }

    public Node SearchRec(int key){
        return SearchRec(root, key);
    }

    public Node SearchIter(int key){
        return SearchIter(root, key);
    }

    private void Print(Node n, int level, char tag){
        if(n == null)
            return;

        for(int i = 0; i < level; i++)
            Console.Write("--> ");

        Console.Write("{0} [{1}]\n", n.ToString(), tag);

        Print(n.Left, level+1, 'e');
        Print(n.Right, level+1, 'd');
    }

    private Node Insert(Node n, int key, string value){   
        if(n == null)
            return new Node(key, value);

        if(key < n.Key)
            n.Left = Insert(n.Left, key, value);
        else if(key > n.Key)
            n.Right = Insert(n.Right, key, value);
        else n.Value = value;

        return n;
    }

    private Node SearchRec(Node n, int key) {
        if (n == null || key == n.Key)
                return n;
        
        if (key < n.Key)
            return SearchRec(n.Left, key);
        else
            return SearchRec(n.Right, key);
    }

    private Node SearchIter(Node n, int key) {
        while (n != null && key != n.Key) {
            if (key < n.Key)
                n = n.Left;
            else
                n = n.Right;
        }
        return n;
    }
};