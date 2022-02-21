require "csv"
require 'net/http'
require 'json'

class EpochConverter
  attr_accessor :url, :data, :csv_file_name, :page
  CSV_ATTRIBUTES = %w(hash Timestamp toAddress confirmed revert amount fee tokenAbbr tokenName tokenDecimal tokenType).freeze

  def initialize(start_date, end_date, address, csv_file_name, page)
    @page = page
    @data = []
    @address = address
    @start_date = start_date
    @end_date = end_date
    @csv_file_name = csv_file_name
  end

  def execute
    begin
      puts "Start get data #{Time.now}"
      while true
        data_epoch = parse_data
        unless data_epoch.nil?
          @page += 1
          @data.push(*data_epoch)
        else
          break
        end
      end
      export_csv
      puts "Finish get and export csv data #{Time.now}"
    rescue
      raise
    end
  end

  private
  def parse_data
    url = "https://apilist.tronscan.org/api/transaction?sort=-timestamp&count=true&limit=50&start=#{@page}&address=#{@address}&start_timestamp=#{@start_date}&end_timestamp=#{@end_date}"
    puts "Current page: #{@page}, url: #{url}"
    JSON.parse(Net::HTTP.get(URI(url))).dig('data')
  end

  def export_csv
    CSV.open("#{@csv_file_name}.csv", "wb") do |csv|
      csv << CSV_ATTRIBUTES
      @data.uniq.each do |item|
        csv << [
          item.dig('hash'),
          item.dig('timestamp'),
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
page = 0  # start page 0

epoch = EpochConverter.new(start_timestamp, end_timestamp, address, csv_file_name, page)
epoch.execute
