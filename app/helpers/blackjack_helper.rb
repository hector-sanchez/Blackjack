# frozen_string_literal: true

module BlackjackHelper
  SUIT_SYMBOLS = {
    "spades" => "&#9824;",
    "hearts" => "&#9829;",
    "diamonds" => "&#9830;",
    "clubs" => "&#9827;"
  }.freeze

  OUTCOMES = {
    "player_win" => "You win",
    "dealer_win" => "Dealer wins",
    "push" => "Push"
  }.freeze

  def suit_symbol(suit)
    SUIT_SYMBOLS.fetch(suit).html_safe
  end

  def card_color_class(suit)
    %w[hearts diamonds].include?(suit) ? "card--red" : "card--black"
  end

  def outcome_label(outcome)
    OUTCOMES.fetch(outcome)
  end

  def winning_seat?(seat, outcome)
    (seat == :player && outcome == "player_win") ||
      (seat == :dealer && outcome == "dealer_win")
  end
end
