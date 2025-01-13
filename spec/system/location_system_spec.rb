require "rails_helper"

RSpec.describe "Location management", type: :system do
  it "enables me to create locations" do
    visit "/locations/new"

    fill_in "City", :with => "Apex"
    fill_in "Country", :with => "US"
    click_button "Create Location"

    expect(page).to have_text("Apex")
  end

  it "disables me from creating incomplete locations" do
    visit "/locations/new"

    fill_in "City", :with => "Apex"
    click_button "Create Location"

    expect(page).to have_text("Country can't be blank")
  end

  it "enables me to view locations" do
    visit "/locations/1"

    expect(page).to have_text("Back to Locations")
  end
end