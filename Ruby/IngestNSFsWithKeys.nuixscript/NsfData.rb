class NsfData
	attr_accessor :evidence_container_name
	attr_accessor :nsf_file_path
	attr_accessor :id_file_path
	attr_accessor :id_file_password

	def self.load_csv(csv_file_path)
		result = []
		require 'csv'
		CSV.foreach(csv_file_path,{:headers => :first_row}) do |row|
			data = NsfData.new
			data.evidence_container_name = row[0]
			data.nsf_file_path = row[1]
			data.id_file_path = row[2]
			data.id_file_password = row[3]
			result << data
		end
		return result
	end

	def add_to_processor(processor)
		evidence_container = processor.newEvidenceContainer(@evidence_container_name)
		evidence_container.addFile(@nsf_file_path)
		evidence_container.save
		id_file = java.io.File.new(@id_file_path)
		processor.addKeyStore(id_file,{
			"filePassword" => @id_file_password,
			#"target" => @nsf_file_path,
			"target" => "*",
		})
	end

	def to_s
		s = "Evidence Container Name: #{@evidence_container_name}\n"
		s << "NSF File Path: #{@nsf_file_path}\n"
		s << "ID File Path: #{@id_file_path}"
		return s
	end
end