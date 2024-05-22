require 'http'

module Vandelay
  module Services
    class PatientRecords
      def self.retrieve_record_for_patient(patient)
        records_vendor = patient['records_vendor']
        vendor_id = patient['vendor_id']
  
        return 'This patient has no records.' if records_vendor.nil? || vendor_id.nil?
  
        # Call the records Api by record vendor name
        case records_vendor
        when 'one'
          retrieve_records_from_api_one(patient)
        when 'two'
          retrieve_records_from_api_two(patient)
        else
          'Invalid vendor.'
        end
      end
  
      def self.retrieve_records_from_api_one(patient)
        # get the records from record vendor one
        token_data = retrieve_token('http://mock_api_one/auth/1')
        return token_data unless token_data.is_a?(Hash)
  
        token = token_data['token']
        records_res = get_records("http://mock_api_one/patients/#{patient['vendor_id']}", token)
  
        return records_res unless records_res.is_a?(Hash)
  
        {
          'patient_id': patient['id'],
          'province': records_res['province'],
          'allergies': records_res['allergies'],
          'num_medical_visits': records_res['recent_medical_visits']
        }
      end
  
      def self.retrieve_records_from_api_two(patient)
        # get the records from record vendor two
        token_data = retrieve_token('http://mock_api_two/auth_tokens/1')
        return token_data unless token_data.is_a?(Hash)
  
        token = token_data['token']
        records_res = get_records("http://mock_api_two/records/#{patient['vendor_id']}", token)
  
        return records_res unless records_res.is_a?(Hash)
  
        {
          'patient_id': patient['id'],
          'province': records_res['province_code'],
          'allergies': records_res['allergies_list'],
          'num_medical_visits': records_res['medical_visits_recently']
        }
      end
  
      def self.retrieve_token(token_url)
        token_res = HTTP.get(token_url)
        return "Failed to retrieve token: #{token_res.code}" unless token_res.code == 200
  
        token_res.parse
      end
  
      def self.get_records(records_url, token)
        records_res = HTTP.headers("Authorization" => "Bearer #{token}").get(records_url)
        return "Failed to retrieve records: #{records_res.code}" unless records_res.code == 200
  
        records_res.parse
      end  
    end
  end
end