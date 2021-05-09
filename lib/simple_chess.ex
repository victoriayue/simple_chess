defmodule SimpleChess.CLI do
  @moduledoc """
  Documentation for `SimpleChess`.
  """
  defmodule Color do
    def blue(text) do
      IO.ANSI.blue() <> text <> IO.ANSI.reset()
    end
    def yellow(text) do
      IO.ANSI.yellow() <> text <> IO.ANSI.reset()
    end
  end

  # if the location is occupied by another token, eat it
  def occupied(map, location, current, color, token) do
    player = Map.fetch!(map, color)
    # update token from map player
    {_, player} = Map.get_and_update(player, token, fn x ->
      {x, location}
    end)
    # update player from map
    {_, map} = Map.get_and_update(map, color, fn x ->
      {x, player}
    end)

    # update board
    # update old token
    [old_x, old_y] = current
    old_index = (old_x-1)*4+old_y-1
    [new_x, new_y] = location
    new_index = (new_x-1)*4+new_y-1

    board = Map.fetch!(map, :board)
    old = Enum.at(board, old_index)
    board = List.replace_at(board, old_index, "  ") |> List.replace_at(new_index, old)

    {_, map} = Map.get_and_update(map, :board, fn x ->
      {x, board}
    end)

    # update all array
    all = Map.fetch!(map, :all)
    all = all -- [current]
    {_, map} = Map.get_and_update(map, :all, fn x ->
      {x, all}
    end)

    # update another player

    oppo_color = if color == :blue do :yellow else :blue end
    oppo = Map.fetch!(map, oppo_color)

    # find which token are eaten
    oppo_token =
      cond do
        Map.fetch!(oppo, :zi) == location -> :zi
        Map.fetch!(oppo, :xiang) == location -> :xiang
        Map.fetch!(oppo, :jiang) == location -> :jiang
        Map.fetch!(oppo, :wang) == location -> :wang
        true ->
          IO.puts "Invalid token"
          System.halt(0) # exit
      end
    # update oppo player
    oppo = Map.fetch!(map, oppo_color)
    {_, oppo_player} = Map.get_and_update(oppo, oppo_token, fn x ->
      {x, [0, 0]} # means it's eaten
    end)
    # update player from map
    {_, map} = Map.get_and_update(map, oppo_color, fn x ->
      {x, oppo_player}
    end)

    {true, map}
  end

  def not_occupied(map, location, current, color, token) do
    player = Map.fetch!(map, color)

    # update token from map player
    {_, player} = Map.get_and_update(player, token, fn x ->
      {x, location}
    end)

    # update board
    # remove old token
    [old_x, old_y] = current
    old_index = (old_x-1)*4+old_y-1
    [new_x, new_y] = location
    new_index = (new_x-1)*4+new_y-1

    board = Map.fetch!(map, :board)
    old = Enum.at(board, old_index)
    board = List.replace_at(board, old_index, "  ") |> List.replace_at(new_index, old)

    {_, map} = Map.get_and_update(map, :board, fn x ->
      {x, board}
    end)


    # update player from map
    {_, map} = Map.get_and_update(map, color, fn x ->
      {x, player}
    end)
    all = Map.fetch!(map, :all)
    # update all token array
    all = all -- [current]
    all = all ++ [location]
    {_, map} = Map.get_and_update(map, :all, fn x ->
      {x, all}
    end)

    {true, map}
  end

  # 子 chess can only go right [x, y+1] or left [x, y-1] depends on which color player pick
  def zi_move(map, location, color) do

    # 1. check location validation
    player = Map.fetch!(map, color)
    current = Map.fetch!(player, :zi)
    x = Enum.at(current, 0)
    y = Enum.at(current, 1)

    valid_move =
      if color == :blue do [x, y+1] else [x, y-1] end

    if location != valid_move do
      IO.puts "Invalid move\n"
      System.halt(0) # exit
    else
      # 2. if occupied by other token, eat
      all = Map.fetch!(map, :all)

      if location in all do      # replace token
        occupied(map, location, current, color, :zi)

      else         # not occupied
        not_occupied(map, location, current, color, :zi)
      end
    end

  end



  #将 can go top [x, y-1], bottom [x, y+1], left [x-1, y], right [x+1, y]

  def jiang_move(map, location, color) do

    player = Map.fetch!(map, color)
    current = Map.fetch!(player, :jiang)
    x = Enum.at(current, 0)
    y = Enum.at(current, 1)

    # 1. check location validation
    if location not in [[x, y+1], [x, y-1], [x+1, y], [x-1, y]] do
      IO.puts "Invalid move\n"
      System.halt(0) # exit
    else
      # 2. if occupied by other token, eat
      all = Map.fetch!(map, :all)

      if location in all do      # replace token
        occupied(map, location, current, color, :jiang)
      else         # not occupied
        not_occupied(map, location, current, color, :jiang)
      end
    end

  end

  #     相 can go top-right [x+1, y-1], top-left [x-1, y-1], bottom-right [x+1, y+1], bottom-left [x-1, y+1]

  def xiang_move(map, location, color) do
    player = Map.fetch!(map, color)
    current = Map.fetch!(player, :xiang)
    x = Enum.at(current, 0)
    y = Enum.at(current, 1)

    # 1. check location validation
    if location not in [[x+1, y+1], [x+1, y-1], [x-1, y+1], [x-1, y-1]] do
      IO.puts "Invalid move\n"
      System.halt(0) # exit
    else
      # 2. if occupied by other token, eat
      all = Map.fetch!(map, :all)

      if location in all do      # replace token
        occupied(map, location, current, color, :xiang)
      else         # not occupied
        not_occupied(map, location, current, color, :xiang)
      end
    end
  end

  #  王 can go anywhere within 1 step
  def wang_move(map, location, color) do
    player = Map.fetch!(map, color)
    current = Map.fetch!(player, :wang)
    x = Enum.at(current, 0)
    y = Enum.at(current, 1)

    # 1. check location validation
    if location not in [[x+1, y+1], [x+1, y-1], [x-1, y+1], [x-1, y-1], [x, y+1], [x, y-1], [x+1, y], [x-1, y]] do
      IO.puts "Invalid move\n"
      System.halt(0) # exit
    else
      # 2. if occupied by other token, eat
      all = Map.fetch!(map, :all)

      if location in all do      # replace token
        occupied(map, location, current, color, :wang)
      else         # not occupied
        not_occupied(map, location, current, color, :wang)
      end
    end

  end

  def check_win(map) do
    # condition 1: 王 is eaten by opponent
    # condition 2: the token 王 go into opponent zone (blue: column 1, yellow: column 4)

    blue = Map.fetch!(map, :blue)
    yellow = Map.fetch!(map, :yellow)

    blue_wang = Map.fetch!(blue, :wang)
    [_, bcol] = blue_wang
    yellow_wang = Map.fetch!(yellow, :wang)
    [_, ycol] = yellow_wang

    cond do
      blue_wang == [0,0] or ycol == 1 ->
        IO.puts "The yellow wins!"
        true
      yellow_wang == [0,0] or bcol == 4 ->
        IO.puts "The blue wins!"
        true
      true -> false
    end
  end

  def print_init_board() do
    IO.puts "+----+----+----+----+"
    IO.puts "| #{Color.blue("相")} |    |    | #{Color.yellow("将")} |"
    IO.puts "+----+----+----+----+"
    IO.puts "| #{Color.blue("王")} | #{Color.blue("子")} | #{Color.yellow("子")} | #{Color.yellow("王")} |"
    IO.puts "+----+----+----+----+"
    IO.puts "| #{Color.blue("将")} |    |    | #{Color.yellow("相")} |"
    IO.puts "+----+----+----+----+"

  end

  def init_board() do
    arr = [[2,2], [1,3], [1,1], [1,2], [2,3], [1,4], [3,4], [2,4]]
    board = ["相", "  ", "  ", "将",
          "王", "子", "子", "王",
          "将", "  ", "  ", "相"]
    blue = %{:zi => [2,2], :jiang => [3,1], :xiang => [1,1], :wang => [2,1]}
    yellow = %{:zi => [2,3], :jiang => [1,4], :xiang => [3,4], :wang => [2,4]}
    players = %{:blue => blue, :yellow => yellow, :all => arr, :board => board}

    players
  end

  def print_board(map) do
    blue = Map.fetch!(map, :blue)
    yellow = Map.fetch!(map, :yellow)

    board = Map.fetch!(map, :board)
    color_board =
      board
    |> Enum.with_index
    |> Enum.map(fn ({x, i}) ->

      row = trunc(i/4)+1
      col = Integer.mod(i, 4)+1

      # colored
      cond do
        [row, col] in Map.values(blue) -> Color.blue(x)
        [row, col] in Map.values(yellow) -> Color.yellow(x)
        true -> x
      end
    end)

    [a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4] = color_board
    between = "+----+----+----+----+\n"
    line1 =   "| #{a1} | #{a2} | #{a3} | #{a4} |\n"
    line2 =   "| #{b1} | #{b2} | #{b3} | #{b4} |\n"
    line3 =   "| #{c1} | #{c2} | #{c3} | #{c4} |\n"

    IO.puts between <> line1 <> between <> line2 <> between <> line3 <> between
  end

  def next_turn(map, color_atom) do
    if color_atom == :blue do
      IO.puts "It's blue's turn."
    else
      IO.puts "It's yellow's turn. "
    end
    # step 3: choose a chess and pick a new location
    IO.puts "We have row 1 to row 3, column 1 to column 4."
    pick = IO.gets "Pick a chess to move (1王 2将 3相 4子): "
    x = IO.gets "Pick the row of new location: "
    y = IO.gets "Pick the col of new location: "
    new_location = [String.trim_trailing(x) |> String.to_integer(), String.trim_trailing(y) |> String.to_integer()]
    pick = String.trim_trailing(pick)
    new_map =
      cond do
        pick == "1" ->
          {flag, new_map} = wang_move(map, new_location, color_atom)
          # if valid move
          if flag == true do
            # print board
            print_board(new_map)
            new_map
          end
        pick == "2" ->
          {flag, new_map} = jiang_move(map, new_location, color_atom)
          # if valid move
          if flag == true do
            # print board
            print_board(new_map)
            new_map
          end
        pick == "3" ->
          {flag, new_map} = xiang_move(map, new_location, color_atom)
          # if valid move
          if flag == true do
            # print board
            print_board(new_map)
            new_map
          end
        pick == "4" ->
          {flag, new_map} = zi_move(map, new_location, color_atom)
          # if valid move
          if flag == true do
            # print board
            print_board(new_map)
            new_map
          end
        true ->
          IO.puts "Can't pick invalid token\n"
          System.halt(0) # exit
      end

    if check_win(new_map) do
      System.halt(0)
    else
      if color_atom == :blue do next_turn(new_map, :yellow) end
      if color_atom == :yellow do next_turn(new_map, :blue) end
    end
  end


  def main(_args \\ []) do
    # step 1: choose player
    player_color = IO.gets "Choose your player: [yellow or blue] "

    if player_color not in ["yellow\n", "blue\n"] do
      IO.puts "Invalid choice"
      System.halt(0) # exit
    end

    color_atom =
      if player_color == "yellow\n" do
        :yellow
      else
        :blue
      end

    # step 2: init chess board
    # print initial chess board
    print_init_board()
    # generate initial chess board to map
    map = init_board()

    next_turn(map, color_atom)


  end


end
