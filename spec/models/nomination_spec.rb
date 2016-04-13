require "rails_helper"
require "cancan/matchers"

RSpec.describe Nomination, type: :model do
  describe "abilities" do
    subject(:ability) { Ability.new(user) }
    let(:user)        { nil }

    context "when an admin" do
      let(:user) { create :user }
    end

    context "when not an admin" do
      it "can create a nomination" do
        expect(ability).to be_able_to(:create, Nomination.new)
      end

      it "can't update a nomination" do
        nomination = create :nomination
        expect(ability).to_not be_able_to(:update, nomination)
      end

      it "can't delete a nomination" do
        nomination = create :nomination
        expect(ability).to_not be_able_to(:destroy, nomination)
      end

      describe "read access" do
        let(:unverified) { create :nomination_with_reasons }
        let(:verified) do
          n = create :nomination_with_reasons
          n.reasons << create(:reason, verified: true, nomination: n)
          n
        end

        it "can't read one with no verified reasons" do
          expect(ability).to_not be_able_to(:read, unverified)
        end

        it "can read one with a verified reason" do
          expect(ability).to be_able_to(:read, verified)
        end
      end
    end
  end
end
