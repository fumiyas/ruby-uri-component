## Ruby URI::Component::Query: Class to handle a query component in an URI
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require 'uri'
require 'cgi'

module URI
  module Component
    class QueryParamsHash < Hash #:nodoc:
      def convert_key(key)
        return key.kind_of?(String) ? key : key.to_s
      end
      def [](key)
        super(self.convert_key(key))
      end
      def fetch(key, default = nil)
        super(self.convert_key(key), default)
      end

      def values(key = nil)
        return key ? self[key] : super
      end

      def value(key)
        return self[key][0]
      end

      def values_at(*keys)
        super(*keys.map {|key| self.convert_key(key)})
      end

      def []=(key, values)
        values = [values] unless values.kind_of?(Array)
        super(self.convert_key(key), values)
      end
      def store(key, values)
        self[key] = values
      end

      def delete(key)
        super(self.convert_key(key))
      end

      def has_key?(key)
        super(self.convert_key(key))
      end
      alias :include? :has_key?
      alias :key? :has_key?
      alias :member? :has_key?

      def merge(hash)
        hash_new = self.class.new
        hash.each do |key, value|
          hash_new[key] = value
        end
        return hash_new
      end

      def merge!(hash)
        hash.each do |key, value|
          self[key] = value
        end
        return self
      end
      alias :update :merge!

      def replace(hash)
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

      def self.mixin(klass) #:nodoc:
	QueryMixin.__send__(:append_features, klass)
	QueryMixin.__send__(:included, klass)
      end

      def initialize(query_str='')
	unless query_str =~ RE_COMPONENT
	  raise InvalidURIError, "bad Query component for URI: #{query_str}"
	end

	@params = QueryParamsHash.new
	@params.default_proc = Proc.new {|hash, key|
	  hash[key] = [] unless hash.key?(key)
	}
	@param_separator = '&'

	query_str.split(/[&;]/).each do |param|
	  next if param.empty?
	  name, value = param.split('=', 2).map do |v|
	    CGI.unescape(v)
	  end
	  @params[name] ||= []
	  @params[name] << value ? value : nil
	end
      end

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

    module QueryMixin
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

