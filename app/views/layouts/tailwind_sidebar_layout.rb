class Views::Layouts::SideNavBar < Views::Base
  def view_template
    # Static sidebar for desktop
    div(class: "hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col dark:bg-gray-900 transition-all duration-300", data_controller: "sidebar", data_sidebar_target: "container") do
      desktop_sidebar
    end

    # Mobile top bar
    mobile_top_bar
  end

  private

  def desktop_sidebar
    # div(class: "flex grow flex-col gap-y-5 overflow-y-auto border-r border-base-300 bg-white px-6 dark:border-white/10 dark:bg-black/10") do
    div(class: "flex grow flex-col gap-y-1 overflow-y-auto border-r border-base-300 bg-white px-6") do
      logo_section
      navigation_section
    end
  end

  def logo_section
    div(class: "flex h-12 pt-3 shrink-0") do
      button(
        type: "button",
        data_action: "click->sidebar#toggle",
        class: "text-xl text-primary hover:opacity-80 transition-opacity"
      ) do
        svg(class: "h-8 w-auto", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 822.2 1000", fill: "currentColor") do |s|
          s.path(d: "M411.6,0C184.3,0,0,184.2,0,411.5c0,149.7,79.9,280.7,199.5,352.7H0v235.1h235.2v-216
          c53.5,25.4,113.3,39.6,176.4,39.6c227.3,0,411.6-184.2,411.6-411.5S638.9,0,411.6,0z
          M411.6,646.6c-129.9,0-235.2-105.3-235.2-235.1
          s105.3-235.1,235.2-235.1s235.2,105.3,235.2,235.1S541.5,646.6,411.6,646.6z")
        end
      end
    end
  end

  def navigation_section
    nav(class: "flex flex-1 flex-col", data_sidebar_target: "nav") do
      ul(role: "list", class: "flex flex-1 flex-col gap-y-7") do
        li do
          ul(role: "list", class: "flex flex-1 flex-col gap-y-7") do
            li { main_navigation_items }
            li { teams_section }
          end
        end
        li(class: "-mx-6 mt-auto") { user_profile_link }
      end
    end
  end

  def main_navigation_items
    ul(role: "list", class: "-mx-2 space-y-1") do
      nav_item("Dashboard", :home, active: true)
      nav_item("Team", :users)
      nav_item("Projects", :folder)
      nav_item("Calendar", :calendar)
      nav_item("Documents", :document)
      nav_item("Reports", :chart)
    end
  end

  def nav_item(label, icon, active: false)
    li do
      a(
        href: "#",
        class: nav_item_classes(active)
      ) do
        render_icon(icon, active)
        plain label
      end
    end
  end

  def nav_item_classes(active)
    if active
      "group flex gap-x-3 rounded-md bg-base-300 p-2 text-sm/6 font-medium text-primary dark:bg-white/5 dark:text-primary"
    else
      "group flex gap-x-3 rounded-md p-2 text-sm/6 font-medium text-gray-700 hover:bg-base-300 hover:text-primary dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-primary"
    end
  end

  def render_icon(icon_name, active)
    icon_class = if active
      "size-6 shrink-0 text-primary dark:text-primary"
    else
      "size-6 shrink-0 text-gray-400 group-hover:text-primary dark:group-hover:text-primary"
    end

    svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", data_slot: "icon", aria_hidden: "true", class: icon_class) do |s|
      icon_paths(s, icon_name)
    end
  end

  def icon_paths(svg, icon_name)
    case icon_name
    when :home
      svg.path(d: "m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25", stroke_linecap: "round", stroke_linejoin: "round")
    when :users
      svg.path(d: "M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z", stroke_linecap: "round", stroke_linejoin: "round")
    when :folder
      svg.path(d: "M2.25 12.75V12A2.25 2.25 0 0 1 4.5 9.75h15A2.25 2.25 0 0 1 21.75 12v.75m-8.69-6.44-2.12-2.12a1.5 1.5 0 0 0-1.061-.44H4.5A2.25 2.25 0 0 0 2.25 6v12a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9a2.25 2.25 0 0 0-2.25-2.25h-5.379a1.5 1.5 0 0 1-1.06-.44Z", stroke_linecap: "round", stroke_linejoin: "round")
    when :calendar
      svg.path(d: "M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5", stroke_linecap: "round", stroke_linejoin: "round")
    when :document
      svg.path(d: "M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75", stroke_linecap: "round", stroke_linejoin: "round")
    when :chart
      svg.path(d: "M10.5 6a7.5 7.5 0 1 0 7.5 7.5h-7.5V6Z", stroke_linecap: "round", stroke_linejoin: "round")
      svg.path(d: "M13.5 10.5H21A7.5 7.5 0 0 0 13.5 3v7.5Z", stroke_linecap: "round", stroke_linejoin: "round")
    end
  end

  def teams_section
    div(class: "text-xs/6 font-semibold text-gray-400") { "Your teams" }
    ul(role: "list", class: "-mx-2 mt-2 space-y-1") do
      team_item("Heroicons", "H")
      team_item("Tailwind Labs", "T")
      team_item("Workcation", "W")
    end
  end

  def team_item(name, initial)
    li do
      a(
        href: "#",
        class: "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold text-gray-700 hover:bg-base-300 hover:text-primary dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
      ) do
        span(class: "flex size-6 shrink-0 items-center justify-center rounded-lg border border-gray-200 bg-white text-[0.625rem] font-medium text-gray-400 group-hover:border-primary group-hover:text-primary dark:border-white/10 dark:bg-white/5 dark:group-hover:border-white/20 dark:group-hover:text-white") do
          plain initial
        end
        span(class: "truncate") { name }
      end
    end
  end

  def user_profile_link
    a(
      href: "#",
      class: "flex items-center gap-x-4 px-6 py-3 text-sm/6 font-semibold text-gray-900 hover:bg-base-300 dark:text-white dark:hover:bg-white/5"
    ) do
      img(
        src: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
        alt: "",
        class: "size-8 rounded-full bg-base-300 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
      )
      span(class: "sr-only") { "Your profile" }
      span(aria_hidden: "true") { "Tom Cook" }
    end
  end

  def mobile_top_bar
    div(class: "sticky top-0 z-40 flex items-center gap-x-6 bg-white px-4 py-4 shadow-xs sm:px-6 lg:hidden dark:bg-gray-900 dark:shadow-none dark:after:pointer-events-none dark:after:absolute dark:after:inset-0 dark:after:border-b dark:after:border-white/10 dark:after:bg-black/10") do
      button(
        type: "button",
        command: "show-modal",
        commandfor: "sidebar",
        class: "-m-2.5 p-2.5 text-gray-700 hover:text-gray-900 lg:hidden dark:text-gray-400 dark:hover:text-white"
      ) do
        span(class: "sr-only") { "Open sidebar" }
        svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.5", data_slot: "icon", aria_hidden: "true", class: "size-6") do |s|
          s.path(d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5", stroke_linecap: "round", stroke_linejoin: "round")
        end
      end
      div(class: "flex-1 text-sm/6 font-semibold text-gray-900 dark:text-white") { "Dashboard" }
      a(href: "#") do
        span(class: "sr-only") { "Your profile" }
        img(
          src: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
          alt: "",
          class: "size-8 rounded-full bg-base-300 outline -outline-offset-1 outline-black/5 dark:bg-gray-800 dark:outline-white/10"
        )
      end
    end
  end
end
