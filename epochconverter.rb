require "csv"
require 'net/http'
require 'json'

class EpochConverter
  attr_accessor :url, :start_date, :end_date, :address, :data, :csv_file_name
  CSV_ATTRIBUTES = %w(hash toAddress confirmed revert amount fee tokenAbbr tokenName tokenDecimal tokenType).freeze

  def initialize(start_date, end_date, address, csv_file_name)
    @url = "https://apilist.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=50&start=0&address=#{address}&start_timestamp=#{start_date}&end_timestamp=#{end_date}"
    @data = []
    @csv_file_name = csv_file_name
  end

  def execute
    begin
      @data = JSON.parse(Net::HTTP.get(URI(@url))).dig('data')
      export_csv
    rescue
      raise
    end
  end

  private
  def export_csv
    CSV.open("#{@csv_file_name}.csv", "wb") do |csv|
      csv << CSV_ATTRIBUTES
      @data.each do |item|
        csv << [
          item.dig('hash'),
          item.dig('toAddress'),
          item.dig('confirmed'),
          item.dig('revert'),
          item.dig('amount'),
          item.dig('fee'),
          item.dig('tokenInfo', 'tokenAbbr'),
          item.dig('tokenInfo', 'tokenName'),
          item.dig('tokenInfo', 'tokenDecimal'),
          item.dig('tokenInfo', 'tokenType')
        ]
      end
    end
  end
end

start_timestamp = 1635724800000 # 2021/11/1 0:0:0 GMT
end_timestamp = 1640908800000   # 2021/31/1 0:0:0 GMT
address = "TQy5KQuJWhHyCTN5NApKZzBiz2J1TkqntU"
csv_file_name = "epoch"

epoch = EpochConverter.new(start_timestamp, end_timestamp, address, csv_file_name)
epoch.execute
