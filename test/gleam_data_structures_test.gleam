import gleam/io
import gleeunit
import gleeunit/should
import data_structures/binary_search_tree as bst
import gleam/int
import gleam/float

pub fn main() {
  gleeunit.main()
}

pub fn preorder_traversal_test() {
  [5, 3, 1, 2, 8, 6, 1]
  |> bst.from_list(int.compare)
  |> bst.to_list()
  |> should.equal([5, 3, 1, 1, 2, 8, 6])
}

pub fn length_test() {
  []
  |> bst.from_list(int.compare)
  |> bst.size()
  |> should.equal(0)

  [5, 3, 1, 2, 8, 6, 1]
  |> bst.from_list(int.compare)
  |> bst.size()
  |> should.equal(7)
}

pub fn empty_test() {
  []
  |> bst.from_list(int.compare)
  |> bst.is_empty()
  |> should.be_true()

  bst.new(int.compare)
  |> bst.is_empty()
  |> should.be_true()

  [1, 2, 3]
  |> bst.from_list(int.compare)
  |> bst.is_empty()
  |> should.be_false()
}

pub fn contains_test() {
  [10.0, 5.8, 7.12, 0.1, 1.9, 58.3123, 30.123]
  |> bst.from_list(float.compare)
  |> bst.contains(4.1)
  |> should.be_false()

  [10.0, 5.8, 7.12, 0.1, 1.9, 58.3123, 30.123]
  |> bst.from_list(float.compare)
  |> bst.contains(0.1)
  |> should.be_true()
}

pub fn float_test() {
  [10.0, 5.8, 7.12, 0.1, 1.9, 58.3123, 30.123]
  |> bst.from_list(float.compare)
  |> bst.to_graph(float.to_string)
  |> io.println_error()
}