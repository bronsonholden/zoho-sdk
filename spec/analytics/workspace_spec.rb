RSpec.describe ZohoSdk::Analytics::Workspace do
  let(:name) { "Workspace" }
  let(:workspace) { client.workspace(name) }

  context "existing" do
    it "exists" do
      expect(workspace).not_to be_nil
    end
  end

  context "missing" do
    let(:name) { "Missing Workspace" }
    it "does not exist" do
      expect(workspace).to be_nil
    end
  end
end
