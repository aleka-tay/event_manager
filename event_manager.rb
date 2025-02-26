require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# A small note, when running the file from project directory with bundle,
# include the full name of the files that need to be read
contents = CSV.open('project_manager/lib/event_attendees.csv', headers: true, header_converters: :symbol)
template_letter = File.read('project_manager/lib/form_letter.erb')
erb_template = ERB.new template_letter
puts 'Event Manager Initialization.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislator_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislator_by_zipcode(zipcode)
  # personal_letter = template_letter.gsub('FIRST_NAME', name)  gsub substitutes first parameter with second one
  # personal_letter.gsub!('LEGISLATORS', legislators)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end
