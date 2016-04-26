require 'rails_helper'

RSpec.describe Api::NominationsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #random" do
    it "returns http success" do
      get :random
      expect(response).to have_http_status(:success)
    end
  end

end
