# frozen_string_literal: true

class DatasetFile
  attr_accessor :name, :description, :format, :size, :display_size, :mime_type, :sequence, :handle, :extension,
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
    file.display_size = ActiveSupport::NumberHelper.number_to_human_size(file.size)
    file.sequence = (hash[:sequence] || "").to_i
    # Technically the handle is a property of the dataset item rather than the file (aka bitstream)
    # but we store it at the file level for convenience.
    file.handle = hash[:handle]
    file.download_url = "#{DatasetFile.download_root}/#{file.handle}/#{file.sequence}"
    file
  end

  # hash[:filename]     "10.123/4567/40/folder1/filename1.txt"
  # full_path           "folder1/filename1.txt"
  def self.from_hash_describe(data)
    hash = data.with_indifferent_access
    file = DatasetFile.new
    file.source = "pdc_describe"
    file.full_path = filename_without_doi(hash[:filename])        # folder1/hello.txt
    file.name = File.basename(file.full_path)                     # hello.txt
    file.extension = File.extname(file.name)
    file.extension = file.extension[1..] if file.extension != "." # drop the leading period
    file.size = hash[:size]
    file.display_size = hash[:display_size]
    file.download_url = hash[:url]
    file
  end

  # Calculates the display filename for a PDC Describe file.
  # PDC Describe files are prefixed with DOI + database_id, for example "10.123/4567/40/folder1/filename1.txt"
  # (where 40 is the database id).
  # This method strips the DOI and the database ID from the path so that we display a friendly
  # path to the user, e.g. "folder1/filename1.txt".
  #
  # full_path          "10.123/4567/40/folder1/filename1.txt"
  # filename_no_doi  = "/40/folder1/filename1.txt"
  # db_id            = "40"
  # display_filename = "/folder1/filename1.txt"
  def self.filename_without_doi(full_path)
    prefix = full_path.split("/").take(3).join("/") # DOI + db id
    full_path[prefix.length+1..-1]
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
