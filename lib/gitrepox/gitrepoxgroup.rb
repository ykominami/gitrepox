module Gitrepox
  class Gitrepoxgroup
    def initialize(home_pn, log_filename, yaml_fname_or_start_path_array)
      @home_pn = home_pn
      @log_filename = log_filename
      @obj = []
      # p "yaml_fname_or_start_path_array=#{yaml_fname_or_start_path_array}"
      yaml_fname_or_start_path_array.each do |yaml_fname_or_start_path|
        pn = Pathname.new(yaml_fname_or_start_path)
        # p "initialize pn=#{pn}"
        if pn.file?
          make_parent_pn_info_from_yaml_file(pn)
          # @content = File.readlines(pn).map{ |line| line.chomp }.join("\n")
        else
          # @obj.concat(find_by_popen3(pn))
          # p "initialize pn=#{pn}"
          @obj += find_git(pn)
          # p "init @obj=#{@obj}"
        end
      end
    end

    def make_parent_pn_info_from_yaml_file(yaml_pn)
      @content = File.read(yaml_pn)
      # p @content
      # obj = YAML.safe_load(@content, symbolize_names: true)
      # obj = YAML.safe_load(@content, aliases: true)
      obj = YAML.safe_load(@content, permitted_classes: [Symbol])
      obj.each_key do |filename_base|
        obj[filename_base].each do |hash|
          hs = {}
          path = File.join(hash['paths'])
          pn = Pathname.new(path)
          str = pn.relative_path_from(@home_pn).to_s
          hs['paths'] = str.split('/')
          hs['filename_base'] = filename_base
          @obj << hs
        end
      end
    end

    def find_git(start_pn)
      # p "find_git start_pn=#{start_pn}"
      dir_pns = []
      git_pns = []
      start_pn.children.each do |item|
        name = item.basename.to_s
        git_pns << item if name =~ /^\.git$/
        dir_pns << item if item.directory?
      end
      if git_pns.empty?
        dir_pns.each do |dir_pn|
          git_pns += find_git(dir_pn)
        end
      end
      # p "find_git git_pns=#{git_pns}"
      git_pns
    end

    def find_by_popen3(start_path)
      _, stdout, = *Open3.popen3("find #{start_path} -name .git ")
      listup(stdout)
    end

    def listup(io)
      xhs = {}
      while (line = io.gets)
        line.chomp!
        pn = Pathname.new(line)
        # p pn
        pp_pn = pn.parent.parent
        xhs[pp_pn.to_s] = pp_pn
      end

      filename_base = 'gitx_hr_'
      xhs.keys.map  do |path|
        pn = xhs[path]
        hs = {}
        str = pn.relative_path_from(@home_pn).to_s
        hs['paths'] = str.split('/')
        hs['filename_base'] = filename_base
        @obj << hs
      end
      @obj
    end

    def listup_in_pathname_array(pn_array)
      xhs = {}
      pn_array.each do |pn|
        pp_pn = pn.parent.parent
        xhs[pp_pn.to_s] = pp_pn
      end

      make_parent_pn_info(xhs)
    end

    def make_parent_pn_info(xhs)
      filename_base = 'gitx_hr_'
      xhs.keys.map  do |path|
        pn = xhs[path]
        hs = {}
        str = pn.relative_path_from(@home_pn).to_s
        hs['paths'] = str.split('/')
        hs['filename_base'] = filename_base
        @obj << hs
      end
      @obj
    end

    def get_and_upload
      @obj.each do |hash|
        content = gitrepox_repo(@home_pn, hash)
        next unless content

        count = Util.get_count
        filename = [hash['filename_base'], count, '.csv'].join('')
        @gsession ||= Gsession.new
        result = @gsession.upload_from_string(content, filename)
        Util.file_append(@log_filename, result) if result
      end
    end

    def list_repo(src_pn)
      return [] if src_pn.file?

      parts = src_pn.children.map do |pn|
        [pn, "#{pn}.git"]
      end.partition do |pns|
        pns[1].exist?
      end
      parts[0].select do |pns|
        x = pns[0]
        g = Gitrepox.new(x)
        pns << g
        x.exist?
      end.map  do |pns|
        item = pns.first.basename
        full_path = pns.first.realpath
        g = pns.last
        remotes = g.get_remotes
        next unless remotes.size.positive?

        remotes.map do |gr|
          g.data[gr.name] = {}
          g.data[gr.name][:full_path] = full_path
          g.data[gr.name][:basename] = item
          g.data[gr.name][:url] = gr.url
          g.data[gr.name][:fetch_opts] = gr.fetch_opts
        end
        g
      end.select { |item| !item.nil? }
    end

    def gitrepox_repo(home_pn, value)
      pn = home_pn
      if value.instance_of?(Hash)
        value['paths'].each do |name|
          pn += name
        end
      else
        pn = value
      end
      get_git_repo_info(pn)
    end

    def get_repo_info_list_in_csv(pn)
      # ary = []
      _, ary = list_repo(pn).each_with_object([[0], []]) do |item, memo|
        # item.show
        head_line = memo[0]
        ary = memo[1]
        if (head_line[0]).zero?
          ary << item.to_csv_header
          head_line[0] = 1
        end
        ary << item.to_csv_data
      end
      ary
    end

    def get_git_repo_info(pn)
      content = nil
      content_array = get_repo_info_list_in_csv(pn)
      content = content_array.join("\n") if content_array.size.positive?
      content
    end
  end
end
