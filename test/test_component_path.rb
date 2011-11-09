require 'test/unit'
require 'uri/component/path'

UCP = URI::Component::Path

module URI
module Component

class PathTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_parse
    p_uri = ''
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_empty(p.nodes)

    p_uri = '/'
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('', p.nodes[0])

    p_uri = '/foo'
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('foo', p.nodes[0])

    p_uri = '/foo/'
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_equal(2, p.nodes.size)
    assert_equal('foo', p.nodes[0])
    assert_equal('foo', p[0])
    assert_empty(p.nodes[1])
    assert_empty(p[1])

    p_uri = '/123%20abc'
    p = UCP.new(p_uri)
    assert_equal('/123%20abc', p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('123 abc', p.nodes[0])

    p_uri = '/123+abc%2BABC'
    p = UCP.new(p_uri)
    assert_equal('/123+abc+ABC', p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('123+abc+ABC', p.nodes[0])

    p_uri = '/foo-1/bar-abc%40xyz/baz-123%20%00%2B789%25ff'
    p = UCP.new(p_uri)
    assert_equal('/foo-1/bar-abc@xyz/baz-123%20%00+789%25ff', p.to_uri)
    assert_equal(3, p.nodes.size)
    assert_equal('foo-1', p.nodes[0])
    assert_equal('bar-abc@xyz', p.nodes[1])
    assert_equal("baz-123 \x00+789%ff", p.nodes[2])

    p_uri = '/foo//bar'
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_equal(3, p.nodes.size)
    assert_equal('foo', p.nodes[0])
    assert_equal('', p.nodes[1])
    assert_equal('bar', p.nodes[2])

    %w(foo1 /foo?bar2 /foo\bar3).concat(['/foo bar4']).each do |path_str|
      assert_raise(URI::InvalidURIError) do
	UCP.new(path_str)
	raise path_str
      end
    end
  end

  def test_set
    p = UCP.new('')
    assert_equal('', p.to_uri)

    p = UCP.new('')
    p.nodes << 'foo'
    assert_equal('/foo', p.to_uri)

    p = UCP.new('')
    p.nodes << 'foo?bar'
    assert_equal('/foo%3Fbar', p.to_uri)

    p = UCP.new('')
    p.nodes << 'foo/bar'
    assert_equal('/foo%2Fbar', p.to_uri)

    p = UCP.new('')
    p.nodes << '123 abc'
    assert_equal('/123%20abc', p.to_uri)

    p = UCP.new('')
    p.nodes << '123+abc'
    assert_equal('/123+abc', p.to_uri)

    p = UCP.new('')
    p.nodes << 'abc@xyz'
    p.nodes << "123 \x00+789%ff"
    assert_equal('/abc@xyz/123%20%00+789%25ff', p.to_uri)
  end

  def test_normalize
    p = UCP.new('/foo/')
    p.normalize!
    assert_equal('/foo', p.to_uri)

    p = UCP.new('/foo/./bar')
    p.normalize!
    assert_equal('/foo/bar', p.to_uri)

    p = UCP.new('/foo/./bar/baz/.')
    p.normalize!
    assert_equal('/foo/bar/baz', p.to_uri)

    p = UCP.new('/foo/../bar')
    p.normalize!
    assert_equal('/bar', p.to_uri)

    p = UCP.new('/foo/../../../bar')
    p.normalize!
    assert_equal('/bar', p.to_uri)

    p = UCP.new('/foo/./../bar')
    p.normalize!
    assert_equal('/bar', p.to_uri)

    p = UCP.new('/foo//bar')
    p.normalize!
    assert_equal('/foo/bar', p.to_uri)
  end

  def test_mixin
    UCP.mixin(URI::HTTPS)

    u_uri = 'https://example.jp/abc%40xyz/123+%00%2B789%25ff'
    u_uri_x = u_uri.gsub('%40','@').gsub('%2B', '+')
    u = URI.parse(u_uri)
    p = u.path_component
    assert_kind_of(URI::HTTPS, u)
    assert_kind_of(UCP, p)
    assert_equal(u_uri_x, u.to_s)
    assert_equal('/abc@xyz/123+%00+789%25ff', u.path)
    assert_equal('/abc@xyz/123+%00+789%25ff', p.to_s)

    p.nodes << 'xxx'
    assert_equal(u_uri_x + '/xxx', u.to_s)
    assert_equal('/abc@xyz/123+%00+789%25ff/xxx', u.path)
    assert_equal('/abc@xyz/123+%00+789%25ff/xxx', p.to_s)

    u_uri.sub!(/^https:/, 'http:')
    u_uri_x = u_uri.gsub('%40','@').gsub('%2B', '+')
    u = URI.parse(u_uri)
    assert_raise(NoMethodError) do
      u.path_component
    end

    UCP.mixin(URI::HTTP)
    u = URI.parse(u_uri)
    p = u.path_component
    assert_kind_of(URI::HTTP, u)
    assert_kind_of(UCP, u.path_component)
    assert_equal(u_uri_x, u.to_s)
    assert_equal('/abc@xyz/123+%00+789%25ff', u.path)
    assert_equal('/abc@xyz/123+%00+789%25ff', p.to_s)
  end
end

end
end

