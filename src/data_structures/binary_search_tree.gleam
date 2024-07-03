//// Binary search tree data structure.
//// The tree is left-leaning, meaning that duplicate values are stored in left child nodes.

import gleam/int
import gleam/string_builder
import gleam/list

pub opaque type Tree {
  Empty
  Node(key: Int, left: Tree, right: Tree)
}

/// Returns a new tree containing no nodes
pub fn new() -> Tree {
  Empty
}

/// Returns a new tree with nodes inserted for each value in `list`.
/// The order of insertion is the same order as the list.
pub fn from_list(list: List(Int)) -> Tree {
  build_tree(new(), list)
}

/// Inserts a node into the tree with its key set to `value` 
pub fn insert(tree: Tree, value: Int) -> Tree {
  case tree {
    Empty -> Node(value, Empty, Empty)
    Node(key, left, right) if value <= key -> Node(key, insert(left, value), right)
    Node(key, left, right) -> Node(key, left, insert(right, value))
  }
}

/// Deletes the first node in the tree whose key equals `value`
pub fn delete(tree: Tree, value: Int) -> Tree {
  case tree {
    Node(key, left, Empty) if value == key -> left
    Node(key, Empty, right) if value == key -> right
    Node(key, left, right) if value == key -> case get_leftmost_child(right) {
      Node(successor_key, _, _) -> Node(successor_key, left, delete(right, successor_key))
      Empty -> Empty
    }
    Node(key, left, right) if value < key -> Node(key, delete(left, value), right)
    Node(key, left, right) if value > key -> Node(key, left, delete(right, value))
    _ -> tree
  }
}

/// Deletes all nodes in the tree whose key equals `value`
pub fn delete_all(tree: Tree, value: Int) -> Tree {
  let tree_after_deletion = delete(tree, value)
  case tree == tree_after_deletion {
    True -> tree
    False -> delete_all(tree_after_deletion, value)
  }
}

/// Returns `True` if a node in the tree has a key equal to `value` and `False` otherwise.
pub fn contains(tree: Tree, value: Int) -> Bool {
  case tree {
    Empty -> False
    Node(key, _, _) if value == key -> True
    Node(key, left, _) if value < key -> contains(left, value)
    Node(_, _, right) -> contains(right, value)
  }
}

/// Returns 'True' if no nodes are in the tree and `False` otherwise.
pub fn is_empty(tree: Tree) -> Bool {
  case tree {
    Empty -> True
    _ -> False
  }
}

/// Returns the number of nodes in the tree.
pub fn length(tree: Tree) -> Int {
  length_recurse(0, tree)
}

/// Returns a list of all the keys in the tree including duplicates.
/// Order of the list is the [`preorder traversal`](https://www.geeksforgeeks.org/preorder-traversal-of-binary-tree/) of the tree.
pub fn to_list(tree: Tree) -> List(Int) {
  to_list_recurse([], tree)
}

/// Returns a string representation of the tree as a graph.
pub fn to_graph(tree: Tree) -> String {
  case tree {
    Empty -> "Empty tree"
    Node(key, left, right) -> {
      let pointer_right = "└ʀ─"
      let pointer_left = case right {
        Empty -> "└ʟ─"
        _ -> "├ʟ─"
      }

      string_builder.new()
      |> string_builder.append(int.to_string(key))
      |> build_graph("", pointer_left, left, case right {
        Empty -> False
        _ -> True
      })
      |> build_graph("", pointer_right, right, False)
      |> string_builder.append("\n")
      |> string_builder.to_string()
    }
  }
}

/// Recursively adds nodes to the string representation of a tree
fn build_graph(
  sb: string_builder.StringBuilder, 
  padding: String, 
  pointer: String, 
  tree: Tree, 
  has_right_sibling: Bool
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
        |> string_builder.append(int.to_string(key))
        |> build_graph(padding_new, pointer_left, left, case right {
          Empty -> False
          _ -> True
        })
        |> build_graph(padding_new, pointer_right, right, False)
      }
    }
}

fn length_recurse(length: Int, tree: Tree) -> Int {
  case tree {
    Empty -> length
    Node(_, left, right) -> {
      length + 1
      |> length_recurse(left)
      |> length_recurse(right)
    }
  }
}

fn to_list_recurse(keys: List(Int), tree: Tree) -> List(Int) {
  case tree {
    Empty -> keys
    Node(key, left, right) -> {
      list.append(keys, [key])
      |> to_list_recurse(left)
      |> to_list_recurse(right)
    }
  }
}

fn build_tree(tree: Tree, list: List(Int)) -> Tree {
  case list {
    [] -> tree
    [first, ..rest] -> build_tree(insert(tree, first), rest)
  }
}

fn get_leftmost_child(tree: Tree) -> Tree {
  case tree {
    Empty -> Empty
    Node(_, Empty, _) -> tree
    Node(_, left, _) -> get_leftmost_child(left)
  }
}