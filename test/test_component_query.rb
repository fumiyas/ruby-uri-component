require 'test/unit'
require 'uri/component/query'

UCQ = URI::Component::Query

module URI
module Component

class TestQueryClass < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_parse
    q = UCQ.new('')
    assert_empty(q.params)

    q = UCQ.new('foo=1')
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])

    q = UCQ.new('foo')
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_nil(q.params['foo'][0])

    q = UCQ.new('foo=123%20abc')
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('123 abc', q.params['foo'][0])

    q = UCQ.new('foo=123+abc%2BABC')
    assert_equal(1, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('123 abc+ABC', q.params['foo'][0])

    q = UCQ.new('foo=1&bar=abc%40xyz&baz=123%20%00%2B789')
    assert_equal(3, q.params.size)
    assert_equal(1, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_equal(1, q.params['bar'].size)
    assert_equal('abc@xyz', q.params['bar'][0])
    assert_equal(1, q.params['baz'].size)
    assert_equal("123 \x00+789", q.params['baz'][0])

    q = UCQ.new('foo=1&bar=a&foo=2&bar=bb&bar=ccc')
    assert_equal(2, q.params.size)
    assert_equal(2, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_equal('2', q.params['foo'][1])
    assert_equal(3, q.params['bar'].size)
    assert_equal('a', q.params['bar'][0])
    assert_equal('bb', q.params['bar'][1])
    assert_equal('ccc', q.params['bar'][2])

    q = UCQ.new('foo=1&foo&bar&baz=a')
    assert_equal(3, q.params.size)
    assert_equal(2, q.params['foo'].size)
    assert_equal('1', q.params['foo'][0])
    assert_nil(q.params['foo'][1])
    assert_equal(1, q.params['bar'].size)
    assert_nil(q.params['bar'][0])
    assert_equal(1, q.params['baz'].size)
    assert_equal('a', q.params['baz'][0])
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
  end
end

end
end

