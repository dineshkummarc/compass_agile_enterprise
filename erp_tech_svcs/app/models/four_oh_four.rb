class FourOhFour < ActiveRecord::Base
  def self.add_request(url, remote_address, referer)
    begin
      request = self.where("url = ? AND referer = ? AND remote_address = ?", url, referer, remote_address).first

      if request.nil?
        request = self.create(:url => url, :referer => referer, :remote_address => remote_address)
      end

      request.count += 1
      request.save
    rescue
    end
  end
end

