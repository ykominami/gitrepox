require "git"
require "secretmgr"
require "pathname"

module Gitrepox
  class Gsession
    @target = "Google"
    @sub_target = "GCPX"
    @secret_dir = "secret"

    class << self
      attr_reader :target, :sub_target, :secret_dir
    end

    def initialize(loggerx, config = "config.json")
      @loggerx = loggerx
      result = ensure_config_file(config)
      @session = (GoogleDrive::Session.from_config(config) if result)
    end

    def valid?
      @session != nil
    end

    def ensure_config_file(fname)
      pn = Pathname.new(fname)
      return if pn.exist?

      make_config_file(fname, Gsession.target, Gsession.sub_target)
    end

    def make_config_file(fname, target, sub_target)
      result = false
      home_dir = Dir.home
      home_pn = Pathname.new(home_dir)
      secret_dir_pn = home_pn + Gsession.secret_dir
      @loggerx.debug "secret_dir_pn=#{secret_dir_pn}"
      if secret_dir_pn.exist?
        smgr = Secretmgr::Secretmgr.new(@loggerx, secret_dir_pn)
        return false unless smgr.valid?

        smgr.set_setting_for_query(target, sub_target)
        content = smgr.load
        File.write(fname, content)
        result = true
      else
        @loggerx.debug "Can not find #{secret_dir_pn}"
      end

      result
    end

    def delete_config_file(fname)
      File.delete(fname)
    end

    def upload_from_string(content, filename, content_type = "text/tab-separated-values")
      obj = @session.upload_from_string(content, filename, content_type: content_type)
      [obj.title, obj.id].join(",")
    end
  end
end
