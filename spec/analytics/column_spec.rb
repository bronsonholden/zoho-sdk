RSpec.describe Zoho::Analytics::Column do
  let(:workspace) { client.workspace("Workspace") }
  let(:table) { workspace.table("Table") }
  let(:column) { table.column("Column") }

  describe "#new" do
    shared_examples "valid column" do
      it "does not raise error" do
        expect { column.create type: type }.not_to raise_error
      end
    end

    shared_examples "invalid column" do
      it "raises error" do
        expect { column.create type: type }.to raise_error(ArgumentError)
      end
    end

    Zoho::Analytics::Column::DATA_TYPES.each { |type|
      context "with #{type} type" do
        let(:type) { type }
        include_examples "valid column"
      end
    }

    context "with invalid type" do
      let(:type) { :not_a_type }
      include_examples "invalid column"
    end
  end
end
