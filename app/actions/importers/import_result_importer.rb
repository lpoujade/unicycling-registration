class Importers::ImportResultImporter < Importers::CompetitionDataImporter
  def process(start_times, processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    raw_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
    is_start_time = start_times || false
    ImportResult.transaction do
      raw_data.each do |raw|
        if build_and_save_imported_result(processor.process_row(raw), raw, @user, @competition, is_start_time)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors << invalid.message
    false
  end

  # Public: Create an ImportResult object.
  # Throws an exception if not valid
  def build_and_save_imported_result(hash, raw, user, competition, is_start_time)
    ImportResult.create!(
      hash.merge(
        raw_data: convert_array_to_string(raw),
        user: user,
        competition: competition,
        is_start_time: is_start_time
      )
    )
  end

  private

  def convert_array_to_string(arr)
    str = "["
    arr.each do |el|
      str += "#{el},"
    end
    str += "]"
    str
  end
end
