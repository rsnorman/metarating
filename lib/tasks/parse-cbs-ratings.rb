require 'byebug'
require 'net/http'
require 'nokogiri'

CBS_RATINGS_URL = 'https://www.cbssports.com/soccer/news/usmnt-player-ratings-pulisic-shines-off-the-bench-as-musah-cements-his-spot/amp/'

def get_page(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  Nokogiri::HTML(response.body)
end

page = get_page(CBS_RATINGS_URL)

def get_rating_section(page)
  page.css('#article-body table:first')[0]
end

rating_section = get_rating_section(page)

def get_rating_elements(rating_section)
  ratings = rating_section.css('tr').select do |section|
    section.children.first.name != 'th'
  end
end

rating_elements = get_rating_elements(rating_section)

def parse_ratings(rating_elements)
  ratings = []
  rating_elements.each do |player_rating_element|
    game_player_rating = {
      game: 'USA vs Mexico World Cup Qualifier - November 12, 2021',
      team: 'USA',
      source: 'CBS Sports'
    }
    game_player_rating[:position] = parse_position(player_rating_element, ratings)
    game_player_rating[:player] = parse_name(player_rating_element)
    game_player_rating[:rating] = parse_rating(player_rating_element)
    game_player_rating[:notes] = parse_notes(player_rating_element)
    game_player_rating[:is_substitute] = parse_is_substitute(player_rating_element)
    game_player_rating[:minutes_played] = parse_minutes_played(player_rating_element)
    ratings << game_player_rating
  end

  ratings
end

def parse_position(player_rating_element, player_ratings)
  text = player_rating_element.css('td').first.text
  if text.include?('(')
    text.split('(').last.split(')').first rescue nil
  else
    replaced_player_name = player_rating_element.css('td')[1].text.split('(').first.strip
    replaced_player_rating = player_ratings.find do |rating|
      rating[:player].end_with?(replaced_player_name)
    end
    replaced_player_rating[:position] rescue nil
  end
end

def parse_name(player_rating_element)
  player_rating_element.css('td').first.text.split(')').last.strip rescue player_rating.css('td').first.text
end

def parse_rating(player_rating_element)
  player_rating_element.css('td').last.text
end

def parse_notes(player_rating_element)
  player_rating_element.children[2].text
end

def parse_is_substitute(player_rating_element)
  false
end

def parse_minutes_played(player_rating_element)
  text = player_rating_element.css('td')[1].text
  if text.include?('(')
    (90 - text.split('(').last.split(')').first.to_i).abs
  else
    text.to_i
  end
end

ratings = parse_ratings(rating_elements)

ratings.each do |rating|
  puts rating
  puts "\n"
end
