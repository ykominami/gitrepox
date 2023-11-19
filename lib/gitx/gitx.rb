
module Gitx
  class Gitx
    attr_reader :data

    def initialize(working_dir)
      @working_dir = working_dir
      begin
        @repo = Git.open(@working_dir)
      rescue => exp
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
      @data.keys.map{ |key|
        puts key
        @data[key].keys.map{ | subkey |
          puts %!#{subkey}: #{@data[key][subkey]}!
        }
      }
      # p "== show END =="
    end

    def to_csv_header
      ary = []
      ary << "dir"
      key = @data.keys[0]
      @data[key].keys.map{ | subkey |
        ary << subkey
      }
      ary.join(',')
    end

    def to_csv_data
      @data.keys.map{ |key|
        ary = []
        ary << key
        @data[key].keys.map{ | subkey |
          # ary << subkey
          ary << @data[key][subkey]
        }
        ary.join(',')
      }.join("\n")
    end
  
    def git_config()
      #  remote.origin.url=git@github.com:ykominami/ykutils.git
      #  remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
      # g.config('user.name')  # returns 'Scott Chacon'
      # p g.config('user.name')  # returns 'Scott Chacon'
      # g.config # returns whole config hash
      # p @repo.config('remote.origin.url')  # returns 'Scott Chacon'
      # p @repo.config('remote.origin.fetch')  # returns 'Scott Chacon'
    end
  
    def get_remote_url()
      if valid_repo?
        @repo.config('remote.origin.url')
      else
        ""
      end
    end
    
    def get_remotes()
      if valid_repo?
        @repo.remotes
      else
        []
      end
    end

    def Gitx.list_repo(src_pn)
      parts = src_pn.children.map{ |pn|
        [pn, pn + ".git"]
      }.partition{ |pns| 
        pns[1].exist? 
      }
      parts[0].select{ |pns|
        x = pns[0]
        g = Gitx.new(x)
        pns << g
        x.exist?
      }.map{ |pns|
        item = pns.first.basename
        full_path = pns.first.realpath
        g = pns.last
        remotes = g.get_remotes
        if remotes.size > 0
          remotes.map{ |gr|
            g.data[gr.name] = {}
            g.data[gr.name][:full_path] = full_path
            g.data[gr.name][:basename] = item
            g.data[gr.name][:url] = gr.url
            g.data[gr.name][:fetch_opts] = gr.fetch_opts
          }
          g
        else
          nil
        end
      }.select{ |item| item != nil }
    end

    def repo_to_csv(pn)
      ary = []
      Gitx::Gitx.list_repo(pn).each_with_object([0]){ |item, memo|
        # item.show
        if memo[0] == 0
          ary << item.to_csv_header
          memo[0] = 1
        end
        ary << item.to_csv_data
      }
      ary
    end
  end
end
