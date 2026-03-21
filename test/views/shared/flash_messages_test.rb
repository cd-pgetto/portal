require "test_helper"

class FlashMessagesTest < ActionView::TestCase
  MESSAGE_TYPES = {
    alert: {bg_color: "bg-error", text_color: "text-error-content"},
    notice: {bg_color: "bg-info", text_color: "text-info-content"},
    success: {bg_color: "bg-success", text_color: "text-success-content"},
    warning: {bg_color: "bg-warning", text_color: "text-warning-content"}
  }

  MESSAGE_TYPES.each do |type, styles|
    describe "when flash contains a #{type} message" do
      before {
        flash[type] = "This is a #{type} message."
        render Views::Shared::FlashMessages.new
      }

      it "displays the #{type} message with correct styles" do
        assert_select "div.#{styles[:bg_color]}"
        assert_includes rendered, "This is a #{type} message."
      end
    end
  end

  describe "when flash is empty" do
    before { render Views::Shared::FlashMessages.new }

    it "does not display any flash messages" do
      MESSAGE_TYPES.each_value do |styles|
        assert_select "div.#{styles[:bg_color]}", count: 0
      end
    end
  end
end
