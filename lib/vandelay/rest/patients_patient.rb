require 'vandelay/services/patients'
require 'vandelay/services/patient_records'
require 'vandelay/models/patient'

module Vandelay
  module REST
    module PatientsPatient
      def self.patients_srvc
        @patients_srvc ||= Vandelay::Services::Patients.new
      end

      def self.registered(app)
        # add endpoint code here
        app.get '/patients/:patient_id/record' do
          patient_id = params['patient_id']
          patient = Vandelay::Models::Patient.with_id(patient_id)

          if patient.nil?
            return 'Patient not found. Invalid ID.'
          end
        
          records = Vandelay::Services::PatientRecords.retrieve_record_for_patient(patient)
          json(records)
        end
      end
    end
  end
end
