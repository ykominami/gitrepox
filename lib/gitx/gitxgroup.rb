module Gitx
  class Gitxgroup
    def initialize(home_pn, log_filename, yaml_fname_or_start_path_array )
      @home_pn = home_pn
      @log_filename = log_filename
      @obj = []
      yaml_fname_or_start_path_array.each do |yaml_fname_or_start_path|
        pn = Pathname.new(yaml_fname_or_start_path)
        if pn.file?
          @content = File.read(pn)
          @obj.concat(YAML.safe_load(@content))
        else
          @obj.concat(find_by_popen3(pn))
        end
      end
    end
    
    def find_by_popen3(start_path)
      stdin, stdout, stderr = *Open3.popen3("find #{start_path} -name .git ")
      listup(stdout)
    end

    def listup(io)
      xhs = {}
      while line = io.gets
        line.chomp!
        pn = Pathname.new(line)
        # p pn
        pp_pn = pn.parent.parent
        xhs[pp_pn.to_s] = pp_pn
      end

      filename_base = "gitx_hr_"
      xhs.keys.map{ |path|
        pn = xhs[path]
        hs = {}
        str = pn.relative_path_from(@home_pn).to_s
        hs["paths"] = str.split('/')
        hs["filename_base"] = filename_base
        @obj << hs
      }
      @obj
    end

    def get_and_upload
      @obj.each{ |hash|
        content = gitx_repo(@home_pn, hash)
        if content
          count = Util.get_count()
          filename = [ hash["filename_base"] , count , ".csv" ].join("")
          #
          puts filename
          puts content
#=begin
          @gsession ||= Gsession.new()
          result = @gsession.upload_from_string(content, filename)
          Util.file_append(@log_filename, result) if result
#=end
        end
      }
    end

    def list_repo(src_pn)
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

    def gitx_repo(home_pn, value)
      pn = home_pn
      value["paths"].each do |name|
        pn = pn + name
      end
      get_git_repo_info(pn)
    end

    def get_repo_info_list_in_csv(pn)
      # ary = []
      head_line, ary = list_repo(pn).each_with_object([[0],  []]){ |item, memo|
        # item.show
        head_line = memo[0]
        ary = memo[1]
        if head_line[0] == 0
          ary << item.to_csv_header
          head_line[0] = 1
        end
        ary << item.to_csv_data
      }
      ary
    end

    def get_git_repo_info(pn)
      content = nil
      content_array = get_repo_info_list_in_csv(pn)
      if content_array.size > 0
        content = content_array.join("\n")
      end
      content
    end
  end
end