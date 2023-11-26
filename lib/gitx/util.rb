module Gitx
  class Util
    @count = 0

    class << self
      def file_append(fname, str)
        File.open(fname, 'a'){ |file|
          file.puts str + "\n"
        }
      end

      def get_count()
        count = @count
        @count += 1
        count
      end
    end
  end
end
