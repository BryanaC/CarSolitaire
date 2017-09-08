=begin
Author: Bryana Craig
Assignment: Ruby Car Solitaire
Due Date: November 18, 2016 11:59pm
=end

require 'date'

=begin
Author: Bryana Craig
Purpose: Creates a card in the deck
=end
class Card
  SUITS = %w(Hearts Diamonds Spades Clubs)
  RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

  attr_accessor :rank, :suit

  #Author: Bryana Craig
  #Purpose: initializes a card with a rank and suit
  #Inputs: id, one of 52
  def initialize(id)
      self.rank = RANKS[id % 13]
      self.suit = SUITS[id % 4]
  end
  
  #Author: Bryana Craig
  #Purpose: calculates point values for each card
  def points
    if @rank == "Ace" then
      return 1
    elsif ["Jack", "Queen", "King"].include? @rank then
      return 10
    else
      @rank.to_i
    end
  end
  
  #Author: Bryana Craig
  #Purpose: overloads toString for card printing
  def to_s
    "#{@rank} of #{@suit}"
  end
end

=begin
Author: Bryana Craig
Purpose: Creates a deck from Cards
=end
class Deck
    attr_accessor :cards
    #Author: Bryana Craig
    #Purpose: initializes a deck made up of 52 cards and shuffles it
    def initialize
        self.cards = (0..51).to_a.shuffle.collect { |id| Card.new(id) }
    end
    
  #Author: Bryana Craig
  #Purpose: pops the top card off of the deck
  def pop
    self.cards.pop()
  end
end

=begin
Author: Bryana Craig
Purpose: Creates and plays the car solitaire game
=end
class Game
  #Author: Bryana Craig
  #Purpose: begins either a normal or hidden game
  def self.play hidden
    if hidden
      puts "Begin Hidden Game..."
    else
      puts "Begin Game..."
    end
    
    deck = Deck.new
    #The four face-up cards in the hand
    visible_hand = Array.new(4)
    hand = Array.new
    while deck.cards.any? do
      for i in 0..3
        if visible_hand[i] == nil
          if hand.any? then visible_hand[i] = hand.pop()
          else visible_hand[i] = deck.pop()end
          if visible_hand[i] == nil then
            break
          end
        end
      end
      
      #displays the face-up cards
      if !hidden
        display_hand(visible_hand)
      end

      if visible_hand[0].rank == visible_hand[-1].rank
        if !hidden then
          puts "All Cards Discarded"
        end
          visible_hand.clear()
      elsif visible_hand[0].suit == visible_hand[-1].suit
        if !hidden then
          puts "Middle Cards Discarded"
        end
          visible_hand[1] = visible_hand[2] = nil
          visible_hand.insert(1, visible_hand.delete_at(3))
      else
        if !hidden then
          puts "No Cards Discarded"
        end
        hand.push(visible_hand.shift())
        visible_hand.push(deck.pop())
      end
      if !hidden
        puts "Return -> Continue \t X -> Exit"
        if gets.strip.upcase == Instructions::EXIT then
          exit
        end
      end
    end
    score = calculate_score(visible_hand)
    puts "Game Complete. Your score: #{score}"
    update_leaderboard(score)
    score
  end
  
  #Author: Bryana Craig
  #Purpose: print the instructions for user
  def self.display_commands
    puts "Command List: "
    puts " X: Exit Game"
    puts " L: Display Leaderboard"
    puts " P: Play Game"
    puts " H: Play Hidden Game"
  end

  #Author: Bryana Craig
  #Purpose: retrieves the command from the user
  def self.retrieve_command
    puts
    display_commands
    puts "Enter Command: "
    input = gets
    input.strip!.upcase!
    case input
      when Instructions::EXIT
        exit
      when Instructions::LEADER_BOARD
        Instructions::LEADER_BOARD
      when Instructions::PLAY
        Instructions::PLAY
      when Instructions::PLAY_HIDDEN
        Instructions::PLAY_HIDDEN
      else
        puts "Unknown instruction '#{input}'"
        Instructions::UNKNOWN
      end
  end
  
  #Author: Bryana Craig
  #Purpose: Displays the face-up cards
  #Inputs: visible_hand, the four face-up cards
  def self.display_hand(visible_hand)
    visible_hand.each do |c| print "#{c.to_s}     " end
    puts
  end
  
  #Author: Bryana Craig
  #Purpose: Calculates score at end of game
  #Inputs: hand, remaining cards in hand
  #Outputs: score as string
  def self.calculate_score(hand)
    score = 0
    hand.each do |card|
      score += card.points
    end
    return score.to_s
  end

  #Author: Bryana Craig
  #Purpose: displays the leaderboard from file
  def self.display_leaderboard
    if File.exist? 'Leaderboard.txt' then
      File.open('Leaderboard.txt') do |f|
        f.each_line do |line|
          puts line
        end
      end
    else
      puts "No previous game found."
    end
  end
  
  #Author: Bryana Craig
  #Purpose: Updates the leaderboard file
  #Inputs: score, the score from last game played
  def self.update_leaderboard(score)
    print "Enter Name: "
    name = gets.chomp
  
    if !File.file?("Leaderboard.txt")
      f = File.new("Leaderboard.txt", "w+")
      f.close
    end
  
    scores = File.readlines("Leaderboard.txt")
  
    scores << "Score: " + score + " \t" + "Name: " + name + " \t" + "Date: " + Date.today.to_s + "\n"
    
    scores.sort!
  
    scores.pop if scores.size > 5
  
    f = File.new("Leaderboard.txt", "w")
    f.puts(scores)
    f.close
  end

  module Instructions
      EXIT = 'X'
      LEADER_BOARD = 'L'
      PLAY = 'P'
      PLAY_HIDDEN = 'H'
      UNKNOWN = ''
  end
  
  while true
      case retrieve_command()
          when Instructions::LEADER_BOARD
              display_leaderboard()
          when Instructions::PLAY
              play(false)
          when Instructions::PLAY_HIDDEN
              play(true)
      end
    end
  end