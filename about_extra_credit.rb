# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

class DiceSet # handles all the roll logic
  attr_reader :values
  attr_reader :next_rolls

  def initialize
    @values = []
    @next_rolls = 5
  end

  def score(dice)
    pending_threes = {
      1 => 0,
      2 => 0, 
      3 => 0, 
      4 => 0, 
      5 => 0,
      6 => 0
    }
    score = 0
    
    dice.each do |roll|
      pending_threes[roll] += 1
      
      if pending_threes[roll] == 3
        if roll == 1
          score += 800
          @next_rolls -= 1
        else
          if roll == 5
            score -= 100
            @next_rolls += 2
          end
          score += roll * 100
          @next_rolls -= 3
        end
        pending_threes[roll] = 0
      elsif roll == 1
        score += 100
        @next_rolls -= 1
      elsif roll == 5
        score += 50
        @next_rolls -= 1
      end
    end
    
    score
  end

  def roll
    @values = Array.new(next_rolls) {rand(1..6)}
    score(@values)
  end
end

class Player
  attr_reader :name
  attr_reader :score
  attr_reader :in

  def initialize(name)
    @name = name
    @score = 0
    @in = false
  end

  def to_s
    "#{@name}\tScore: #{@score}\tIs 'in'? #{@in}"
  end

  def add(n)
    @score += n
  end

  def is_in
    @in = true
  end
end

class Game # handles all the game logic and provides an interface for the game
  attr_reader :players
  attr_reader :turn
  attr_reader :dice
  attr_reader :tentative_score
  attr_reader :exclude

  def initialize
    @players = []
    @turn = 0
    @dice = DiceSet.new
    @tentative_score = 0
  end

  def player
    @players[@turn % @players.length]
  end

  def advance
    @turn += 1
    @dice = DiceSet.new
    @tentative_score = 0
  end

  def add_score(n)
    @tentative_score += n
    if player.in
      if n == 0
        player.add(-@tentative_score)
      else
        player.add(n)
      end
    elsif @tentative_score >= 300
      player.is_in
      player.add(@tentative_score)
    end
  end

  def roll
    score = @dice.roll
    add_score(score)

    score
  end

  def end_game
    @players.each do |p|
      if p.score >= 3000 and p != player
        @turn = 0
        @dice = DiceSet.new
        @tentative_score = 0
        @exclude = p

        return true
      end
    end
    
    false
  end
end

game = Game.new

# adding players
puts "Adding Players (type 'help' for help):"
while true do
  input = gets.chomp
  if input == "start" or input == "s"
    if game.players.length > 1
      break
    end
    puts "Not enough players in the lobby"
    next
  elsif input == "help"
    puts %(
HOW TO PLAY:
- Type in a name to add a player
- Type 'start' or 's' to start the game
- To roll in the game simply press enter
- Type 'pass' or 'p' to pass your turn
- Read 'GREED_RULES.txt' if you don't know the rules
    )
    next
  end
  
  game.players << Player.new(input)
  puts "Players:", game.players 
end

# title (made with http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=Greed) and newlines for space
puts %(
 ██████╗ ██████╗ ███████╗███████╗██████╗
██╔════╝ ██╔══██╗██╔════╝██╔════╝██╔══██╗
██║  ███╗██████╔╝█████╗  █████╗  ██║  ██║
██║   ██║██╔══██╗██╔══╝  ██╔══╝  ██║  ██║
╚██████╔╝██║  ██║███████╗███████╗██████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝



)

# gameloop
while true do
  if game.end_game
    break
  end

  points_rolled = game.roll

  puts "*** Turn #{game.turn + 1}\t#{game.player}"
  puts "Tentative Score:", game.tentative_score
  puts "Points Rolled:", points_rolled
  puts "Dice Values:", game.dice.values
  puts "Next Roll: #{game.dice.next_rolls} di(c)e"
  

  if points_rolled == 0
    if game.player.in
      puts "#{game.tentative_score} Penalty, #{game.player.score + game.tentative_score} => #{game.player.score}"
    end

    game.advance
  elsif game.dice.next_rolls == 0
    game.advance
  else
    input = gets.chomp
    if input == "pass" or input == "p"
      game.advance
    end
  end
end

# title and newlines (ascii art made with http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=Final%20Round)
puts %(
███████╗██╗███╗   ██╗ █████╗ ██╗         ██████╗  ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
██╔════╝██║████╗  ██║██╔══██╗██║         ██╔══██╗██╔═══██╗██║   ██║████╗  ██║██╔══██╗
█████╗  ██║██╔██╗ ██║███████║██║         ██████╔╝██║   ██║██║   ██║██╔██╗ ██║██║  ██║
██╔══╝  ██║██║╚██╗██║██╔══██║██║         ██╔══██╗██║   ██║██║   ██║██║╚██╗██║██║  ██║
██║     ██║██║ ╚████║██║  ██║███████╗    ██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 



)

# endgame
while true do
  if game.turn + 1 > game.players.length
    break
  elsif game.player == game.exclude
    puts "*** Turn #{game.turn + 1}\t#{game.player.name} skipped"
    game.advance
    next
  end

  points_rolled = game.roll

  puts "*** Turn #{game.turn + 1}\t#{game.player}"
  puts "Tentative Score:", game.tentative_score
  puts "Points Rolled:", points_rolled
  puts "Dice Values:", game.dice.values
  puts "Next Roll: #{game.dice.next_rolls} di(c)e"
  

  if points_rolled == 0
    if game.player.in
      puts "#{game.tentative_score} Penalty, #{game.player.score + game.tentative_score} => #{game.player.score}"
    end

    game.advance
  elsif game.dice.next_rolls == 0
    game.advance
  else
    input = gets.chomp
    if input == "pass" or input == "p"
      game.advance
    end
  end
end

# title and newlines (ascii art made with http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=Game%20Over)
puts %(
-------------------------------------------------------------------------- 
 ██████╗  █████╗ ███╗   ███╗███████╗     ██████╗ ██╗   ██╗███████╗██████╗
██╔════╝ ██╔══██╗████╗ ████║██╔════╝    ██╔═══██╗██║   ██║██╔════╝██╔══██╗
██║  ███╗███████║██╔████╔██║█████╗      ██║   ██║██║   ██║█████╗  ██████╔╝
██║   ██║██╔══██║██║╚██╔╝██║██╔══╝      ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗
╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗    ╚██████╔╝ ╚████╔╝ ███████╗██║  ██║
 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝     ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝
--------------------------------------------------------------------------
)

# game over display
rankings = game.players.sort_by { |p| -p.score }
puts "* #{rankings[0].name} Score: #{rankings[0].score} wins!"

count = 2
rankings[1..-1].each do |p|
  puts "#{"*" * count} #{p.name} Score: #{p.score}"
  count += 1
end
