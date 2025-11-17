class Views::Shared::FlashMessages < Components::Base
  include Phlex::Rails::Helpers::Flash

  MESSAGE_STYLES = {
    alert: {bg_color: "bg-error", text_color: "text-error-content", icon: PhlexIcons::Lucide::CircleAlert},
    notice: {bg_color: "bg-info", text_color: "text-info-content", icon: PhlexIcons::Lucide::Info},
    success: {bg_color: "bg-success", text_color: "text-success-content", icon: PhlexIcons::Lucide::CircleCheck},
    warning: {bg_color: "bg-warning", text_color: "text-warning-content", icon: PhlexIcons::Lucide::TriangleAlert}
  }

  def view_template
    turbo_frame_tag "flash_messages" do
      MESSAGE_STYLES.keys.each do |type|
        render_message(type)
      end
    end
  end

  private

  def render_message(type)
    return if (message = flash[type]).blank?

    div(class: "#{bg_color_for(type)} px-6 py-4 mt-4 rounded-md flex gap-x-2 items-center mx-auto w-3/4 xl:w-2/4") do
      render icon_component_class(type).new(class: ["icon-#{type} size-6", text_color_for(type)])
      span(class: text_color_for(type)) { message }
    end
  end

  def bg_color_for(type) = MESSAGE_STYLES[type][:bg_color]
  def icon_color_for(type) = MESSAGE_STYLES[type][:icon_color]
  def text_color_for(type) = MESSAGE_STYLES[type][:text_color]
  def icon_component_class(type) = MESSAGE_STYLES[type][:icon]
end
