class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::SharedTemplates

  protect_from_forgery with: :exception

  before_filter :set_expiry
  before_filter :set_slimmer_template

  before_filter :restrict_request_formats

  # Allows additional request formats to be enabled.
  #
  # By default, PublicFacingController actions will only respond to HTML requests. To enable
  # additional formats on any given action, use this helper method. For example:
  #
  #   enable_request_formats index: [:atom, :json]
  #
  # That would allow both atom and JSON requests for the :index action to be processed.
  #
  def self.enable_request_formats(options)
    options.each do |action, formats|
      self.acceptable_formats[action.to_sym] ||= Set.new
      self.acceptable_formats[action.to_sym] += Array(formats)
    end
  end

  def self.acceptable_formats
    @acceptable_formats ||= {}
  end

  private

  def restrict_request_formats
    unless can_handle_format?(request.format)
      render status: :not_acceptable, text: "Request format #{request.format} not handled."
    end
  end

  def can_handle_format?(format)
    return true if format == Mime::HTML || format == Mime::ALL
    format && self.class.acceptable_formats.fetch(params[:action].to_sym, []).include?(format.to_sym)
  end

  def set_slimmer_template
    set_slimmer_headers(template: 'header_footer_only')
  end

  def error_404; error 404; end
  def error_410; error 410; end
  def error_503(e); error(503, e); end

  def error(status_code, exception = nil)
    Airbrake.notify_or_ignore(exception) if exception
    render status: status_code, text: "#{status_code} error"
  end

  def cacheable_404
    set_expiry(10.minutes)
    error 404
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, :public => true)
    end
  end

  def validate_slug_param(param_name = :slug)
    param_to_use = params[param_name]
    if param_to_use.parameterize != param_to_use
      cacheable_404
    end
  rescue StandardError # Triggered by trying to parameterize malformed UTF-8
    cacheable_404
  end
end
