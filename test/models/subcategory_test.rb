require "test_helper"

def build_mock_collections_api
  stub('CollectionsApi').tap {|api|
    Collections.services(:collections_api, api)
  }
end

describe Subcategory, ".find" do
  it "finds the curated content for the given slug in the collections api" do
    slug = "oil-and-gas/wells"
    collections_api_has_content_for("/#{slug}")

    subcategory = Subcategory.find(slug)

    assert_instance_of Subcategory, subcategory
    assert subcategory.groups
    assert subcategory.changed_documents
  end

  it "returns nil if there is no content for the given slug in the collections api" do
    slug = "nothing-here"
    collections_api_has_no_content_for("/#{slug}")

    subcategory = Subcategory.find(slug)

    assert_equal nil, subcategory
  end

  it 'passes the "start" and "count" arguments to the API request' do
    mock_collections_api = stub("CollectionsApi")
    mock_response = stub("Response", title: 'Foo')
    Collections.services(:collections_api, mock_collections_api)

    mock_collections_api.expects(:topic)
                        .with('/foo', has_entries(start: 10, count: 30))
                        .returns(mock_response)

    subcategory = Subcategory.find('foo', start: 10, count: 30)

    assert_equal 'Foo', subcategory.title
  end
end

describe Subcategory, "#groups" do
  it "returns the curated content for the subcategory" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    assert_equal stubbed_response_body['details']['groups'][0]['title'], subcategory.groups.first.title
  end
end

describe Subcategory, "#changed_documents" do
  it "returns the changed documents for the subcategory" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    assert_equal stubbed_response_body['details']['documents'][0]['title'], subcategory.changed_documents.first.title
  end
end

describe Subcategory, "#description" do
  it "returns the description for the subcategory" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    assert_equal stubbed_response_body['description'], subcategory.description
  end
end

describe Subcategory, "#title" do
  it "returns the title for the subcategory" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    assert_equal stubbed_response_body['title'], subcategory.title
  end
end

describe Subcategory, "#parent_sector_title" do
  it "returns the parent sector for the subcategory" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    assert_equal stubbed_response_body['parent']['title'], subcategory.parent_sector_title
  end
end

describe Subcategory, "#combined_title" do
  it "combined the parent and child titles for added context" do
    slug = "oil-and-gas/wells"
    stubbed_response = collections_api_has_content_for("/#{slug}")
    stubbed_response_body = JSON.parse(stubbed_response.response.body)

    subcategory = Subcategory.find(slug)

    expected_combined_title = "#{stubbed_response_body['parent']['title']}: #{stubbed_response_body['title']}"
    assert_equal expected_combined_title, subcategory.combined_title
  end
end

describe Subcategory, "#slug" do
  it "returns the slug for the subcategory" do
    slug = "oil-and-gas/wells"
    collections_api_has_content_for("/#{slug}")

    subcategory = Subcategory.find(slug)

    assert_equal slug, subcategory.slug
  end
end

describe Subcategory, '#documents_total' do
  it 'returns the total number of documents for the subcategory' do
    mock_collections_api = build_mock_collections_api
    mock_response = stub("Response", details: stub('Details', documents_total: 2560))

    mock_collections_api.expects(:topic).with('/foo', {}).returns(mock_response)

    subcategory = Subcategory.find('foo')

    assert_equal 2560, subcategory.documents_total
  end
end

describe Subcategory, '#documents_start' do
  it 'returns the starting offset for the recent documents in the subcategory' do
    mock_collections_api = build_mock_collections_api
    mock_response = stub('Response', details: stub('Details', documents_start: 42))

    mock_collections_api.expects(:topic).with('/foo', {}).returns(mock_response)

    subcategory = Subcategory.find('foo')

    assert_equal 42, subcategory.documents_start
  end
end

describe Subcategory, '#parent_slug' do
  it 'returns the parent portion of the slug for the subcategory' do
    slug = 'oil-and-gas/fields-and-wells'
    collections_api_has_content_for("/#{slug}")

    subcategory = Subcategory.find(slug)

    assert_equal 'oil-and-gas', subcategory.parent_slug
  end
end

describe Subcategory, '#child_slug' do
  it 'returns the child portion of the slug for the subcategory' do
    slug = 'oil-and-gas/fields-and-wells'
    collections_api_has_content_for("/#{slug}")

    subcategory = Subcategory.find(slug)

    assert_equal 'fields-and-wells', subcategory.child_slug
  end
end
