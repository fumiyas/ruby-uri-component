## Ruby URI::Component::UserInfo: Class to handle an userinfo component in an URI
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require 'uri'

module URI #:nodoc:
  module Component
    ## Handle an userinfo component in an URI as an object
    class UserInfo
      #:stopdoc:
      RE_ELEMENT_UNSAFE = /[^#{URI::REGEXP::PATTERN::UNRESERVED}]/
      ## Same as URI::USERINFO, except ';' and ':'
      RE_ELEMENT = /(?:
        [#{URI::REGEXP::PATTERN::UNRESERVED}&=+$,]|
        #{URI::REGEXP::PATTERN::ESCAPED})*
      /x
      RE_COMPONENT = /^(?:(#{RE_ELEMENT});)?(#{RE_ELEMENT})(?::(#{RE_ELEMENT}))?$/
      #:startdoc:

      def self.mixin(klass=URI::Generic) #:nodoc:
	UserInfoMixin.__send__(:append_features, klass)
	UserInfoMixin.__send__(:included, klass)
      end

      def escape_element(v)
	return URI.escape(v, RE_ELEMENT_UNSAFE)
      end

      def initialize(info_str=nil)
	if info_str
	  unless m = info_str.match(RE_COMPONENT)
	    raise InvalidURIError, "bad UserInfo component for URI: #{info_str}"
	  end
	  @domain = m[1] ? URI.unescape(m[1]) : nil
	  @user = URI.unescape(m[2])
	  @password = m[3] ? URI.unescape(m[3]) : nil
	else
	  @domain = @user = @password = nil
	end
      end

      def domain
	return @domain
      end

      def domain=(v)
	if v && !@user
	  raise InvalidURIError, "domain component depends user component"
	end
	@domain = v
      end

      def user
	return @user
      end

      def user=(v)
	if !v
	  @domain = @password = nil
	end
	@user = v
      end

      def password
	return @password
      end

      def password=(v)
	if v && !@user
	  raise InvalidURIError, "password component depends user component"
	end
	@password = v
      end

      def to_uri
	return nil unless @user

	info_str = ''
	info_str += self.escape_element(@domain) + ';' if @domain
	info_str += @user ? self.escape_element(@user) : '';
	info_str += ':' + self.escape_element(@password) if @password
	return info_str
      end
      alias to_s to_uri
    end

    module UserInfoMixin #:nodoc:
      def initialize_copy(uri)
	if (userinfo = uri.instance_variable_get('@userinfo_component'))
	  @userinfo_component = userinfo.dup
	end

	super(uri)
      end

      def userinfo
	return @userinfo_component ? @userinfo_component.to_uri : nil
      end

      def userinfo=(info_str)
	super(info_str)

	parse_userinfo!
	return self.userinfo
      end

      def user
	user = @userinfo_component.user
	return nil unless user

	domain = @userinfo_component.domain
	user_uri = domain ? @userinfo_component.escape_element(domain) + ';' : ''
	user_uri += @userinfo_component.escape_element(user)
	return user_uri
      end

      def user=(user_uri)
	if user_uri
	  m = user_uri.match(/^(?:(.*);)?(.*)$/)
	  @userinfo_component.domain = m[1] ? URI.unescape(m[1]) : nil
	  @userinfo_component.user = URI.unescape(m[2])
	else
	  @userinfo_component.user = nil
	end
      end

      def password
	pass = @userinfo_component.password
	return pass ? @userinfo_component.escape_element(pass) : nil
      end

      def password=(pass_uri)
	@userinfo_component.password = pass_uri ? URI.unescape(pass_uri) : nil
      end

      def userinfo_component
	parse_userinfo! unless @userinfo_component
	return @userinfo_component
      end
      alias userinfo_c userinfo_component

      protected

      def parse_userinfo!
	info_str = @user
	info_str += ':' + @password if @password
	@userinfo_component = URI::Component::UserInfo.new(info_str)
      end
    end
  end
end

