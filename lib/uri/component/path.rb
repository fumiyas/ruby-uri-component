## Ruby URI::Component::Path: Class to handle a path component in an URI
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require 'uri'
require 'cgi'

module URI
  module Component
    ## Class to handle a path component in an URI
    class Path
      RE_COMPONENT = /^(?:#{URI::REGEXP::PATTERN::ABS_PATH})?$/

      def self.mixin(c=URI::Generic)
	PathMixin.__send__(:append_features, c)
	PathMixin.__send__(:included, c)
      end

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

    module PathMixin
      def initialize_copy(uri)
	if (path = uri.instance_variable_get('@path_component'))
	  @path_component = path.dup
	end

	super(uri)
      end

      def path
	@path_component.to_uri
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

      protected

      def parse_path!
	@path_component = URI::Component::Path.new(@path)
      end
    end
  end
end

