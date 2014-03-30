require_relative "piece"
require 'colorize'

class Board
  attr_accessor :grid
  
  def initialize
    @grid = Array.new(8) { Array.new(8) }
    set_board
  end
  
  def [](pos)
    x,y = pos
    @grid[x][y]
  end
  
  def []=(pos,val)
    x,y = pos
    @grid[x][y] = val 
  end
  
  def find_black_squares
    blacks = []
    
    @grid.each_with_index do |row, r_idx|
      row.each_with_index do |pos, p_idx|
        if (r_idx.even? && p_idx.even?) || (r_idx.odd? && p_idx.odd?)
          blacks << [r_idx, p_idx]
        end
      end
    end
    
    blacks
  end
  
  def set_board
    find_black_squares.each do |square|
      if square[0].between?(0,2)
        @grid[square[0]][square[1]] = Piece.new(square, self, :black, false)
      elsif square[0].between?(5,7)
        @grid[square[0]][square[1]] = Piece.new(square, self, :red, false)
      else
        next
      end
    end
  end
  
  def to_s
    board_str = ""
    @grid.each_with_index do |row, ri|
      board_str << "#{ri} |"
      row.each_with_index do |pos, pi|
        if pos.nil? 
          board_str << color_board(ri, pi, "   " )
        elsif pos.color == :black
          board_str << color_board(ri, pi, " B ".blue)
        elsif pos.color == :red
          board_str << color_board(ri, pi, " R ".red)
        end
      end
      board_str << "\n"
    end
    nums = ""
    8.times { |i| nums << " #{i} " }
    board_str << "   " + nums
  end
  
  def color_board(row, col, input)
    if (row.even? && col.even?) || (row.odd? && col.odd?)
      input.on_black
    else
      input.on_white
    end
  end
  
  def move(start, target)
    start_pos = self[[start[0], start[1]]]
    color = start_pos.color
    if start_pos.slide_moves(color).include?(target)
      start_pos.perform_slide(target)
      p "In here"
    elsif start_pos.jump_moves(color).include?(target)
      start_pos.perform_jump(target)
      p "in here"
    else
      false
    end
  end
  
  def dup_board
    new_board = Board.new
    new_board.grid = @grid.map {|x| x.dup}
    new_board.grid.each_with_index do |row, r_idx|
      row.each_with_index do |piece, p_idx|
        next if piece.nil?
        new_piece = Piece.new(piece.pos.dup, new_board, piece.color, piece.king)
        new_board[[r_idx,p_idx]] = new_piece
        new_piece.board = new_board
      end
    end
    new_board
  end
  
  def perform_moves!(start, move_sequence)
    if move_sequence.count == 1 && self[start].slide_moves(self[start].color).include?(move_sequence[0])
      move(start, move_sequence[0])
    else
      move_sequence.each do |move|
        raise InvalidMoveError unless self[start].jump_moves(self[start].color).include?(move)
        move(start, move)
        start = move
      end
    end
  end
  
  def perform_moves(start, move_sequence)
    return false unless valid_move_sequence?(start, move_sequence)
    perform_moves!(start, move_sequence) 
    true
  end
  
  def valid_move_sequence?(start, move_sequence)
    begin
      duped_board = self.dup_board
      duped_board.perform_moves!(start, move_sequence)
    rescue InvalidMoveError => e
      puts e.message
      false
    else
      true
    end
  end
  
  def pieces_for(color)
    cnt = 0
    @grid.each do |row|
      row.each do |pos|
        next if pos.nil?
        cnt += 1 if pos.color == color
      end
    end
    cnt
  end
  
end

class InvalidMoveError < ArgumentError
  def initialize
    super
  end
end