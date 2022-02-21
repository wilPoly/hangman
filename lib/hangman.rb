# frozen_string_literal: true

# Game engine
class Game
  WORDLIST = './google-10000-english-no-swears.txt'
  TURNS = 8

  def initialize
    @secret_word = define_secret_word(WORDLIST)
    @hidden_word = @secret_word.gsub(/./, '_')
    @turns_left = TURNS
    @misses = []
    turn
  end

  def define_secret_word(word_list)
    word = ''
    File.open(word_list, 'r') do |file|
      lines = file.readlines
      word = lines[rand(lines.length)].chomp until word.chomp.length.between?(5, 12)
    end
    word
  end

  def player_input
    input = ''
    while input == ''
      input = gets.downcase.chomp[0]
      case input
      when ('a'..'z')
        guess(input)
      when '1'
        save_game # TODO
        redo
      else
        redo
      end
    end
  end

  def write_guess(secret, hidden, guess)
    secret.split('').each_with_index do |letter, i|
      hidden[i] = guess if letter == guess
    end
    hidden
  end

  def guess(letter)
    if @secret_word.include?(letter)
      puts "'#{letter}' is in the word!"
      @hidden_word = write_guess(@secret_word, @hidden_word, letter)
    else
      puts "'#{letter} is not in the word!"
      @misses << letter unless @misses.include?(letter)
      @turns_left -= 1
    end
  end

  def end_game(condition)
    response = ''
    until %w[Y N].include?(response)
      puts "You #{condition}! Would you like to play another game? Y/N"
      response = gets.upcase.chomp
      case response
      when 'Y'
        Game.new
      when 'N'
        exit(0)
      end
    end
  end

  def turn
    until @turns_left.zero?
      puts @secret_word # comment when done testing
      puts "\n#{@hidden_word} - Misses: #{@misses}"
      puts "#{@turns_left} turns left"
      puts 'Guess a letter from the secret word. Enter "1" to save the game.'
      player_input
      end_game('win') if @secret_word == @hidden_word
    end
    end_game('lose')
  end
end

game = Game.new
# p game.define_secret_word('./google-10000-english-no-swears.txt')
