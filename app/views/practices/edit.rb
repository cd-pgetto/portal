class Views::Practices::Edit < Views::Base
  def initialize(practice:)
    @practice = practice
  end

  def view_template
    content_for :title, "Edit #{@practice.name}"

    div(class: "max-w-2xl mx-auto px-4 py-8 space-y-8") do
      section_card("Practice Name") do
        form_with model: @practice, url: practice_path(@practice) do |f|
          div(class: "flex gap-4 items-end") do
            div(class: "fieldset flex-1") do
              f.label :name, "Name", class: "fieldset-legend"
              f.text_field :name, class: "input w-full", required: true
            end
            f.submit "Save", class: "btn btn-primary"
          end
        end
      end

      section_card("Members") do
        members_by_user = @practice.members.includes(:user).group_by(&:user)
          .sort_by { |user, _| [user.last_name, user.first_name] }
        if members_by_user.any?
          table(class: "table table-sm") do
            thead {
              tr {
                th { "Member" }
                th { "Roles" }
              }
            }
            tbody do
              members_by_user.each do |user, memberships|
                existing_roles = memberships.map(&:role)
                remaining_roles = sorted_roles - existing_roles
                tr do
                  td(class: "align-top font-medium pt-3") { user.full_name }
                  td do
                    div(class: "flex items-center justify-between gap-2") do
                      div(class: "flex flex-wrap items-center gap-2") do
                        memberships.each do |membership|
                          div(class: "flex items-center gap-1") do
                            span(class: "badge badge-neutral") { membership.role.humanize }
                            button_to practice_membership_path(@practice, membership), method: :delete,
                              class: "btn btn-xs btn-circle btn-ghost btn-error",
                              form: {data: {turbo_confirm: "Remove #{membership.role.humanize} role from #{user.full_name}?"}} do
                              "×"
                            end
                          end
                        end
                      end
                      if remaining_roles.any?
                        form_with url: practice_memberships_path(@practice), method: :post, class: "flex items-center gap-1" do |f|
                          f.hidden_field :email_address, value: user.email_address, name: "practice_member[email_address]"
                          f.select :role, remaining_roles.map { |r| [r.humanize, r] },
                            {}, name: "practice_member[role]", class: "select select-xs"
                          f.submit "Add", class: "btn btn-xs btn-outline"
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        else
          p(class: "text-sm text-base-content/60") { "No members yet." }
        end
      end

      pending_invitations = @practice.invitations.pending.includes(:invited_by)
      if pending_invitations.any?
        section_card("Pending Invitations") do
          table(class: "table table-sm") do
            thead {
              tr {
                th { "Email" }
                th { "Role" }
                th { "Invited by" }
                th {}
              }
            }
            tbody do
              pending_invitations.each do |invitation|
                tr do
                  td { invitation.email }
                  td { invitation.role.humanize }
                  td { invitation.invited_by.full_name }
                  td(class: "text-right") do
                    button_to practice_invitation_path(@practice, invitation), method: :delete,
                      class: "btn btn-xs btn-ghost btn-error",
                      form: {data: {turbo_confirm: "Cancel invitation to #{invitation.email}?"}} do
                      "Cancel"
                    end
                  end
                end
              end
            end
          end
        end
      end

      section_card("Invite User") do
        new_invitation = @practice.invitations.build
        form_with model: [:practice, new_invitation],
          url: practice_invitations_path(@practice) do |f|
          div(class: "grid grid-cols-2 gap-4") do
            div(class: "fieldset") do
              f.label :email, "Email address", class: "fieldset-legend"
              f.email_field :email, class: "input w-full", placeholder: "user@example.com", required: true
            end
            div(class: "fieldset") do
              f.label :role, "Role", class: "fieldset-legend"
              f.select :role, PracticeMember::REGULAR_ROLES.sort.map { |r| [r.humanize, r] },
                {}, class: "select w-full"
            end
          end
          f.submit "Send Invitation", class: "btn btn-primary mt-4"
        end
      end
    end
  end

  private

  def sorted_roles
    PracticeMember::REGULAR_ROLES.sort + PracticeMember::PRIVILEGED_ROLES
  end

  def section_card(title)
    div(class: "card bg-base-100 border border-base-300") do
      div(class: "card-body") do
        h2(class: "card-title text-lg") { title }
        yield
      end
    end
  end
end
