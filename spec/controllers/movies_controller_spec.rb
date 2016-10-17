require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      expect(Movie).to receive(:find_in_tmdb).with('Ted').and_call_original
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end
    it 'should redirect to movies page if search term is null' do
      post :search_tmdb, {:search_terms => ''}
      allow(Movie).to receive(:find_in_tmdb)
      expect(response).to redirect_to('/movies')
    end 
    it 'should redirect to movies if search results 0 values' do
      post :search_tmdb, {:search_terms => 'rfvbtghnuijm'}
      allow(Movie).to receive(:find_in_tmdb)
      expect(response).to redirect_to('/movies')
    end
  end
  
  describe 'adding to RP' do
    it 'should call model method that creates from tmdb' do
      fake_results = [double('movie3')]
      expect(Movie).to receive(:create_from_tmdb).with('941'). and_return(fake_results)
      post :add_tmdb, {:checkbox => {'941':'1'}}
    end
    it 'should call model method id of selected movie' do
      expect(Movie).to receive(:create_from_tmdb).with('941')
      post :add_tmdb, {:checkbox => {'941':'1'}}
    end
    it 'should redirect to movies if no movies selected' do
      post :add_tmdb, {}
      expect(response).to redirect_to('/movies')
    end
  end
end
