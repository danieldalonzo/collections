require_relative '../test_helper'

describe SpecialistSectorsController do

  describe "GET sector with a valid sector tag" do
    before do
      subcategories = [
        { slug: "oil-and-gas/wells", title: "Wells" },
      ]

      content_api_has_tag("specialist_sector", { slug: "oil-and-gas", title: "Oil and Gas", description: "Guidance for the oil and gas industry" })
      content_api_has_sorted_child_tags("specialist_sector", "oil-and-gas", "alphabetical", subcategories)
    end

    it "requests a tag from the Content API and assign it" do
      get :show, sector: "oil-and-gas"

      assert_equal "Oil and Gas", assigns(:sector).title
      assert_equal "Guidance for the oil and gas industry", assigns(:sector).description
    end

    it "sets the correct slimmer headers" do
      get :show, sector: "oil-and-gas"

      assert_equal "specialist-sector", response.headers["X-Slimmer-Format"]
    end

    it "sets expiry headers for 30 minutes" do
      get :show, sector: "oil-and-gas"

      assert_equal "max-age=1800, public",  response.headers["Cache-Control"]
    end
  end

  it "returns a 404 status for GET sector with an invalid sector tag" do
    api_returns_404_for("/tags/specialist_sector/oil-and-gas.json")
    get :show, sector: "oil-and-gas"

    assert_equal 404, response.status
  end

  describe "invalid slugs" do
    it "returns a cacheable 404 without calling content_api if the sector slug is invalid" do
      get :show, sector: "this & that"

      assert_equal "404", response.code
      assert_equal "max-age=600, public",  response.headers["Cache-Control"]
      assert_not_requested(:get, %r{\A#{GdsApi::TestHelpers::ContentApi::CONTENT_API_ENDPOINT}})
    end
  end
end
