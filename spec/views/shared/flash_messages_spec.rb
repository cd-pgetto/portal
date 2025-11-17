require "rails_helper"

MESSAGE_TYPES = {
  alert: {bg_color: "bg-error", text_color: "text-error-content", icon: PhlexIcons::Lucide::CircleAlert},
  notice: {bg_color: "bg-info", text_color: "text-info-content", icon: PhlexIcons::Lucide::Info},
  success: {bg_color: "bg-success", text_color: "text-success-content", icon: PhlexIcons::Lucide::CircleCheck},
  warning: {bg_color: "bg-warning", text_color: "text-warning-content", icon: PhlexIcons::Lucide::TriangleAlert}
}

RSpec.describe "shared/flash_messages", type: :view do
  MESSAGE_TYPES.each do |type, styles|
    context "when flash contains a #{type} message" do
      let(:message_text) { "This is a #{type} message." }

      before do
        flash[type] = message_text
        render Views::Shared::FlashMessages.new
      end

      it "displays the #{type} message with correct styles and icon" do
        expect(rendered).to have_selector("div.#{styles[:bg_color]}") do |div|
          expect(div).to have_selector("span.#{styles[:text_color]}", text: message_text)
          expect(div).to have_selector("svg.icon-#{type}.#{styles[:text_color]}")
        end
      end
    end
  end

  context "when flash is empty" do
    before do
      render Views::Shared::FlashMessages.new
    end

    it "does not display any flash messages" do
      MESSAGE_TYPES.keys.each do |type|
        expect(rendered).not_to have_selector("div.#{MESSAGE_TYPES[type][:bg_color]}")
      end
    end
  end
end
