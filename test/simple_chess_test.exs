defmodule SimpleChessTest do
  use ExUnit.Case
  doctest SimpleChess.CLI

  # test "greets the world" do
  #   assert SimpleChess.hello() == :world
  # end
  @tag timeout: :infinity
  test "init board" do
    SimpleChess.CLI.main()
  end
end
