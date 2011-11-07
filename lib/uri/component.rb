## = uri/component.rb
##
## Ruby URI::Component module
##
## Author:: SATOH Fumiyasu
## Copyright:: (c) 2007-2011 SATOH Fumiyasu @ OSS Technology, Corp.
## License:: You can redistribute it and/or modify it under the same term as Ruby.
##

require "uri/component/userinfo"
require "uri/component/path"
require "uri/component/query"

module URI #:nodoc:
  ## Handle URI components as an object
  module Component
    ## == Description
    ##
    ## Add the following instance methods to the class +klass+:
    ##
    ## userinfo_component::
    ##   Returns the userinfo component of the URI as URI::Component::UserInfo
    ##   object.
    ## path_component::
    ##   Returns the path component of the URI as URI::Component::Path object.
    ## query_component::
    ##   Returns the query component of the URI as URI::Component::Query object.
    ##
    ## == Example
    ##
    ##   require "uri"
    ##   require "uri/component"
    ##
    ##   URI::Component.mixin(URI::HTTP)
    ##
    ##   u = URI.parse("http://bob:pass@example.jp/path?foo=12&bar=ab");
    ##   i = u.userinfo_component #=> URI::Component::Userinfo.new("bob:pass")
    ##   p = u.path_component #=> URI::Component::Path.new("/path")
    ##   q = u.query_component #=> URI::Component::Query.new("foo=12&bar=ab")
    ##
    ##   i.password = nil
    ##   p i.to_s #=> "bob"
    ##   p.nodes << "file"
    ##   p p.to_s #=> "/path/file"
    ##   q.params["baz"] = ["x y z"]
    ##   p q.to_s #=> "foo=12&bar=ab&baz=x+y+z"
    ##   p u.to_s #=> "http://bob@example.jp/path/file?foo=12&bar=ab&baz=x+y+z"
    ##
    def self.mixin(klass)
      URI::Component::UserInfo.mixin(klass) if klass.component.include?(:userinfo)
      URI::Component::Path.mixin(klass) if klass.component.include?(:path)
      URI::Component::Query.mixin(klass) if klass.component.include?(:query)
    end
  end
end

