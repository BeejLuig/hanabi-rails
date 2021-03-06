require 'rails_helper'

RSpec.describe "Games API", type: :request do

  before(:each) do 
    @user = create(:user)
    @token = Auth.create_token(@user.id)
    @token_headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      'Authorization': "Bearer: #{@token}"
    }
    @tokenless_headers = { "CONTENT_TYPE" => "application/json" }
  end

  it 'all routes require a token' do 
      responses = []
      response_bodies = []
      game = create(:game)
      params = { game: { title: "Test Game" } }

      post '/api/games', params: params.to_json, headers: @tokenless_headers
      responses << response 
      response_bodies << JSON.parse(response.body)

      get "/api/games", headers: @tokenless_headers
      responses << response 
      response_bodies << JSON.parse(response.body)

      post "/api/games/#{game.id}/join", headers: @tokenless_headers
      responses << response 
      response_bodies << JSON.parse(response.body)
    
      responses.each { |r| expect(r).to have_http_status(403) }
      response_bodies.each { |body| expect(body["errors"]).to eq([{ "message" => "You must include a JWT Token!" }]) }
    end
    
  describe 'POST /games' do 

    describe 'successful creation' do 

      it 'returns the newly created game' do     
        params = { game: { title: "Test Game" } }
        post '/api/games', params: params.to_json, headers: @token_headers
        body = JSON.parse(response.body)

        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(200)
        expect(body).to match({
          "id" => be_kind_of(Integer),
          "title" => match(/Test Game/),
          "status" => match(/setup/)
        })
      end
    end 

    describe 'failure (due to validations)' do 

      it 'returns a 500 status with error messages' do 
        game = create(:game)
        params = { game: { title: game.title } }
        post '/api/games', params: params.to_json, headers: @token_headers
        body = JSON.parse(response.body)

        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(500)
        expect(body["errors"]).to eq({ "title" => ["has already been taken"] })
      end 
    end
  end

  describe 'GET /games' do 

    it 'returns a list of all games that have a status of setup or active' do  
      create(:game)
      create(:game, title: "game 2", status: 1)   
      get '/api/games', headers: @token_headers
      body = JSON.parse(response.body)

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(200)
      expect(body["games"].count).to eq(2)
      expect(body["games"][0]).to match({
        "id" => be_kind_of(Integer),
        "title" => match(/game_test/),
        "status" => match(/setup/)
      })
      expect(body["games"][1]).to match({
        "id" => be_kind_of(Integer),
        "title" => match(/game 2/),
        "status" => match(/active/)
      })
    end
  end
end