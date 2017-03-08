class Importers::ImportResultCsvImporter < Importers::BaseImporter
  def process(file, start_times)
    return false unless valid_file?(file)

    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    ImportResult.transaction do
      raw_data.each do |raw|
        data = upload.convert_array_to_string(raw)
        if ImportResult.build_and_save_imported_result(raw, data, @user, @competition, is_start_time)
          self.num_rows_processed += 1
        end
      end
    end

  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end
end
