module Gitrepox
  class Util
    @count = 0

    class << self
      def file_append(fname, str)
        File.open(fname, 'a') do |file|
          file.puts "#{str}\n"
        end
      end

      def get_count
        count = @count
        @count += 1
        count
      end
    end
  end
end
