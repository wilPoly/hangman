# frozen_string_literal: true

# Game engine
class Game
  WORDLIST = './google-10000-english-no-swears.txt'
  TURNS = 8

  def initialize
    @secret_word = define_secret_word(WORDLIST)
    @hidden_word = @secret_word.gsub(/./, '_')
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

  def write_guess(secret, hidden, guess)
    secret.split('').each_with_index do |letter, i|
      hidden[i] = guess if letter == guess
    end
    hidden
  end

  def guess_word
    puts 'Guess a letter from the secret word.'
    guess = gets.chomp[0].downcase
    if @secret_word.include?(guess)
      puts "'#{guess}' is in the word!"
      @hidden_word = write_guess(@secret_word, @hidden_word, guess)
    else
      puts "'#{guess} is not in the word!"
      misses << guess unless misses.include?(guess)
    end
  end

  def win?(hidden, secret)
    puts 'You win!' if hidden == secret
  end

  def turn
    turns_left = TURNS
    until turns_left.zero?
      puts @secret_word
      puts @hidden_word
      guess_word
      puts 'You win!' if @secret_word == @hidden_word
      turns_left -= 1
    end
  end
end

game = Game.new
# p game.define_secret_word('./google-10000-english-no-swears.txt')
