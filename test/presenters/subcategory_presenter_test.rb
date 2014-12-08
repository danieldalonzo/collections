require 'test_helper'
require 'ostruct'

describe SubcategoryPresenter do

  let(:mock_response) {
    OpenStruct.new(
      title: 'VAT',
      description: 'Information about VAT for businesses',
      parent: OpenStruct.new(
        title: 'Business tax',
      ),
      details: {},
    )
  }
  let(:subcategory) {
    Subcategory.new('business-tax/vat', mock_response)
  }
  let(:presenter) {
    SubcategoryPresenter.new(subcategory)
  }

  describe '#method_missing' do
    it 'delegates other methods to the original object' do
      stub_subcategory = stub("Subcategory")
      presenter = SubcategoryPresenter.new(stub_subcategory)

      stub_subcategory.expects(:foo).returns('bar')
      assert_equal 'bar', presenter.foo
    end
  end

  describe '#part_of_links' do
    it 'returns a link to the parent slug by default' do
      output = presenter.part_of_links
      parent_link = output.first

      assert_equal 1, output.size

      assert_match /href="\/business-tax"/, parent_link
      assert_match /Business tax/, parent_link
    end

    it 'includes both the parent and subcategory slug when an option is provided' do
      output = presenter.part_of_links(include_child: true)
      child_link = output.first
      parent_link = output.last

      assert_equal 2, output.size

      assert_match /href="\/business-tax\/vat"/, child_link
      assert_match /VAT/, child_link
      assert_match /href="\/business-tax"/, parent_link
      assert_match /Business tax/, parent_link
    end
  end

end
