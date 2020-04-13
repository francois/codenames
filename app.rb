# frozen_string_literal: true
require "sinatra"

configure do
  WORDS = File.read("words.txt").split("\n").freeze
end

def new_game_name
  srand(Time.now.to_i)
  3.times.map{ rand(WORDS.size) }.map{|idx| WORDS[idx]}.join("-")
end

get "/" do
  @new_game_name = new_game_name
  erb :home
end

get "/game" do
  words = params[:name].split(/[^a-z]/i).map(&:to_s).map(&:downcase)
  halt :bad_request unless words.length == 3
  halt :bad_request if words.any?(&:empty?)

  idx1 = WORDS.index(words[0])
  idx2 = WORDS.index(words[1])
  idx3 = WORDS.index(words[2])
  halt :not_found if idx1 == -1 || idx2 == -1 || idx3 == -1

  seed = idx1 * idx2 * idx3
  srand(seed)

  @game_name   = [WORDS[idx1], WORDS[idx2], WORDS[idx3]].join(" ")
  @starter     = rand(100) < 50 ? :red : :blue
  @num_cells   = 25
  @num_colored = 6
  @num_black   = 1
  @num_neutral = @num_cells - @num_colored - @num_colored - @num_black

  @grid = [
    @num_colored.times.map{ :red },
    @num_colored.times.map{ :blue },
    @num_black.times.map{ :black },
    @num_neutral.times.map{ :neutral },
  ].flatten.shuffle.each_slice(5).to_a

  @new_game_name = new_game_name
  erb :game
end
