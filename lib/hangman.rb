# frozen_string_literal: true

require 'yaml'

# Saving and loading games
module FileSystem
  def save_game
    Dir.mkdir('./saves') unless File.exist? './saves'
    File.open('./saves/save_game.yaml', 'w') { |file| file.write save_to_yaml }
  end

  def save_to_yaml
    YAML.dump(
      'secret_word' => @secret_word,
      'hidden_word' => @hidden_word,
      'turns_left' => @turns_left,
      'misses' => @misses
    )
  end

  def load_game
    file = YAML.safe_load(File.open('./saves/save_game.yaml', 'r'))
    @secret_word = file['secret_word']
    @hidden_word = file['hidden_word']
    @turns_left = file['turns_left']
    @misses = file['misses']
  end
end

# Game engine
class Game
  include FileSystem
  WORDLIST = './google-10000-english-no-swears.txt'
  TURNS = 8

  attr_accessor :secret_word, :hidden_word, :turns_left, :misses

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
      # get random word with rand(max=lines.length)
      word = lines[rand(lines.length)].chomp until word.chomp.length.between?(5, 12)
    end
    word
  end

  def player_input
    input = ''
    while input == ''
      input = gets.downcase.chomp[0]
      case input
      when ('a'..'z') then guess(input)
      when '1'
        save_game # TODO
        exit(0)
      when '2'
        load_game
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
      puts 'Guess a letter from the secret word. (1) save and exit | (2) load the last saved game'
      player_input
      end_game('win') if @secret_word == @hidden_word
    end
    end_game('lose')
  end
end

Game.new
