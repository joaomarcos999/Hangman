require 'json'

class Hangman
  attr_accessor :secret_word, :guesses_left, :guessed_letters, :current_state, :incorrect_letters

  def initialize(secret_word)
    @secret_word = secret_word
    @guesses_left = 6
    @guessed_letters = []
    @incorrect_letters = []
    @current_state = "_" * secret_word.length
  end

  def to_json(*_args)
    {
      secret_word: @secret_word,
      guesses_left: @guesses_left,
      guessed_letters: @guessed_letters,
      incorrect_letters: @incorrect_letters,
      current_state: @current_state
    }.to_json
  end

  def self.from_json(json_str)
    data = JSON.parse(json_str)
    obj = new(data['secret_word'])
    obj.guesses_left = data['guesses_left']
    obj.incorrect_letters = data['incorrect_letters']
    obj.current_state = data['current_state']
    return obj
  end

  def display_status
    puts "\nCurrent_word: #{@current_state.split('').join(' ')}"
    puts "Incorrect guesses: #{@incorrect_letters.join(", ")}"
    puts "Guesses left: #{guesses_left}"
  end

  def save_game(game)
    Dir.mkdir('saves') unless Dir.exist?('saves')
    puts "Input a name for your save file:"
    save_name = gets.chomp.strip
    save_name = save_name.gsub(/[^0-9A-Za-z_\-]/, "_")
    save_path = "saves/#{save_name}.json"

    File.open(save_path, "w") do |file|
      file.puts to_json
    end
  end

  def self.load_game

    save_folder = 'saves'

    unless Dir.exist?(save_folder) && !Dir.empty?(save_folder)
      puts "No games found!"
      return nil
    end

    save_files = Dir.entries(save_folder).select{ |f| f.end_with?(".json")}

    puts "Available save files:"
    save_files.each_with_index do |file, index|
      puts "#{index}. #{file}"
    end

    puts "Enter the number of the save file you want to load:"
    file_index = gets.chomp.to_i

    if file_index < 0 || file_index >= save_files.size
      puts "Invalid selection, please try again."
      return nil
    end

    save_file = "#{save_folder}/#{save_files[file_index]}"
    json_data = File.read(save_file)

    puts "Game loaded successfully!"

    from_json(json_data)
  end


end

def define_word 
  words_list = File.read("../google-10000-english-no-swears.txt").split("\n")
  keep_going = true
  while keep_going == true
    word = words_list.sample
    keep_going = false if word.length.between?(5, 12)
  end
  word
end

def guess_input
  puts "Input a letter:"
  guess = gets.chomp.downcase
  if guess == 'save'
    return guess
  elsif
    while guess.size != 1 || guess !~ /^[a-z]$/
      puts "Invalid input, please try again:"
      guess = gets.chomp.downcase
    end
  end
  guess
end  

def check_guess(game, guess)

  if game.secret_word.include?(guess)
    puts "Correct guess."
    game.secret_word.chars.each_with_index do |char, index|
      if char == guess
        game.current_state[index] = guess
      end
    end
  else
    puts "Wrong guess."
    game.incorrect_letters << guess
    game.guesses_left -= 1
  end

  game.guessed_letters << guess

end



def play_game  

  puts "Welcome to Hangman!"
  puts "1. Start a new game"
  puts "2. Load a saved game"
  choice = gets.chomp.to_i

  if choice == 2
    game = Hangman.load_game
    puts game
    if game.nil?
      puts "Starting a new game instead..."
      word = define_word
      game = Hangman.new(word)
    end
  else
    word = define_word
    game = Hangman.new(word)
  end

  until game.guesses_left < 1 || !game.current_state.include?("_")
    game.display_status
    puts "Type 'save' to save the game, or guess a letter"
    guess = guess_input
    if guess == "save"
      game.save_game(game)
      puts "Game saved! See you later!"
      return 1
    end

    if game.guessed_letters.include?(guess)
      puts "You already guessed '#{guess}'. Try another letter."
    else
      check_guess(game, guess)
    end
  end

  if game.current_state == game.secret_word
    puts "Congratulations! You guessed the word #{game.secret_word}"
  else
    puts "Game Over! the word was: #{game.secret_word}" 
  end

end

play_game

