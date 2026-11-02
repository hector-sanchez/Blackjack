# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Playing blackjack", type: :system do
  before { driven_by :chrome_visible }

  it "lets a player deal and finish a round from the browser" do
    visit root_path
    click_button "Deal"

    expect(page).to have_css("h2", text: "Dealer")
    expect(page).to have_css("h2", text: "You")

    if page.has_button?("Stand", wait: 0)
      expect(page).to have_css(".card--facedown")
      click_button "Stand"
    end

    expect(page).to have_css(".banner", text: /You win|Dealer wins|Push/)
    expect(page).to have_button("Deal again")
  end
end
