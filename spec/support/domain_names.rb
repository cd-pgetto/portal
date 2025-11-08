module DomainNames
  VALID_SUBDOMAIN_NAMES = %w[foo bar baz foo0 0foo f0o a 1 A a0 A0 f-oo f-o-o A-0c 0--0]
  VALID_FULL_DOMAIN_NAMES = %w[
    foo.com foo.bar.org foo.jp 01010.com A0c.com A-0c.com
    o12345670123456701234567012345670123456701234567012345670123456.com a.co 0--0.org
  ]
  VALID_USERNAMES = %w[user THE_USER first.last user+tag user_tag user-tag user.tag user_tag-tag user.tag.tag user_tag.tag-tag]
  VALID_FULL_EMAIL_ADDRESSES = VALID_USERNAMES.product(VALID_FULL_DOMAIN_NAMES).map { |u, d| "#{u}@#{d}" }

  INVALID_SUBDOMAIN_NAMES_SUBLIST = %w[
    A0c- -A0c A0c\nA0c - 123- -456 -example- example_test example@test example#test
    example$test example%test example&test example*test example+test example=test example!test
    example?test example/test example\test example|test example<test example>test example:test
    example;test example,test o123456701234567012345670123456701234567012345670123456701234567
  ]
  INVALID_SUBDOMAIN_NAMES = ["", "example test", "foo.com", "foo,com", "foo.", ".com", ".foo.bar"] + INVALID_SUBDOMAIN_NAMES_SUBLIST
  INVALID_FULL_DOMAIN_NAMES = INVALID_SUBDOMAIN_NAMES_SUBLIST.map { |d| d + ".com" } +
    ["foo,com", "foo.", ".com", ".foo.bar", ".", "..", "http://example.com", "https://example.com", "example.com/path"]
  INVALID_FULL_EMAIL_ADDRESSES = INVALID_FULL_DOMAIN_NAMES.map { |d| "user@#{d}" } + %w[user_at_foo.org]
end
