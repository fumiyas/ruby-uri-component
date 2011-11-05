require 'test/unit'
require 'uri/component/query'

UCQ = URI::Component::Query

module URI
module Component

class QueryTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_parse
    q_uri = ''
    q = UCQ.new(q_uri)
    assert_equal(q_uri, q.to_uri)
    assert_empty(q.params)

    q_uri = 'foo=1'
    q = UCQ.new(q_uri)
    assert_equal(q_uri, q.to_uri)
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])

    q_uri = 'foo'
    q = UCQ.new(q_uri)
    assert_equal(q_uri, q.to_uri)
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_nil(q.params['foo'][0])

    q_uri = 'foo=123%20abc'
    q = UCQ.new(q_uri)
    assert_equal(q_uri.gsub('%20', '+'), q.to_uri)
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('123 abc', q.params['foo'][0])

    q_uri = 'foo=123+abc%2BABC'
    q = UCQ.new(q_uri)
    assert_equal(q_uri, q.to_uri)
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('123 abc+ABC', q.params['foo'][0])

    q_uri = 'foo=1&bar=abc%40xyz&baz=123%20%00%2B789'
    q = UCQ.new(q_uri)
    assert_equal(q_uri.gsub('%20', '+'), q.to_uri)
    assert_equal(3, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_equal(1, q.params['bar'].size)
    assert_equal('abc@xyz', q.params['bar'][0])
    assert_equal(1, q.params['baz'].size)
    assert_equal("123 \x00+789", q.params['baz'][0])

    q_uri = 'foo=1&bar=a&foo=2&bar=bb&bar=ccc'
    q = UCQ.new(q_uri)
    assert_equal('foo=1&foo=2&bar=a&bar=bb&bar=ccc', q.to_uri)
    assert_equal(2, q.params.size)
    assert_equal(2, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_equal('2', q.params['foo'][1])
    assert_equal(3, q.params['bar'].size)
    assert_equal('a', q.params['bar'][0])
    assert_equal('bb', q.params['bar'][1])
    assert_equal('ccc', q.params['bar'][2])

    q_uri = 'foo=1&foo&bar&baz=a'
    q = UCQ.new(q_uri)
    assert_equal(q_uri, q.to_uri)
    assert_equal(3, q.params.size)
    assert_equal(2, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_nil(q.params['foo'][1])
    assert_equal(1, q.params['bar'].size)
    assert_nil(q.params['bar'][0])
    assert_equal(1, q.params['baz'].size)
    assert_equal('a', q.params['baz'][0])

    q_uri = 'foo=1;bar=abc;baz=ABC'
    q = UCQ.new(q_uri)
    assert_equal(q_uri.gsub(';', '&'), q.to_uri)
    assert_equal(q_uri, q.to_uri(';'))
    assert_equal(3, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_equal(1, q.params['bar'].size)
    assert_equal('abc', q.params['bar'][0])
    assert_equal(1, q.params['baz'].size)
    assert_equal('ABC', q.params['baz'][0])

    assert_raise(URI::InvalidURIError) do
      UCQ.new('foo bar')
    end
  end

  def test_set
    q = UCQ.new('')
    q.params['foo'] = [1]
    assert_equal('foo=1', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = [nil]
    assert_equal('foo', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = ['123 abc']
    assert_equal('foo=123+abc', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = ['123+abc']
    assert_equal('foo=123%2Babc', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = [1]
    q.params['bar'] = ['abc@xyz']
    q.params['baz'] = ["123 \x00+789"]
    assert_equal('foo=1&bar=abc%40xyz&baz=123+%00%2B789', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = [1, 2]
    q.params['bar'] = ['a', 'bb', 'ccc']
    assert_equal('foo=1&foo=2&bar=a&bar=bb&bar=ccc', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = [1, nil]
    q.params['bar'] = [nil]
    q.params['baz'] = ['a']
    assert_equal('foo=1&foo&bar&baz=a', q.to_uri)

    q = UCQ.new('')
    q.params['foo'] = [1]
    q.params['bar'] = ['abc']
    q.params['baz'] = ['ABC']
    assert_equal('foo=1;bar=abc;baz=ABC', q.to_uri(';'))
  end

  def test_mixin
    UCQ.mixin(URI::HTTPS)

    u_uri = 'https://example.jp/?foo=123%40example&bar=abc%20xyz'
    u_uri_x = u_uri.gsub('+', '%2B').gsub('%20', '+')
    u = URI.parse(u_uri)
    q = u.query_component
    assert_kind_of(UCQ, q)
    assert_equal(u_uri_x, u.to_s)
    assert_equal('foo=123%40example&bar=abc+xyz', u.query)
    assert_equal('foo=123%40example&bar=abc+xyz', q.to_s)

    q.params['baz'] = ['xxx']
    assert_equal(u_uri_x + '&baz=xxx', u.to_s)
    assert_equal('foo=123%40example&bar=abc+xyz&baz=xxx', u.query)
    assert_equal('foo=123%40example&bar=abc+xyz&baz=xxx', q.to_s)

    u_uri.sub!(/^https:/, 'http:')
    u_uri_x = u_uri.gsub('+', '%2B').gsub('%20', '+')
    u = URI.parse(u_uri)
    assert_raise(NoMethodError) do
      u.query_component
    end

    UCQ.mixin(URI::HTTP)
    u = URI.parse(u_uri)
    q = u.query_component
    assert_kind_of(UCQ, q)
    assert_equal(u_uri_x, u.to_s)
    assert_equal('foo=123%40example&bar=abc+xyz', u.query)
    assert_equal('foo=123%40example&bar=abc+xyz', q.to_s)
  end
end

end
end

