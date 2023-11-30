require 'git'

module Gitx
  class Gitx
    attr_reader :data

    def initialize(working_dir)
      @working_dir = working_dir
      begin
        @repo = Git.open(@working_dir)
      rescue StandardError => exp
        puts exp.message
        #
      end
      @data = {}
    end

    def valid_repo?
      @repo != nil
    end

    def show
      # p "== show ======"
      # p @data
      @data.keys.map do |key|
        puts key
        @data[key].keys.map do |subkey|
          puts %(#{subkey}: #{@data[key][subkey]})
        end
      end
      # p "== show END =="
    end

    def to_csv_header
      ary = []
      ary << 'dir'
      key = @data.keys[0]
      @data[key].keys.map do |subkey|
        ary << subkey
      end
      ary.join(',')
    end

    def to_csv_data
      @data.keys.map do |key|
        ary = []
        ary << key
        @data[key].keys.map do |subkey|
          # ary << subkey
          ary << @data[key][subkey]
        end
        ary.join(',')
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
        @repo.config('remote.origin.url')
      else
        ''
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
