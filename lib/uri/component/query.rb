require 'uri'
require 'cgi'

module URI
  module Component
    class Query
      def initialize(query_str='')
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
  end
end

