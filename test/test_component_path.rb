require 'test/unit'
require 'uri/component/path'

UCP = URI::Component::Path

module URI
module Component

class TestPathClass < Test::Unit::TestCase
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

    p_uri = '/123%20abc'
    p = UCP.new(p_uri)
    assert_equal('/123+abc', p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('123 abc', p.nodes[0])

    p_uri = '/123+abc%2BABC'
    p = UCP.new(p_uri)
    assert_equal(p_uri, p.to_uri)
    assert_equal(1, p.nodes.size)
    assert_equal('123 abc+ABC', p.nodes[0])

    p_uri = '/foo-1/bar-abc%40xyz/baz-123%20%00%2B789'
    p = UCP.new(p_uri)
    assert_equal('/foo-1/bar-abc%40xyz/baz-123+%00%2B789', p.to_uri)
    assert_equal(3, p.nodes.size)
    assert_equal('foo-1', p.nodes[0])
    assert_equal('bar-abc@xyz', p.nodes[1])
    assert_equal("baz-123 \x00+789", p.nodes[2])

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
    assert_equal('/123+abc', p.to_uri)

    p = UCP.new('')
    p.nodes << '123+abc'
    assert_equal('/123%2Babc', p.to_uri)

    p = UCP.new('')
    p.nodes << 'abc@xyz'
    p.nodes << "123 \x00+789"
    assert_equal('/abc%40xyz/123+%00%2B789', p.to_uri)
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
    UCP.mixin(URI::HTTP)

    u_uri = 'http://example.jp/foo-123%40example/bar-abc%20xyz'
    u = URI.parse(u_uri)
    p = u.path_component
    assert_kind_of(UCP, p)
    assert_equal(u_uri, u.to_s)
    assert_equal('/foo-123%40example/bar-abc+xyz', u.path)
    assert_equal('/foo-123%40example/bar-abc+xyz', p.to_s)

    u_uri = 'ftp://example.jp/foo'
    u = URI.parse(u_uri)
    assert_raise(NoMethodError) do
      u.path_component
    end
  end
end

end
end

