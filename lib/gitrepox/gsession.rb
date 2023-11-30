require 'git'
require 'secretmgr'
require 'pathname'

module Gitrepox
  class Gsession
    def initialize(config = 'config.json')
      ensure_config_file(config)
      @session = GoogleDrive::Session.from_config(config)
    end

    def ensure_config_file(fname)
      pn = Pathname.new(fname)
      return if pn.exist?

      target = 'Google'
      sub_target = 'GCPX'
      make_config_file(config, target, sub_target)
    end

    def make_config_file(fname, target, sub_target)
      home_dir = ENV['HOME']
      home_pn = Pathname.new(home_dir)
      secret_dir_pn = "#{home_pn}secret"
      sm = Secretmgr::Secretmgr.new(secret_dir_pn)
      sm.set_setting_for_query(target, sub_target)
      content = sm.load
      File.write(fname, content)
    end

    def delete_config_file(fname)
      File.delete(fname)
    end

    def upload_from_string(content, filename, content_type = 'text/tab-separated-values')
      obj = @session.upload_from_string(content, filename, content_type: content_type)
      [obj.title, obj.id].join(',')
    end
  end
end
