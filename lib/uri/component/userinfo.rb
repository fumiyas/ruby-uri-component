require 'uri'

module URI
  module Component
    class UserInfo
      RE_UNSAFE = /[^#{URI::REGEXP::PATTERN::UNRESERVED}]/
      RE_PART = /(?:[#{URI::REGEXP::PATTERN::UNRESERVED}&=+$,]|#{URI::REGEXP::PATTERN::ESCAPED})*/

      def self.mixin(c=URI::Generic)
	UserInfoMixin.__send__(:append_features, c)
	UserInfoMixin.__send__(:included, c)
      end

      def self.escape(v)
	return URI.escape(v, RE_UNSAFE)
      end

      def initialize(info_str=nil)
	if info_str
	  unless info_str =~ /^(?:(#{RE_PART});)?(#{RE_PART})(?::(#{RE_PART}))?$/
	    raise InvalidURIError, "bad UserInfo component for URI: #{info_str}"
	  end
	  @domain = $1 ? URI.unescape($1) : nil
	  @user = URI.unescape($2)
	  @password = $3 ? URI.unescape($3) : nil
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
	info_str += self.class.escape(@domain) + ';' if @domain
	info_str += @user ? self.class.escape(@user) : '';
	info_str += ':' + self.class.escape(@password) if @password
	return info_str
      end
      alias to_s to_uri
    end

    module UserInfoMixin
      def initialize_copy(url)
	if (userinfo = url.instance_variable_get('@userinfo_component'))
	  @userinfo_component = userinfo.dup
	end

	super(url)
      end

      def userinfo
	self.userinfo_component.to_uri
      end

      def userinfo=(info_str)
	info_str = super(info_str)

	parse_userinfo! if @userinfo_component
	return info_str
      end

      def user
	user = self.userinfo_component.user
	return nil unless user

	domain = self.userinfo_component.domain
	uri = domain ? URI::Component::UserInfo.escape(domain) + ';' : ''
	uri += URI::Component::UserInfo.escape(user)
	return uri
      end

      def user=(v)
	if v
	  m = v.match(/^(?:(.*);)?(.*)$/)
	  self.userinfo_component.domain = m[1] ? URI.unescape(m[1]) : nil
	  self.userinfo_component.user = URI.unescape(m[2])
	else
	  self.userinfo_component.user = nil
	end
      end

      def password
	v = self.userinfo_component.password
	return v ? URI::Component::UserInfo.escape(v) : nil
      end

      def password=(v)
	self.userinfo_component.password = URI.unescape(v)
      end

      def userinfo_component
	parse_userinfo! unless @userinfo_component
	return @userinfo_component
      end

      protected

      def parse_userinfo!
	info_str = @user
	info_str += ':' + @password if @password
	@userinfo_component = URI::Component::UserInfo.new(info_str)
      end
    end
  end
end

