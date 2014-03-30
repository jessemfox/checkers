require_relative 'board'

class Game
  attr_accessor :board
  def initialize
    @board = Board.new
  end
  
  def play
    current_color = :red
    
    until game_over?
      begin
        display_board
        player_move(get_input, current_color)
      rescue InvalidMoveError => e
        puts e.message
        retry
      end
      
      current_color = other_color(current_color)
    end
    
    puts "Game Over! #{winner.to_s.upcase} wins."
  end
  
  def game_over?
    @board.pieces_for(:red) == 0 || @board.pieces_for(:black) == 0
  end
  
  def winner
    :red
  end
  
  def display_board
    #system("clear")
    puts @board
  end
  
  def other_color(color)
    color == :red ? :black : :red
  end
  
  def get_input
    puts "Make a move eg: x,y x,y x,y"
    input = gets.chomp.split()
    str_arr = input.map { |el| el.split(",") }
    arr = str_arr.map { |el| [el[0].to_i, el[1].to_i] }
  end
  
  def fix_that
    
  end
  
  def player_move(move, color)
    raise InvalidMoveError unless @board[move[0]].color == color
    @board.perform_moves(move[0], move[1..-1])
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  x = Piece.new([1,1], game.board, :red, false)
  game.board[[1,1]] = x
  game.board[[1,3]] = nil
  game.board[[2,4]] = nil
  game.play
  
end