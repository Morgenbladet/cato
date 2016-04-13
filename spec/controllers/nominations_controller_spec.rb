require "rails_helper"

RSpec.describe NominationsController do
  context "as non-admin" do
    it("has no current user") { expect(controller.current_user).to be_nil }

    context "GET index" do
      let!(:approved) { create :nomination_with_reasons, verified: true }
      let!(:unapproved) { create :nomination_with_reasons, verified: false }

      before do
        get :index
      end

      it("is allowed") { expect(response).to be_success }
      it("renders the template") { expect(response).to render_template('index') }
      it("returns (only) approved nominations") do
        expect(assigns(:nominations)).to eq([approved])
      end
    end

    context "POST create" do
      context "with good data" do
        let(:institution) { create :institution }
        let(:data) { attributes_for(:nomination,
                                    institution_id: institution.id,
                                    reasons_attributes: [ attributes_for(:reason) ]) }

        it "creates a nominiation" do
          expect do
            post :create, nomination: data
          end.to change(Nomination, :count).by(1)
        end

        it "creates a reason" do
          expect do
            post :create, nomination: data
          end.to change(Reason, :count).by(1)
        end
      end

      context "with verified=true" do
        let(:institution) { create :institution }
        let(:data) { attributes_for :nomination_with_reasons,
                     institution_id: institution.id,
                     reasons_count: 1,
                     verified: true }

        it "creates a nominiation" do
          expect do
            post :create, nomination: data
          end.to change(Nomination, :count).by(1)
        end

        it "filters the verified parameter" do
          xhr :post, :create, nomination: data, format: :json
          expect(response).to have_http_status(:created)
          expect(assigns[:nomination]).to_not be_verified
        end
      end

      context "with bad data" do
        let(:data) { {evil: 'hacker', id: 4, verified: true } }

        it "creates no nomination" do
          expect do
            post :create, nomination: data
          end.to_not change(Nomination, :count)
        end

        it "returns an error status code" do
          xhr :post, :create, nomination: data, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "PATCH update" do
      let(:nomination) { create :nomination, :approved }

      before do
        n = nomination
        n.name = "Testing"
      end


      it "disallows updates through xhr" do
        xhr :patch,
          :update,
          id: nomination.id,
          nomination: nomination.attributes,
          format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it "does not update the record" do
        patch :update, id: nomination.id, nomination: nomination.attributes
        expect(Nomination.find(nomination.id).name).to_not eq("Testing")
      end
    end

    context "POST verify_all" do
      let!(:nomination) { create :nomination }
      it "has one unapproved nomination" do
        expect(Nomination.count).to eq(1)
        expect(Nomination.verified.count).to eq(0)
      end

      it "does not change the verified status" do
        post :verify_all
        expect(nomination.reload).to_not be_verified
      end

      it "shows an error message" do
        post :verify_all
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  context "logged in" do
    let(:user) { create :user }

    before do
      sign_in user
    end

    context "POST verify_all" do
      let!(:nom1) { create :nomination_with_reasons }
      let!(:nom2) { create :nomination_with_reasons }
      let!(:nom3) { create :nomination, :approved }

      it "has two unverified before posting" do
        expect(Nomination.count-Nomination.verified.count).to eq(2)
      end

      it "has three verified and zero unverified after posting" do
        post :verify_all
        expect(Nomination.count).to eq(3)
        expect(Nomination.verified.count).to eq(3)
      end
    end
  end
end
