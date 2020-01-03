RSpec.describe Zoho::Analytics::Workspace do
  let(:name) { "Missing Workspace" }
  let(:workspace) { client.workspace(name) }

  describe "#exists?" do
    context "with existing" do
      let(:name) { "Workspace" }
      it "exists" do
        expect(workspace.exists?).to eq(true)
      end
    end

    context "with missing" do
      it "does not exist" do
        expect(workspace.exists?).to eq(false)
      end
    end
  end
end
