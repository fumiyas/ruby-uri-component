require 'uri'

module URI
  module Component
    class UserInfo
      RE_UNSAFE = /[^#{URI::REGEXP::PATTERN::UNRESERVED}]/
      RE_PART = /(?:[#{URI::REGEXP::PATTERN::UNRESERVED}&=+$,]|#{URI::REGEXP::PATTERN::ESCAPED})*/

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
	return '' unless @user

	info_str = ''
	info_str += URI.escape(@domain, RE_UNSAFE) + ';' if @domain
	info_str += @user ? URI.escape(@user, RE_UNSAFE) : '';
	info_str += ':' + URI.escape(@password, RE_UNSAFE) if @password
	return info_str
      end
      alias to_s to_uri
    end
  end
end
