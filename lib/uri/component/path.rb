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

      def to_uri
	return '' if @nodes.empty?
	return '/' + @nodes.map do |node|
	  CGI.escape(node)
	end.join('/')
      end
      alias to_s to_uri

      def nodes
	return @nodes
      end

      def nodes=(v)
	@nodes = v
      end

      def normalize!
	nodes = []
	@nodes.each do |node|
	  case node
	  when ''
	    next
	  when '.'
	    next
	  when '..'
	    nodes.pop
	    next
	  end
	  nodes << node
	end

	@nodes = nodes
      end
    end
  end
end

