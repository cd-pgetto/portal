module DomainName
  # URI::MailTo::EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

  # extracted from: URI::MailTo::EMAIL_REGEXP
  DNS_LABEL_REGEXP = /[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?/
  SUBDOMAIN_REGEXP = /\A#{DNS_LABEL_REGEXP}\z/
  FULL_DOMAIN_REGEXP = /\A#{DNS_LABEL_REGEXP}(?:\.#{DNS_LABEL_REGEXP})*\z/
end
