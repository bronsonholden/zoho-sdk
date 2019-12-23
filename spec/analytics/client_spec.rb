RSpec.describe Zoho::Analytics::Client do
  let(:client) { Zoho::Analytics::Client.new("", "") }

  describe "#workspace_metadata" do
    it "retrieves workspace metadata" do
      # TODO: Return metadata object
      expect { client.workspace_metadata }.not_to raise_error
    end
  end
end
