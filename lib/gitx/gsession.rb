require "git"

module Gitx
  class Gsession
    def initialize(config = "config.json")
      @session = GoogleDrive::Session.from_config(config)
    end

    def repo_to_csv(pn)
      ary = []
      Gitx.list_repo(pn).each_with_object([0]){ |item, memo|
        # item.show
        if memo[0] == 0
          ary << item.to_csv_header
          memo[0] = 1
        end
        ary << item.to_csv_data
      }
      ary
    end
    
    def upload_from_string(content, filename, content_type = "text/tab-separated-values")
      obj = @session.upload_from_string(content, filename, content_type: content_type ) 
      [obj.title, obj.id].join(",")
    end

    def get_list_git_repo_in_spreadsheet(pn, filename, log_filename)
      get_list_git_repo(pn, filename, log_filename, "text/tab-separated-values")
    end

    def get_list_git_repo(pn, filename, log_filename, content_type)
      content_array = repo_to_csv(pn)
      content = content_array.join("\n")
      result = upload_from_string(content, filename, content_type)
      Util.file_append(log_filename, result)
    end
  end
end