# Portal To Do List

## Migrate stuff from older versions of the app
## Move GH repo to Cyberdontics

## General

- [ ] Implement missing tests
      - [ ] Views
            - [ ] Admin/Identity Provider
            - [ ] Home
            - [X] Layouts
                  - [X] Navbar
            - [ ] Passwords
            - [ ] Passwords Mailer
            - [X] Sessions
            - [X] Shared
      - [ ] Models
            - [ ] Current
            - [ ] Authenticable concern
            - [ ] DomainName
            - [ ] Lockable
      - [ ] Controller concerns
            - [ ] Authentication
            - [ ] Authorization

## Sign Up / Sign In

- [X] Check / prevent sign ups using email addresses associated with organizations with require authentication via Oauth
- [X] Sign up's using shared Oauth providers
- [X] Review / clean up Claude code in Oath callback (Identity) controller
- [X] Adjust sign in page to split into two steps, first gets the email address. If the user is recognied and associated
      with an Organization required Oauth, use that. If the user has associated identities show them, possibly with
      the option to use a password if not prohibited by an associated Organization. If no existing user is found, or there
      no associated Oauth identities, show password field.
- [X] Improve test coverage for new sessions to cover all organization rules (pw allowed/denied, IdPs, etc)
- [ ] Implement 2FA, add as optional requirement for Org's
- [ ] Implement Lockout based on too many failed attempts
- [ ] Add identity providers - [ ] Apple, [ ] Auth0(?), [X] Google, [ ] Microsoft, [ ] Okta, [ ] OneLogin(?)

## Admin Pages / Users

- [X] Refactor Perceptive model
- [X] Add link for Dashboard to the side nav bar
- [ ] Add link for Users to the side nav bar
- [ ] Add link for Practices to the side nav bar
- [X] Add "stat" for Identity Providers
- [ ] Update IDP index page to table
- [ ] Update Org show page to list email domains and improve layout (look at IDP index page for layout details?)
- [ ] Add User index, show, edit, etc pages


## Practice and patients

- [ ] Implement practice and role model
- [ ] Practice admin, including invitations, changing roles, etc.
- [ ] Implement patient and subordinate models (scan, diagnostic model, jaw, tooth, findings, etc)
- [ ] Implement scan data models
- [ ] Implement 3 js viewer for models

## DevOps

- [ ] Set up hosting and deploy (AWS, Render, ???); Kamal?
