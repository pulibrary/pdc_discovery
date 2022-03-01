# frozen_string_literal: true
module UsageHelper
  def downloads(files)
    files.map(&:downloads).inject(0, :+).to_s
  end
end
