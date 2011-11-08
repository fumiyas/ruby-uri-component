## Ruby URI::Component::Path: Class to handle a path component in an URI
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require 'uri'

module URI #:nodoc:
  module Component
    ## Handle a path component in an URI as an object
    class Path
      #:stopdoc:
      ## Same as URI::UNSAFE, plus '/' (separator for path nodes)
      ## and '?' (separator for path and query)
      RE_NODE_UNSAFE = /
        [^#{URI::REGEXP::PATTERN::UNRESERVED}#{URI::REGEXP::PATTERN::RESERVED}]|
        [\/?]
      /x
      RE_COMPONENT = /^(?:#{URI::REGEXP::PATTERN::ABS_PATH})?$/
      #:startdoc:

      def self.mixin(klass) #:nodoc:
	PathMixin.__send__(:append_features, klass)
	PathMixin.__send__(:included, klass)
      end

      def initialize(path_str='')
	unless path_str =~ RE_COMPONENT
	  raise InvalidURIError, "bad Path component for URI: #{path_str}"
	end

	if path_str
	  @nodes = path_str.split('/', -1).map do |node|
	    URI.unescape(node)
	  end
	  @nodes.shift
	else
	  @nodes = []
	end
      end

      def escape_node(v)
        return URI.escape(v, RE_NODE_UNSAFE)
      end

      def to_uri
	return '' if @nodes.empty?
	return '/' + @nodes.map do |node|
	  self.escape_node(node)
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

    module PathMixin #:nodoc:
      def initialize_copy(uri)
	if (path = uri.instance_variable_get('@path_component'))
	  @path_component = path.dup
	end

	super(uri)
      end

      def path
	return @path_component ? @path_component.to_uri : @path
      end

      def path=(path_str)
	super(path_str)

	parse_path!
	return self.path
      end

      def path_component
	parse_path! unless @path_component
	return @path_component
      end
      alias path_c path_component

      def path_query
        str = self.path
        if query = self.query
          str += '?' + query
        end
        return str
      end
      private :path_query

      protected

      def parse_path!
	@path_component = URI::Component::Path.new(@path)
      end
    end
  end
end

