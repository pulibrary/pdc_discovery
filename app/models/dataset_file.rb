# frozen_string_literal: true

class DatasetFile
  attr_accessor :name, :description, :format, :size, :display_size, :mime_type, :sequence, :handle, :extension,
    :source, :download_url, :full_path

  def self.from_hash(data, _data_source)
    from_hash_describe(data)
  end

  def self.from_hash_describe(data)
    hash = data.with_indifferent_access
    file = DatasetFile.new
    file.source = "pdc_describe"
    file.full_path = filename_without_doi(hash[:filename])        # folder1/hello.txt
    file.name = File.basename(file.full_path)                     # hello.txt
    file.extension = File.extname(file.name)
    file.extension = file.extension[1..] if file.extension != "." # drop the leading period
    file.size = hash[:size]
    file.display_size = ActiveSupport::NumberHelper.number_to_human_size(file.size)
    file.download_url = hash[:url]
    file
  end

  # Calculates the display filename for a PDC Describe file.
  # PDC Describe files are prefixed with DOI + database_id, for example "10.123/4567/40/folder1/filename1.txt"
  # (where 40 is the database id).
  # This method strips the DOI and the database ID from the path so that we display a friendly
  # path to the user, e.g. "folder1/filename1.txt".
  #
  # full_path = "10.123/4567/40/folder1/filename1.txt"
  # returns "folder1/filename1.txt"
  def self.filename_without_doi(full_path)
    return "" if full_path.nil?
    tokens = full_path.split("/").compact_blank
    if tokens.length > 2
      prefix = tokens.take(3).join("/") # DOI + db id
      database_id = tokens[2]
      if database_id.to_i != 0
        full_path[prefix.length + 1..-1]
      else
        full_path
      end
    else
      full_path
    end
  end

  def self.sort_file_array(file_array)
    sorted_by_name = file_array.sort_by(&:name)
    sorted_file_array = []
    sorted_file_array.concat(sorted_by_name.select { |a| a.name.downcase.include? "readme" })
    sorted_file_array.concat(sorted_by_name.difference(sorted_file_array))
    sorted_file_array
  end
end
