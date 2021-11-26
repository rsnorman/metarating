require 'byebug'
require 'net/http'
require 'nokogiri'

NBC_RATINGS_URL = 'https://soccer.nbcsports.com/2021/11/14/usmnt-player-ratings-2022-world-cup-qualifying-mexico/'
NBC_RATING_MATCHHER = /<p><strong>[A-Z]+\s–\s.*<\/strong>\s\d/

class GamePlayerRating
  attr_accessor :player, :position, :rating, :notes

  def initialize(game, team, source)
    @game = game
    @team = team
    @source = source
  end
end

uri = URI.parse(NBC_RATINGS_URL)
response = Net::HTTP.get_response(uri)
page = Nokogiri::HTML(response.body)

article_paragraphs = page.css('.entry-content p')

ratings = article_paragraphs.select do |paragraph|
  NBC_RATING_MATCHHER.match?(paragraph.to_s)
end

ratings.each do |player_rating|
  game_player_rating = GamePlayerRating.new('USA vs Mexico World Cup Qualifier - November 12, 2021',
                                            'USA',
                                            'NBC Sports')

  game_player_rating.position = player_rating.css('strong').first.text.split(' – ').first
  game_player_rating.player = player_rating.css('strong').first.text.split(' – ').last.chomp(':')
  game_player_rating.rating = player_rating.text.split(': ')[1].split(/\s/).first
  #byebug
  game_player_rating.notes = player_rating.text.split(': ').last.split(' – ').last

#  puts "Player: #{player}"
#  puts "Position: #{position}"
#  puts "Rating: #{rating}"
#  puts "Notes: #{notes}"
  puts game_player_rating.inspect
  puts "\n"
end
