import gleeunit
import gleeunit/should
import data_structures/binary_search_tree as bst

pub fn main() {
  gleeunit.main()
}

pub fn preorder_traversal_test() {
  [5, 3, 1, 2, 8, 6, 1]
  |> bst.from_list()
  |> bst.to_list()
  |> should.equal([5, 3, 1, 1, 2, 8, 6])
}

pub fn length_test() {
  []
  |> bst.from_list()
  |> bst.length()
  |> should.equal(0)

  [5, 3, 1, 2, 8, 6, 1]
  |> bst.from_list()
  |> bst.length()
  |> should.equal(7)
}

pub fn empty_test() {
  []
  |> bst.from_list()
  |> bst.is_empty()
  |> should.be_true()

  bst.new()
  |> bst.is_empty()
  |> should.be_true()

  [1, 2, 3]
  |> bst.from_list()
  |> bst.is_empty()
  |> should.be_false()
}