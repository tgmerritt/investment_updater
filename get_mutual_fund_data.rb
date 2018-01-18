#!/usr/bin/env ruby

require 'mechanize'
require 'csv'
require 'google_drive'
require 'pry'

class GetMutualFundData

  def initialize
    present_menu
  end

  def present_menu
    puts "Welcome to the Investment Updater Utility"
    puts "Please choose from the following options:"
    puts "1. Update Mutual Fund Data"
    puts "Q to quit"
    get_first_choice
  end

  def get_first_choice
    input = "1" # If we add more options, revert to line 24
    # input = gets.chomp
    analyze_first_choice(input)
  end

  def analyze_first_choice(input)
    if input == "1"
      set_session
      update_ticker_data
    elsif input == "2"
      run_api_menu
    elsif input == "3"
      run_fake_data
    elsif "Q".casecmp(input) == 0
      exit
    else
      you_screwed_up
    end
  end

  private

  def update_ticker_data
    puts "Updating the spreadsheet"

    tickers = parse_tickers
    # t       = tickers[0] # THIS IS FOR TESTING
    tickers.each do |t|
      puts "Getting data for #{t}"
      page = get_page_data(t)
      update_style_cells(modify_style_data(page), t) # Morningstar Style section
      update_size_cells(modify_market_cap_data(page), t) # Market Cap section
      update_sector_weights(modify_sector_weightings_data(page), t) # Sector Weightings section
      update_markets(modify_markets(page), t)
    end

    @ws.save

    puts "Finished!"
  end

  def modify_style_data(page)
    data = page.xpath('//table[@id="asset_allocation_tab"]/tbody').text.split(/[\n\t]+/)
    data.each { |s| s.gsub!(/\s+/, '') }
    data = clear_empty(data)
    data = slice_array(data, 6)
    data
  end

  def modify_markets(page)
    data = page.xpath('//table[@id="world_regions_tab"]/tbody/tr[td//text()[contains(., "% Emerging Markets")]]').text.split(/[\n\t]+/)
    data.each do |s|
      s.gsub!(/\s+/, '')
    end
    data = clear_empty(data)
    data
  end

  def modify_sector_weightings_data(page)
    data = page.xpath('//table[@id="sector_we_tab"]/tbody').text.split(/[\n\t]+/)
    data.each { |s| s.gsub!(/\s+/, '') }
    data = clear_empty(data)
    data = slice_array(data, 17)
    data
  end

  def modify_market_cap_data(page)
    data = page.xpath('//table[@id="equity_style_tab"]/tbody').text.split(/[\n\t\s*]+/)
    data = clear_empty(data)
    data = data.map { |e| e =~ /[[:alpha:]]/ ? e : e.to_f }
    data = slice_array(data, 4)
    data
  end

  def update_style_cells(data, t)
    # Cash = 1
    # US Stock = 2
    # Foreign Stock = 3
    # Bonds = 4
    # Other = 5

    (1..5).each do |cell|
      e = cell - 1
      @ws.list[cell][t] = data[e][1]
    end
  end

  def update_size_cells(data, t)
    puts "Updating sizing for #{t}"
    # Giant = 8
    # Large = 9
    # Medium = 10
    # Small = 11
    # Micro = 12
    (8..12).each do |cell|
      e                 = cell - 8 # offset back to the first element in the data array
      @ws.list[cell][t] = data[e][1]
    end
  end

  def update_sector_weights(data, t)
    puts "Updating Sector Weights for #{t}"

    @values_array = []
    data.each do |d|
      d.shift
      new_d = d.each_slice(4).to_a
      new_d.each do |c|
        c = c.map { |e| e =~ /[[:alpha:]]/ ? e : e.to_f } # convert string floats to actual floats
        #[["BasicMaterials", "10.37", "7.46", "6.03"], ["ConsumerCyclical", "15.95", "11.91", "13.36"],["FinancialServices", "7.70", "22.89", "23.43"],["RealEstate", "8.14", "2.84", "2.71"]]
        @values_array << c[1]
      end
    end
    set_sector_values(@values_array, t)
  end

  def update_markets(data, t)
    @ws.list[33][t] = data[1] # Set emerging market percentage
  end

  def set_sector_values(array, t)
    # Basic Materials = 16
    # Consumer Cyclical = 17
    # Financial Services = 18
    # Real Estate = 19
    # Comm Services = 22
    # Energy = 23
    # Industrial Materials = 24
    # Technology = 25
    # Consumer Defensive = 28
    # Healthcare = 29
    # Utilities = 30
    array = array.slice(0..array.size-2) # get rid of the last nil in the array - don't need it

    (16..19).each do |cell|
      e                 = cell - 16
      @ws.list[cell][t] = array[e]
    end

    (22..25).each do |cell|
      e                 = cell - 18
      @ws.list[cell][t] = array[e]
    end

    (28..30).each do |cell|
      e                 = cell - 20
      @ws.list[cell][t] = array[e]
    end

  end

  def clear_empty(data)
    data.reject(&:empty?)
  end

  def slice_array(data, size)
    data.each_slice(size).to_a
  end

  def parse_tickers
    get_worksheet_obj
    ws = clear_empty(@ws.rows.first) #@ws is a frozen array, plus it's bad form to modify the Google Sheets object
    ws.shift # pop off the first value
    ws
  end

  def get_page_data(t)
    mechanize = Mechanize.new
    mechanize.get("http://portfolios.morningstar.com/fund/summary?t=#{t}&region=usa&culture=en-US")
  end

  def get_worksheet_obj
    @ws = @session.spreadsheet_by_key("YOUR_GOOGLE_SPREADSHEET_ID_HERE").worksheet_by_title("Funds") # CHANGE TITLE TO CORRECT SHEET AFTER TESTING
  end

  def set_session
    # There must be a config.json file in the same directory for this script to work.  Not checked into version control
    @session = GoogleDrive::Session.from_config("config.json")
  end

end

GetMutualFundData.new



