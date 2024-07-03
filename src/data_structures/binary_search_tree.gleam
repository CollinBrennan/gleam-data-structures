//// Binary search tree data structure.
//// The tree is left-leaning, meaning that duplicate values are stored in left child nodes.

import gleam/string_builder
import gleam/list
import gleam/order.{type Order, Lt, Eq, Gt}

type Tree(a) {
  Empty
  Node(key: a, left: Tree(a), right: Tree(a))
}

pub opaque type BST(a) {
  BST(root: Tree(a), compare: fn(a, a) -> Order)
}

/// Returns a new tree containing no nodes.
/// Takes an order function used to compare node values.
pub fn new(compare: fn(a, a) -> Order) -> BST(a) {
  BST(Empty, compare)
}

/// Returns a new tree with nodes inserted for each value in `list`.
/// Takes an order function to compare node values.
pub fn from_list(list: List(a), compare: fn(a, a) -> Order) -> BST(a) {
  let root = from_list_recurse(list, Empty, compare)
  BST(root, compare)
}

/// Inserts a node into the tree with its key set to `value` 
pub fn insert(bst: BST(a), value: a) -> BST(a) {
  let root = insert_recurse(bst.root, value, bst.compare)
  BST(root, bst.compare)
}

/// Deletes the first node in the tree whose key equals `value`
pub fn delete(bst: BST(a), value: a) -> BST(a) {
  let root = delete_recurse(bst.root, value, bst.compare)
  BST(root, bst.compare)
}

/// Deletes all nodes in the tree whose key equals `value`
pub fn delete_all(bst: BST(a), value: a) -> BST(a) {
  let bst_after_deletion = delete(bst, value)
  case bst.root == bst_after_deletion.root {
    True -> bst
    False -> delete_all(bst_after_deletion, value)
  }
}

/// Returns `True` if a node in the tree has a key equal to `value` and `False` otherwise.
pub fn contains(bst: BST(a), value: a) -> Bool {
  contains_recurse(bst.root, value, bst.compare)
}

/// Returns 'True' if no nodes are in the tree and `False` otherwise.
pub fn is_empty(bst: BST(a)) -> Bool {
  case bst.root {
    Empty -> True
    _ -> False
  }
}

/// Returns the number of nodes in the tree.
pub fn size(bst: BST(a)) -> Int {
  length_recurse(0, bst.root)
}

/// Returns a list of all the keys in the tree including duplicates.
/// Order of the list is the [`preorder traversal`](https://www.geeksforgeeks.org/preorder-traversal-of-binary-tree/) of the tree.
pub fn to_list(bst: BST(a)) -> List(a) {
  to_list_recurse([], bst.root)
}

/// Returns a string representation of the tree as a graph.
pub fn to_graph(bst: BST(a), to_string: fn(a) -> String) -> String {
  case bst.root {
    Empty -> "Empty tree"
    Node(key, left, right) -> {
      let pointer_right = "└ʀ─"
      let pointer_left = case right {
        Empty -> "└ʟ─"
        _ -> "├ʟ─"
      }

      string_builder.new()
      |> string_builder.append(to_string(key))
      |> to_graph_recurse("", pointer_left, left, case right {
        Empty -> False
        _ -> True
      }, to_string)
      |> to_graph_recurse("", pointer_right, right, False, to_string)
      |> string_builder.append("\n")
      |> string_builder.to_string()
    }
  }
}

fn to_graph_recurse(
  sb: string_builder.StringBuilder, 
  padding: String, 
  pointer: String, 
  tree: Tree(a), 
  has_right_sibling: Bool,
  to_string: fn(a) -> String
  ) -> string_builder.StringBuilder {
    case tree {
      Empty -> sb
      Node(key, left, right) -> {
        let pointer_right = "└ʀ─"
        let pointer_left = case right {
          Empty -> "└ʟ─"
          _ -> "├ʟ─"
        }

        let padding_new = string_builder.new()
        |> string_builder.append(padding)
        |> string_builder.append(case has_right_sibling {
          True -> "│  "
          False -> "   "
        })
        |> string_builder.to_string()

        string_builder.append(sb, "\n")
        |> string_builder.append(padding)
        |> string_builder.append(pointer)
        |> string_builder.append(to_string(key))
        |> to_graph_recurse(padding_new, pointer_left, left, case right {
          Empty -> False
          _ -> True
        }, to_string)
        |> to_graph_recurse(padding_new, pointer_right, right, False, to_string)
      }
    }
}

fn from_list_recurse(list: List(a), tree: Tree(a), compare: fn(a, a) -> Order) -> Tree(a) {
  case list {
    [] -> tree
    [value, ..rest] -> from_list_recurse(rest, insert_recurse(tree, value, compare), compare)
  }
} 

fn contains_recurse(tree: Tree(a), value: a, compare: fn(a, a) -> Order) -> Bool {
  case tree {
    Empty -> False
    Node(key, left, right) -> case compare(value, key) {
      Eq -> True
      Lt -> contains_recurse(left, value, compare)
      Gt -> contains_recurse(right, value, compare)
    }
  }
}

fn length_recurse(length: Int, tree: Tree(a)) -> Int {
  case tree {
    Empty -> length
    Node(_, left, right) -> {
      length + 1
      |> length_recurse(left)
      |> length_recurse(right)
    }
  }
}

fn to_list_recurse(keys: List(a), tree: Tree(a)) -> List(a) {
  case tree {
    Empty -> keys
    Node(key, left, right) -> {
      list.append(keys, [key])
      |> to_list_recurse(left)
      |> to_list_recurse(right)
    }
  }
}

fn insert_recurse(tree: Tree(a), value: a, compare: fn(a, a) -> Order) -> Tree(a) {
  case tree {
    Empty -> Node(value, Empty, Empty)
    Node(key, left, right) -> case compare(value, key) {
      Lt | Eq -> Node(key, insert_recurse(left, value, compare), right)
      Gt -> Node(key, left, insert_recurse(right, value, compare))
    }
  }
}

fn delete_recurse(tree: Tree(a), value: a, compare: fn(a, a) -> Order) -> Tree(a) {
  case tree {
    Node(key, left, right) -> case compare(value, key) {
      Eq -> case get_leftmost_child(right) {
        Empty -> left
        Node(successor_key, _, _) -> Node(successor_key, left, delete_recurse(right, successor_key, compare))
      }
      Lt -> Node(key, delete_recurse(left, value, compare), right)
      Gt -> Node(key, left, delete_recurse(right, value, compare))
    }
    _ -> tree
  }
}

fn get_leftmost_child(tree: Tree(a)) -> Tree(a) {
  case tree {
    Empty -> Empty
    Node(_, Empty, _) -> tree
    Node(_, left, _) -> get_leftmost_child(left)
  }
}