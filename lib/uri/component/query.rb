## Ruby URI::Component::Query: Class to handle a query component in an URI
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require 'uri'
require 'cgi'

module URI #:nodoc:
  module Component
    ## Handle query parameters for the URI as a hash
    ##
    ## == Example
    ##
    ##   require "uri/component/query"
    ##
    ##   query = URI::Component::Query.new('foo=123&bar=x+y&bar=%40example')
    ##   params = query.params
    ##   #=> #<URI::Component::QueryParamsHash: {"foo"=>["123"], "bar"=>["x y", "@example"]}>
    ##
    ##   p params['foo']
    ##   #=> ["123"]
    ##   p params[:foo]
    ##   #=> ["123"]
    ##   p params.values(:foo)
    ##   #=> ["123"]
    ##   p params.value(:foo)
    ##   #=> "123"
    ##
    ##   p params['bar']
    ##   #=> ["x y", "@example"]
    ##   p params[:bar]
    ##   #=> ["x y", "@example"]
    ##   p params.values(:bar)
    ##   #=> ["x y", "@example"]
    ##   p params.value(:bar)
    ##   #=> "x y"
    ##
    ##   params[:foo] = [1, 2, 3]
    ##   #=> [1, 2, 3]
    ##   params[:bar] = 'baz@baz.example.jp'
    ##   #=> ["baz@baz.example.jp"]
    ##   p query.to_uri
    ##   #=> "foo=1&foo=2&foo=3&bar=baz%40example.jp"
    class QueryParamsHash < Hash
      def initialize
	super
	@nil = true
      end

      def clear
	super
	@nil = true
      end

      def nil=(flag)
	@nil = flag
      end

      def nil?
	return !@nil
      end

      def convert_key(key) #:nodoc:
        return key.kind_of?(String) ? key : key.to_s
      end
      def [](key) #:nodoc:
        super(self.convert_key(key))
      end
      def fetch(key, default = nil) #:nodoc:
        super(self.convert_key(key), default)
      end

      ## Returns an array of values from the hash for the given key.
      def values(key)
        return self[key]
      end

      ## Returns a value from the hash for the given key.
      def value(key)
        return self[key][0]
      end

      def values_at(*keys) #:nodoc:
        super(*keys.map {|key| self.convert_key(key)})
      end

      def []=(key, values) #:nodoc:
	@nil = false
        values = [values] unless values.kind_of?(Array)
        super(self.convert_key(key), values)
      end
      def store(key, values) #:nodoc:
	@nil = false
        self[key] = values
      end

      def delete(key) #:nodoc:
        super(self.convert_key(key))
      end

      def has_key?(key) #:nodoc:
        super(self.convert_key(key))
      end
      alias :include? :has_key?
      alias :key? :has_key?
      alias :member? :has_key?

      def merge(hash) #:nodoc:
        hash_new = self.class.new
        hash.each do |key, value|
          hash_new[key] = value
        end
        return hash_new
      end

      def merge!(hash) #:nodoc:
        hash.each do |key, value|
          self[key] = value
        end
        return self
      end
      alias :update :merge!

      def replace(hash) #:nodoc:
        self.clear
        hash.each do |key, value|
          self[key] = value
        end
        return self
      end
    end

    ## Handle a query component in an URI as an object
    class Query
      #:stopdoc:
      RE_COMPONENT = /^#{URI::REGEXP::PATTERN::QUERY}?$/
      #:startdoc:

      DEFAULT_PARAM_SEPARATOR = '&'

      def self.mixin(klass) #:nodoc:
	QueryMixin.__send__(:append_features, klass)
	QueryMixin.__send__(:included, klass)
      end

      def initialize(query_str=nil)
	unless !query_str || query_str =~ RE_COMPONENT
	  raise InvalidURIError, "bad Query component for URI: #{query_str}"
	end

	@params = QueryParamsHash.new
	@param_separator = DEFAULT_PARAM_SEPARATOR

	if query_str
	  @params.nil = false
	  query_str.split(/[&;]/).each do |param|
	    next if param.nil?
	    name, value = param.split('=', 2).map do |v|
	      CGI.unescape(v)
	    end
	    @params[name] ||= []
	    @params[name] << value ? value : nil
	  end
	end
      end

      def clear
	@params.clear
      end

      def [](key)
	return @params[key]
      end

      ## Returns query parameters as an URI::Component::QueryParamsHash object
      def params
	return @params
      end

      def param_separator
	return @param_separator
      end

      def param_separator=(v)
	@param_separator = v
      end

      def to_uri(separator=@param_separator)
	return nil unless @params.nil?

	query = []

	@params.each do |name, values|
	  name = CGI.escape(name)
	  values.each do |value|
	    query << "#{name}#{'=' + CGI.escape(value.to_s) if value}"
	  end
	end

	return query.join(separator)
      end
      alias to_s to_uri
    end

    module QueryMixin #:nodoc:
      def initialize_copy(uri)
	if (query = uri.instance_variable_get('@query_component'))
	  @query_component = query.dup
	end

	super(uri)
      end

      def query
	return @query_component ? @query_component.to_uri : @query
      end

      def query=(query_str)
	super(query_str)

	parse_query!
	return self.query
      end

      def query_component
	parse_query! unless @query_component
	return @query_component
      end
      alias query_c query_component

      def path_query
        str = self.path
        if query = self.query
          str += '?' + query
        end
        return str
      end
      private :path_query

      protected

      def parse_query!
	@query_component = URI::Component::Query.new(@query)
      end
    end
  end
end

