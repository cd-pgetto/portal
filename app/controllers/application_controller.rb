class ApplicationController < ActionController::Base
  include Authentication
  include Authorization

  before_action :set_current_practice

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def set_current_practice
    if cookies.signed[:practice_id]
      Current.practice = Current.user&.practices&.find_by(id: cookies.signed[:practice_id])
      cookies.delete(:practice_id) unless Current.practice
    elsif Current.user&.practices&.any?
      select_current_practice(Current.user.practices.first)
    end
  end

  def select_current_practice(practice)
    cookies.signed.permanent[:practice_id] = {value: practice.id, httponly: true, same_site: :lax}
    Current.practice = practice
  end
end
