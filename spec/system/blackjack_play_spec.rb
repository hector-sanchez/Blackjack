# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Playing blackjack", type: :system do
  def deal(*ranks)
    stub_shoe(*ranks)

    visit root_path
    click_button "Deal"
  end

  it "plays a full round: hole card hidden, hit persists, stand reveals the winner" do
    deal(10, 9, 7, 6, 4, "K", 10, 8, 5, 2)

    expect(page).to have_css("h2", text: "You")
    expect(page).to have_css(".card--facedown")
    expect(page).to have_no_css(".card__rank", exact_text: "6")

    click_button "Hit"

    expect(page).to have_css(".card__rank", exact_text: "4")
    expect(page).to have_css(".card--facedown")

    click_button "Stand"

    expect(page).to have_css(".banner", text: "You win")
    expect(page).to have_css(".seat--winner", text: "You")
    expect(page).to have_css(".card__rank", exact_text: "6")
    expect(page).to have_no_css(".card--facedown")
    expect(page).to have_no_button("Hit")
    expect(page).to have_button("Deal again")
    expect(page).to have_css(".totals__wins", text: "1")

    click_button "Deal again"

    expect(page).to have_css(".card--facedown")
    expect(page).to have_no_css(".banner")
    expect(page).to have_css(".card__rank", exact_text: "10")
    expect(page).to have_css(".card__rank", exact_text: "5")
    expect(page).to have_no_css(".card__rank", exact_text: "2")
    expect(page).to have_css(".totals__wins", text: "1")
  end

  it "announces a dealer blackjack without a face-down card" do
    deal(10, "A", 9, "K")

    expect(page).to have_css(".banner", text: "Dealer wins")
    expect(page).to have_css(".seat--winner", text: "Dealer")
    expect(page).to have_no_css(".card--facedown")
    expect(page).to have_no_button("Hit")
  end

  it "starts a new sitting from New game and resets totals" do
    deal("A", 9, "K", 7)

    expect(page).to have_css(".banner", text: "You win")
    expect(page).to have_css(".totals__wins", text: "1")
    expect(page).to have_button("Deal again")
    expect(page).to have_button("New game")
    first_path = page.current_path

    stub_shoe(10, 9, 7, 6)
    click_button "New game"

    expect(page).not_to have_current_path(first_path)
    expect(page).to have_css(".card--facedown")
    expect(page).to have_no_css(".banner")
    expect(page).to have_css(".card__rank", exact_text: "10")
    expect(page).to have_css(".card__rank", exact_text: "7")
    expect(page).to have_css(".totals__wins", text: "0")
    expect(page).to have_css(".totals__losses", text: "0")
  end
end
