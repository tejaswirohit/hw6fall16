class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      if string == nil or string.length < 1
        return nil
      end
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      tmdb_response = Tmdb::Movie.find(string)
      if tmdb_response == nil or tmdb_response.length == 0
        return []
      else
        result = []
        tmdb_response.each do |response_object|
          release_info = Tmdb::Movie.releases(response_object.id)
          response_object_hash = response_object.instance_values
          rating = ''
          release_info['countries'].each do |country_info|
            if country_info['iso_3166_1'] == 'US' && rating == ''
              rating = country_info['certification']
            end
          end
          if rating == ''
            rating = "NA"
          end
          response_object_hash['rating'] = rating
          result.push(response_object_hash)
        end
        return result
      end
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(id)
    movie_info = Tmdb::Movie.detail(id)
    movie_hash = Hash.new()
    movie_hash[:title] = movie_info['title']
    movie_hash[:description] = movie_info['overview']
    movie_hash[:release_date] = movie_info['release_date']
    
    release_info = Tmdb::Movie.releases(id)
    rating = ''
    release_info['countries'].each do |country_info|
      if country_info['iso_3166_1'] == 'US' && rating == ''
        rating = country_info['certification']
      end
    end
    movie_hash[:rating] = rating
    
    Movie.create(movie_hash)
    
  end

end
