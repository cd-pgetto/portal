require "rails_helper"

RSpec.describe Admin::PracticesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/organizations/1/practices").to route_to("admin/practices#index", organization_id: "1")
    end

    it "routes to #new" do
      expect(get: "/admin/organizations/1/practices/new").to route_to("admin/practices#new", organization_id: "1")
    end

    it "routes to #show" do
      expect(get: "/admin/organizations/1/practices/1").to route_to("admin/practices#show", organization_id: "1", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/organizations/1/practices/1/edit").to route_to("admin/practices#edit", organization_id: "1", id: "1")
    end

    it "routes to #create" do
      expect(post: "/admin/organizations/1/practices").to route_to("admin/practices#create", organization_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/organizations/1/practices/1").to route_to("admin/practices#update", organization_id: "1", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/organizations/1/practices/1").to route_to("admin/practices#update", organization_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/organizations/1/practices/1").to route_to("admin/practices#destroy", organization_id: "1", id: "1")
    end
  end
end
