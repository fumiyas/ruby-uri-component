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
    class Query
      RE_COMPONENT = /^#{URI::REGEXP::PATTERN::QUERY}?$/

      def self.mixin(klass)
	QueryMixin.__send__(:append_features, klass)
	QueryMixin.__send__(:included, klass)
      end

      def initialize(query_str='')
	unless query_str =~ RE_COMPONENT
	  raise InvalidURIError, "bad Query component for URI: #{query_str}"
	end

	@params = {}
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
	@query_component.to_uri
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

      protected

      def parse_query!
	@query_component = URI::Component::Query.new(@query)
      end
    end
  end
end

