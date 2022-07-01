using System;

public class Program {
    public static void Main() {
        Node n = new Node(40, "Quarenta");
        n.Print();

        BST bst = new BST();

        bst.Insert(10, "Dez");
        bst.Insert(20, "Vinte");
        bst.Insert(30, "Trinta");
        bst.Print();

        bst.SearchRec(30).Print();
        bst.SearchIter(30).Print();
    }
}