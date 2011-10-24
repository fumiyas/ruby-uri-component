require 'uri'
require 'cgi'

module URI
  module Component
    class Path
      RE_COMPONENT = /^(?:#{URI::REGEXP::PATTERN::ABS_PATH})?$/

      def initialize(path_str='')
	unless path_str =~ RE_COMPONENT
	  raise InvalidURIError, "bad Path component for URI: #{path_str}"
	end

	if path_str
	  @nodes = path_str.split('/', -1).map do |node|
	    CGI.unescape(node)
	  end
	  @nodes.shift
	else
	  @nodes = []
	end
      end

      def nodes
	return @nodes
      end

      def to_uri
	return '' if @nodes.empty?
	return '/' + @nodes.map do |node|
	  CGI.escape(node)
	end.join('/')
      end
      alias to_s to_uri
    end
  end
end

