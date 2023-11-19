module Gitx
  class Util
    class << self
      def file_append(fname, str)
        File.open(fname, 'a'){ |file|
          file.puts str + "\n"
        }
      end
    end
  end
end
