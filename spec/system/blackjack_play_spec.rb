# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Playing blackjack", type: :system do
  def deal_with_deck(*ranks)
    allow(Games::Blackjack::Game).to receive(:new).and_wrap_original do |original, **kwargs|
      next original.call(**kwargs) unless kwargs.empty?

      original.call(deck: deck_with(*ranks.map { |rank| card(rank) }))
    end

    visit root_path
    click_button "Deal"
  end

  it "plays a full round from the table: hole card hidden, hit persists, stand reveals the winner" do
    deal_with_deck(10, 9, 7, 6, 4, "K")

    expect(page).to have_css("h2", text: "Dealer")
    expect(page).to have_css("h2", text: "You")
    expect(page).to have_css(".card__rank", exact_text: "10")
    expect(page).to have_css(".card__rank", exact_text: "7")
    expect(page).to have_css(".card__rank", exact_text: "9")
    expect(page).to have_css(".card--facedown")
    expect(page).to have_no_css(".card__rank", exact_text: "6")
    expect(page).to have_no_css(".banner")

    click_button "Hit"

    expect(page).to have_css(".card__rank", exact_text: "4")
    expect(page).to have_css(".card--facedown")
    expect(page).to have_no_css(".card__rank", exact_text: "6")

    click_button "Stand"

    expect(page).to have_css(".banner", text: "You win")
    expect(page).to have_css(".seat--winner", text: "You")
    expect(page).to have_css(".card__rank", exact_text: "6")
    expect(page).to have_css(".card__rank", exact_text: "K")
    expect(page).to have_no_css(".card--facedown")
    expect(page).to have_no_button("Hit")
    expect(page).to have_no_button("Stand")
    expect(page).to have_button("Deal again")
  end

  it "announces a dealer blackjack without a face-down card" do
    deal_with_deck(10, "A", 9, "K")

    expect(page).to have_css(".banner", text: "Dealer wins")
    expect(page).to have_css(".seat--winner", text: "Dealer")
    expect(page).to have_css(".card__rank", exact_text: "A")
    expect(page).to have_css(".card__rank", exact_text: "K")
    expect(page).to have_no_css(".card--facedown")
    expect(page).to have_no_button("Hit")
    expect(page).to have_no_button("Stand")
  end

  it "does not show another player's table" do
    visit blackjack_session_path(0)

    expect(page).to have_text("ActiveRecord::RecordNotFound")
    expect(page).to have_no_css("h2", text: "You")
  end
end
