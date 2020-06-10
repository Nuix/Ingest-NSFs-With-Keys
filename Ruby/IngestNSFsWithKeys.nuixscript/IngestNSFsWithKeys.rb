# Menu Title: Ingest NSFs with Keys
# Needs Case: true

script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"

load File.join(script_directory,"NsfData.rb")

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

dialog = TabbedCustomDialog.new("Ingest NSF with Keys")

main_tab = dialog.addTab("main_tab","Main")
main_tab.appendOpenFileChooser("input_csv","Input CSV","Comma Separated Values","csv")
main_tab.appendHeader("Worker Settings")
main_tab.appendTextField("worker_count","Worker Count","4")
main_tab.appendTextField("worker_memory","Worker Memory","768")
main_tab.appendDirectoryChooser("worker_temp","Worker Temp")
main_tab.setText("worker_temp","C:\\workerTemp")

dialog.validateBeforeClosing do |values|
	input_csv_file = java.io.File.new(values["input_csv"])
	if !input_csv_file.exists
		CommonDialogs.showError("Please select a valid input csv file.")
		next false
	end

	if values["worker_count"].strip.empty? || values["worker_count"].to_i < 1
		CommonDialogs.showError("Please provide a valid worker count value.")
		next false
	end

	if values["worker_memory"].strip.empty? || values["worker_memory"].to_i < 768
		CommonDialogs.showError("Please provide a valid worker memory value greater than or equal to 768.")
		next false
	end

	if values["worker_temp"].strip.empty?
		CommonDialogs.showError("Please provide a valid worker temp directory.")
		next false
	end

	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap
	
	ProgressDialog.forBlock do |pd|
		pd.setSubProgressVisible(false)
		pd.setAbortButtonVisible(false)
		nsfs = NsfData.load_csv(values["input_csv"])
		if nsfs.size < 1
			pd.logMessage("Input CSV contains no records.")
		else
			pd.logMessage("NSF Entries: #{nsfs.size}")
			processor = $current_case.createProcessor
			require 'json'
			settings_file = "#{File.dirname(__FILE__)}\\Settings.json"
			pd.logMessage("Loading Settings from: #{settings_file}")
			settings = JSON.parse(File.read(settings_file))
			settings["processingSettings"]["reportProcessingStatus"] = "physical_files"

			pd.logMessage("=== Processing Settings ===")
			settings["processingSettings"].each do |k,v|
				pd.logMessage("\t#{k} = #{v}")
			end

			parallel_processing_settings = {
				"workerCount" => values["worker_count"],
				"workerMemory" => values["worker_memory"],
				"workerTemp" => values["worker_temp"],
			}

			pd.logMessage("=== Parallel Processing Settings ===")
			parallel_processing_settings.each do |k,v|
				pd.logMessage("\t#{k} = #{v}")
			end

			processor.setProcessingSettings(settings["processingSettings"])
			processor.setParallelProcessingSettings(parallel_processing_settings)

			nsfs.each_with_index do |nsf_data,index|
				pd.logMessage("===== #{index+1}/#{nsfs.size} =====")
				pd.logMessage(nsf_data.to_s)
				pd.logMessage("Adding to processor...")
				nsf_data.add_to_processor(processor)
			end

			approx_item_count = 0
			require 'thread'
			semaphore = Mutex.new
			last_progress = Time.now
			processor.whenItemProcessed do |info|
				semaphore.synchronize {
					approx_item_count += 1
				}
			end

			processor.whenProgressUpdated do |info|
				if (Time.now - last_progress) > 1
					pd.setSubStatus("Approximate Items: #{approx_item_count}")
					current_size_mb = info.getCurrentSize.to_f / (1000.0 ** 2)
					total_size_mb = info.getTotalSize.to_f / (1000.0 ** 2)
					pd.setMainProgress(current_size_mb.ceil,total_size_mb.ceil)
				end
			end

			pd.logMessage("\nBeginning processing...")
			pd.setMainStatus("Processing")
			processor.process
			pd.setMainStatusAndLogIt("Processing Completed")
			pd.setSubStatus("")
		end
	end
end