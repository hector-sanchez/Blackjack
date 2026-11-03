# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Blackjack::Sessions", type: :request do
  def persist_owned_game(*ranks)
    stub_shoe(*ranks)
    post blackjack_sessions_path
    GameSession.last
  end

  describe "POST /blackjack/sessions" do
    it "starts a game, stores the session id, and redirects" do
      expect { post blackjack_sessions_path }.to change(GameSession, :count).by(1)

      game_session = GameSession.last
      expect(session[:game_session_id]).to eq(game_session.id)
      expect(response).to redirect_to(blackjack_session_path(game_session))
    end

    it "sitting down again starts a new session" do
      first = persist_owned_game(10, 9, 7, 6)

      post blackjack_sessions_path

      second = GameSession.last
      expect(second.id).not_to eq(first.id)
      expect(session[:game_session_id]).to eq(second.id)
      expect(response).to redirect_to(blackjack_session_path(second))
    end
  end

  describe "GET /blackjack/sessions/:id" do
    it "hides the hole card and remaining shoe during the player's turn" do
      game_session = persist_owned_game(10, 9, 7, 6, 2)

      get blackjack_session_path(game_session)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(">10<")
      expect(response.body).to include(">7<")
      expect(response.body).to include(">9<")
      expect(response.body).to include("&#9824;")
      expect(response.body).to include("Face down")
      expect(response.body).not_to include(">6<")
      expect(response.body).not_to include(">2<")
    end

    it "reveals the hole card and announces the winner when the round is over" do
      game_session = persist_owned_game("A", 9, "K", 7)

      get blackjack_session_path(game_session)

      expect(response.body).to include("You win")
      expect(response.body).to include("✓")
      expect(response.body).to include(">9<")
      expect(response.body).to include(">7<")
      expect(response.body).not_to include("player_win")
      expect(response.body).not_to include("Face down")
    end

    it "does not show a session the player does not own" do
      persist_owned_game(10, 9, 7, 6, 2)
      other = GameSession.create!(shoe_cards: [], status: "active")

      get blackjack_session_path(other)

      expect(response).to have_http_status(:not_found)
    end

    it "does not show a missing session" do
      get blackjack_session_path(0)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "gameplay across requests" do
    it "hits, stands, and persists the public table after each action" do
      game_session = persist_owned_game(10, 9, 7, 6, 4, "K")

      post hit_blackjack_session_path(game_session)
      expect(response).to redirect_to(blackjack_session_path(game_session))

      get blackjack_session_path(game_session)
      expect(response.body).to include(">10<")
      expect(response.body).to include(">7<")
      expect(response.body).to include(">4<")
      expect(response.body).to include("Face down")
      expect(response.body).not_to include(">6<")

      post stand_blackjack_session_path(game_session)
      expect(response).to redirect_to(blackjack_session_path(game_session))

      get blackjack_session_path(game_session)
      expect(response.body).to include(">6<")
      expect(response.body).to include(">K<")
      expect(response.body).to include("You win")
      expect(response.body).not_to include("Face down")
    end

    it "deals the next round from the leftover shoe" do
      game_session = persist_owned_game("A", 9, "K", 7, 10, 8, 5, 6)

      expect { post deal_blackjack_session_path(game_session) }
        .not_to change(GameSession, :count)

      expect(response).to redirect_to(blackjack_session_path(game_session))

      get blackjack_session_path(game_session)
      expect(response.body).to include(">10<")
      expect(response.body).to include(">5<")
      expect(response.body).to include(">8<")
      expect(response.body).to include("Face down")
      expect(response.body).not_to include(">6<")
      expect(response.body).not_to include("You win")
    end
  end

  describe "invalid actions" do
    it "does not let a player hit or stand on another player's session" do
      persist_owned_game(10, 9, 7, 6, 4)
      other = GameSession.create!(shoe_cards: [], status: "active")

      post hit_blackjack_session_path(other)
      expect(response).to have_http_status(:not_found)

      post stand_blackjack_session_path(other)
      expect(response).to have_http_status(:not_found)

      post deal_blackjack_session_path(other)
      expect(response).to have_http_status(:not_found)
    end

    it "rejects a hit after the round is over" do
      game_session = persist_owned_game("A", 9, "K", 7)

      expect { post hit_blackjack_session_path(game_session) }
        .to raise_error(Games::Blackjack::Round::InvalidActionError)
    end

    it "rejects a hit when only stand is legal" do
      game_session = persist_owned_game(10, 9, 7, 6, 4, "K")
      post hit_blackjack_session_path(game_session)

      expect { post hit_blackjack_session_path(game_session) }
        .to raise_error(Games::Blackjack::Round::InvalidActionError)
    end

    it "rejects dealing until the current round is over" do
      game_session = persist_owned_game(10, 9, 7, 6)

      expect { post deal_blackjack_session_path(game_session) }
        .to raise_error(Games::Blackjack::SessionManager::InvalidActionError)
    end
  end
end
