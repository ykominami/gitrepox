require "git"

module Gitx
  class Gsession
    def initialize(config = "config.json")
      @session = GoogleDrive::Session.from_config(config)
    end
    
    def upload_from_string(content, filename, content_type = "text/tab-separated-values")
      obj = @session.upload_from_string(content, filename, content_type: content_type ) 
      [obj.title, obj.id].join(",")
    end
  end
end