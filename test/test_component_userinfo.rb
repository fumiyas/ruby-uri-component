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
    assert_nil(i.domain)
    assert_nil(i.user)
    assert_nil(i.password)

    i = UCUI.new('user%20name')
    assert_nil(i.domain)
    assert_equal('user name', i.user)
    assert_nil(i.password)

    i = UCUI.new('user%20name:p%40ssword')
    assert_nil(i.domain)
    assert_equal('user name', i.user)
    assert_equal('p@ssword', i.password)

    i = UCUI.new('domain%5Fname;user%20name')
    assert_equal('domain_name', i.domain)
    assert_equal('user name', i.user)
    assert_nil(i.password)

    i = UCUI.new('domain%5Fname;user%20name:p%40ssword')
    assert_equal('domain_name', i.domain)
    assert_equal('user name', i.user)
    assert_equal('p@ssword', i.password)

    %w(foo/bar1 foo@bar2 foo?bar3 foo:bar:baz4 foo;bar;baz5).each do |info|
      assert_raise(URI::InvalidURIError) do
	UCUI.new(info)
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
end

end
end

