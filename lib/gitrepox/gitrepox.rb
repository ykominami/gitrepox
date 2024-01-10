require "git"

module Gitrepox
  class Gitrepox
    attr_reader :data

    def initialize(loggerx, working_dir)
      @loggerx = loggerx
      @working_dir = working_dir
      begin
        @repo = Git.open(@working_dir)
      rescue StandardError => e
        @loggerx.error e.message
      end
      @data = {}
    end

    def valid_repo?
      @repo != nil
    end

    def show
      @data.keys.map do |key|
        @loggerx.debug key
        @data[key].keys.map do |subkey|
          @loggerx.info %(#{subkey}: #{@data[key][subkey]})
        end
      end
    end

    def to_csv_header
      ary = []
      ary << "dir"
      key = @data.keys[0]
      @data[key].keys.map do |subkey|
        ary << subkey
      end
      ary.join(",")
    end

    def to_csv_data
      @data.keys.map do |key|
        ary = []
        ary << key
        @data[key].keys.map do |subkey|
          # ary << subkey
          ary << @data[key][subkey]
        end
        ary.join(",")
      end.join("\n")
    end

    def git_config
      #  remote.origin.url=git@github.com:ykominami/ykutils.git
      #  remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
      # g.config('user.name')  # returns 'Scott Chacon'
      # p g.config('user.name')  # returns 'Scott Chacon'
      # g.config # returns whole config hash
      # p @repo.config('remote.origin.url')  # returns 'Scott Chacon'
      # p @repo.config('remote.origin.fetch')  # returns 'Scott Chacon'
    end

    def get_remote_url
      if valid_repo?
        @repo.config("remote.origin.url")
      else
        ""
      end
    end

    def get_remotes
      if valid_repo?
        @repo.remotes
      else
        []
      end
    end
  end
end
