require "loggerx"

module Gitrepox
  class Cli
    def initialize(argv)
      @argv = argv
      use_stdout = true
      log_level = :debug
      @loggerx = Loggerx::Loggerx.new("log_", "log.txt", ".", use_stdout, log_level)

      home_dir = Dir.home
      @home_pn = Pathname.new(home_dir)

      @output_log_filename = "log2.txt"
      File.write(@output_log_filename, "") unless Pathname.new(@output_log_filename).exist?
    end

    def execute
      gg = Gitrepoxgroup.new(@loggerx, @home_pn, @output_log_filename, @argv)

      # gg =Gitrepox::Gitrepoxgroup.new(home_pn, yaml_fname)
      gg.get_and_upload
    end
  end
end
