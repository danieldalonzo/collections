class SubcategoryPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def initialize(subcategory)
    @subcategory = subcategory
  end

  def part_of_links(include_child: false)
    parent_link = link_to(subcategory.parent_sector_title,
                          sector_path(subcategory.parent_slug))

    child_link = link_to(subcategory.title, subcategory_path(
                                              subcategory.parent_slug,
                                              subcategory.child_slug))

    if include_child
      [child_link, parent_link]
    else
      [parent_link]
    end
  end

private

  attr_reader :subcategory, :view_context

  def method_missing(method, *args, &block)
    if subcategory.respond_to?(method)
      subcategory.send(method, *args, &block)
    else
      super
    end
  end

end
