require 'test/unit'
require 'uri/component/userinfo'

UCUI = URI::Component::UserInfo

module URI
module Component

class TestUserInfoClass < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_parse
    i = UCUI.new()
    assert_nil(i.to_uri)
    assert_nil(i.domain)
    assert_nil(i.user)
    assert_nil(i.password)

    i_uri = 'user%20name'
    i = UCUI.new(i_uri)
    assert_equal(i_uri, i.to_uri)
    assert_nil(i.domain)
    assert_equal('user name', i.user)
    assert_nil(i.password)

    i_uri = 'user%20name:p%40ssword'
    i = UCUI.new(i_uri)
    assert_equal(i_uri, i.to_uri)
    assert_nil(i.domain)
    assert_equal('user name', i.user)
    assert_equal('p@ssword', i.password)

    i_uri = 'domain%20name;user%20name'
    i = UCUI.new(i_uri)
    assert_equal(i_uri, i.to_uri)
    assert_equal('domain name', i.domain)
    assert_equal('user name', i.user)
    assert_nil(i.password)

    i_uri = 'domain%20name;user%20name:p%40ssword'
    i = UCUI.new(i_uri)
    assert_equal(i_uri, i.to_uri)
    assert_equal('domain name', i.domain)
    assert_equal('user name', i.user)
    assert_equal('p@ssword', i.password)

    %w(foo/bar1 foo@bar2 foo?bar3 foo:bar:baz4 foo;bar;baz5).each do |info_str|
      assert_raise(URI::InvalidURIError) do
	UCUI.new(info_str)
	raise info_str
      end
    end
  end

  def test_modify
    i = UCUI.new('domain%5Fname;user%20name:p%40ssword')

    i.domain = 'domain2'
    assert_equal('domain2', i.domain)
    assert_equal('domain2;user%20name:p%40ssword', i.to_uri)
    i.domain = nil
    assert_nil(i.domain)
    assert_equal('user%20name:p%40ssword', i.to_uri)

    i.password = 'password2'
    assert_equal('password2', i.password)
    assert_equal('user%20name:password2', i.to_uri)
    i.password = nil
    assert_nil(i.password)
    assert_equal('user%20name', i.to_uri)

    i.domain = 'domain %20_3'
    assert_equal('domain %20_3', i.domain)
    assert_equal('domain%20%2520_3;user%20name', i.to_uri)

    i.password = 'password %20_3'
    assert_equal('password %20_3', i.password)
    assert_equal('domain%20%2520_3;user%20name:password%20%2520_3', i.to_uri)

    i.user = 'user2'
    assert_equal('user2', i.user)
    assert_equal('domain%20%2520_3;user2:password%20%2520_3', i.to_uri)
    i.user = nil
    assert_nil(i.user)
    assert_nil(i.to_uri)

    assert_raise(URI::InvalidURIError) do
      i.domain = 'domain4'
    end
    assert_raise(URI::InvalidURIError) do
      i.password = 'password4'
    end

    i.user = 'user %20_3'
    assert_equal('user %20_3', i.user)
    assert_equal('user%20%2520_3', i.to_uri)
  end

  def test_mixin
    UCUI.mixin(URI::HTTPS)

    u_uri = 'https://user%20name:p%40ssword@example.jp/'
    u = URI.parse(u_uri)
    i = u.userinfo_component
    assert_kind_of(UCUI, i)
    assert_equal('user%20name:p%40ssword', u.userinfo)
    assert_equal('user%20name', u.user)
    assert_equal('user name', i.user)
    assert_equal('p%40ssword', u.password)
    assert_equal('p@ssword', i.password)
    assert_nil(i.domain)

    u.user = 'user%2Fname'
    assert_equal('user%2Fname:p%40ssword', u.userinfo)
    assert_equal('user%2Fname', u.user)
    assert_equal('user/name', i.user)
    assert_nil(i.domain)

    u.password = 'pass%2Fword'
    assert_equal('user%2Fname:pass%2Fword', u.userinfo)
    assert_equal('pass%2Fword', u.password)
    assert_equal('pass/word', i.password)
    assert_nil(i.domain)

    u.user = 'domain;user%3Bname'
    assert_equal('domain;user%3Bname:pass%2Fword', u.userinfo)
    assert_equal('domain;user%3Bname', u.user)
    assert_equal('domain', i.domain)
    assert_equal('user;name', i.user)

    u_uri.sub!(/^https:/, 'http:')
    u = URI.parse(u_uri)
    assert_raise(NoMethodError) do
      u.userinfo_component
    end

    UCUI.mixin(URI::HTTP)
    u = URI.parse(u_uri)
    i = u.userinfo_component
    assert_kind_of(UCUI, i)
    assert_equal('user%20name:p%40ssword', u.userinfo)
    assert_equal('user%20name', u.user)
    assert_equal('user name', i.user)
    assert_equal('p%40ssword', u.password)
    assert_equal('p@ssword', i.password)
    assert_nil(i.domain)
  end
end

end
end

