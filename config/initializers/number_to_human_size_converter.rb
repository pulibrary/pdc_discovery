# frozen_string_literal: true
# Source: https://github.com/rails/rails/issues/40054#issuecomment-674449143
# Additional information: https://massive.io/file-transfer/gb-vs-gib-whats-the-difference/
module ActiveSupport
  module NumberHelper
    class NumberToHumanSizeConverter < NumberConverter
      private

        # Allows a base to be specified for the conversion
        # 1024 was the default and that produces gigibytes
        # 1000 produces gigabytes
        def base
          options[:base] || 1000
        end
    end
  end
end
