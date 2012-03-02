module ErpTechSvcs
  module SmsWrapper
    class Clickatell
      attr_accessor :api

      def initialize()
        configuration = YAML::load_file(File.join(Rails.root,'config','clickatell.yml'))[Rails.env]
        @api = ::Clickatell::API.authenticate(configuration['api_id'].to_s, configuration['username'], configuration['password'])
      end

      def send_message(phone_number, message, options={})
        phone_number = phone_number.insert(0,'1') if phone_number.length == 10
       
        result = nil
        begin
          result = @api.send_message(phone_number, message, options)
        rescue ::Clickatell::API::Error=>ex
          Rails.logger.error("Clickatell Error:#{ex.message}")
        end
        result
      end

    end
  end
end