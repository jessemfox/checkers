class Piece
  SLIDE_OPTS = [[1, 1], [1, -1]]
  JUMP_OPTS = [[2, 2], [2,-2] ]
  
  attr_accessor :pos, :board, :color, :king
  
  def initialize(pos, board, color, king)
    @pos, @board, @color = pos, board, color
    @king = false
  end
  
  def perform_slide(target)
    return false unless slide_moves(self.color).include?(target)
    move!(target)
    maybe_premote
    true
  end
  
  def perform_jump(target)
    jumps = jump_moves(self.color)
    #raise "You can't jump there" unless jumps.keys.include?(target)
    return false unless jumps.keys.include?(target)
    jumped_piece = jumps[target]
    
    @board[[jumped_piece[0], jumped_piece[1]]] = nil
    move!(target)
    maybe_premote
    true
  end
  
  def move!(target)
    @board[[@pos[0], @pos[1]]] = nil
    @pos = target
    @board[[target[0], target[1]]] = self
  end
  
  def move_opts(color)
    slide_moves = []
    if color == :red && !self.king
      slide_moves = SLIDE_OPTS.map { |el| [el[0] * -1, el[1]] }
    elsif color == :black && !self.king
      slide_moves = SLIDE_OPTS
    else
      slide_moves = SLIDE_OPTS + SLIDE_OPTS.map { |el| [el[0] * -1, el[1]] }
    end
    slide_moves
  end
  
  def slide_moves(color)
    move_arr = []
    move_opts(color).each do |move|
      dx = self.pos[0] + move[0]
      dy = self.pos[1] + move[1]
      space = @board[[dx, dy]]
      move_arr << [dx, dy] if dx.between?(0,7) && dy.between?(0,7) && space.nil?
    end
    move_arr
  end
    
  def jump_moves(color)
    move_hash = {}
    slide_arr = slide_moves(color)
    move_opts(color).each do |move|
      dx = self.pos[0] + move[0]
      dy = self.pos[1] + move[1]
      dx2 = self.pos[0] + (move[0] * 2)
      dy2 = self.pos[1] + (move[1] * 2)
      enemy_piece = @board[[dx, dy]]
      next if slide_arr.include?([dx, dy])
      move_hash[[dx2, dy2]] = [dx, dy] if dx2.between?(0,7) && dy2.between?(0,7) && !enemy_piece.nil? && 
      @board[[dx2, dy2]].nil?
    end
    move_hash
  end
  
  # def jumped_piece(end_pos)
  #   
  # end
  
  def maybe_premote
    @king = true if on_back_row?
  end
  
  def on_back_row?
    (self.color == :red && @pos[0] == 0) || (self.color == :black && @pos[0] == 7)
  end
  
  
  
  
  
end