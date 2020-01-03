RSpec.describe Zoho::Analytics::Workspace do
  let(:workspace) { client.workspace("Workspace") }

  describe "#exists?" do
    it "returns true for existing workspace" do
      expect(workspace.exists?).to eq(true)
    end
  end
end
