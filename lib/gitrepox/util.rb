module Gitrepox
  class Util
    @count = 0
    @temp_count = 0

    class << self
      def file_append(fname, str)
        File.open(fname, "a") do |file|
          file.puts "#{str}\n"
        end
      end

      def get_count
        count = @count
        @count += 1
        count
      end

      def reset_count
        @count = 0
      end

      def make_temp_basename
        count = @temp_count
        @temp_count += 1

        "_tmp_#{count}_"
      end
    end
  end
end
