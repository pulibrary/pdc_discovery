# frozen_string_literal: true

class DatasetFile
  attr_accessor :name, :description, :format, :size, :mime_type, :sequence, :handle, :extension

  def self.from_hash(data)
    hash = data.with_indifferent_access
    file = DatasetFile.new
    file.name = hash[:name]
    file.extension = File.extname(file.name)
    file.extension = file.extension[1..] if file.extension != "." # drop the leading period
    file.description = hash[:description]
    file.mime_type = hash[:mime_type]
    file.size = hash[:size]
    file.mime_type = hash[:mime_type]
    file.sequence = (hash[:sequence] || "").to_i
    # Technically the handle is a property of the dataset item rather than the file (aka bitstream)
    # but we store it at the file level for convenience.
    file.handle = hash[:handle]
    file
  end

  def self.download_root
    "#{Rails.configuration.pdc_discovery.dataspace_url}/bitstream"
  end

  def download_url
    # We use the handle URL from DataSpace (instead of the bitstream/retrieveLink property in DataSpace)
    # when downloading the file because the handle URL provides the proper HTTP headers (e.g. name, mime type)
    # that allows the browser to interpret the file correctly.
    "#{DatasetFile.download_root}/#{handle}/#{sequence}/#{name}"
  end

  # def downloads
  #   2 # TODO: pull from API
  # end
end
