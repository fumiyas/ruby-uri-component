require 'uri'
require 'cgi'

module URI
  module Component
    class Query
      def initialize(query_str='')
	@query_params = {}
	@query_params.default_proc = Proc.new {|hash, key|
	  hash[key] = [] unless hash.key?(key)
	}

	query_str.split('&').each do |param|
	  next if param.empty?
	  name, value = param.split('=', 2).map do |v|
	    CGI.unescape(v)
	  end
	  @query_params[name] ||= []
	  @query_params[name] << value ? value : nil
	end
      end

      def params
	return @query_params
      end

      def to_uri
	query = []

	@query_params.each do |name, values|
	  name = CGI.escape(name)
	  values.each do |value|
	    query << "#{name}#{'=' + CGI.escape(value.to_s) if value}"
	  end
	end

	return query.join('&')
      end
      alias to_s to_uri
    end
  end
end

