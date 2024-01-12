# frozen_string_literal: true

class DatasetFile
  attr_accessor :name, :description, :format, :size, :mime_type, :sequence, :handle, :extension,
    :source, :download_url, :full_path

  def self.from_hash(data, data_source)
    if data_source == "pdc_describe"
      from_hash_describe(data)
    else
      from_hash_dataspace(data)
    end
  end

  def self.from_hash_dataspace(data)
    hash = data.with_indifferent_access
    file = DatasetFile.new
    file.source = "dataspace"
    file.full_path = hash[:name]
    file.name = hash[:name]
    file.extension = File.extname(file.name)
    file.extension = file.extension[1..] if file.extension != "." # drop the leading period
    file.description = hash[:description]
    file.mime_type = hash[:mime_type]
    file.size = hash[:size]
    file.sequence = (hash[:sequence] || "").to_i
    # Technically the handle is a property of the dataset item rather than the file (aka bitstream)
    # but we store it at the file level for convenience.
    file.handle = hash[:handle]
    file.download_url = "#{DatasetFile.download_root}/#{file.handle}/#{file.sequence}"
    file
  end

  def self.from_hash_describe(data)
    hash = data.with_indifferent_access
    file = DatasetFile.new
    file.source = "pdc_describe"
    file.full_path = hash[:full_name]
    file.name = hash[:name]
    file.extension = File.extname(file.name)
    file.extension = file.extension[1..] if file.extension != "." # drop the leading period
    file.size = hash[:size]
    file.download_url = hash[:url]
    file
  end

  def self.download_root
    "#{Rails.configuration.pdc_discovery.dataspace_url}/bitstream"
  end

  def self.sort_file_array(file_array)
    sorted_by_name = file_array.sort_by(&:name)
    sorted_file_array = []
    sorted_file_array.concat(sorted_by_name.select { |a| a.name.downcase.include? "readme" })
    sorted_file_array.concat(sorted_by_name.difference(sorted_file_array))
    sorted_file_array
  end
end
