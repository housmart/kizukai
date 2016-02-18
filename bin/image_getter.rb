#!/usr/bin/env ruby
# encoding: utf-8

# 1. install gem
# bundle install --path vendor/bundle
# 2. run with following command
# bundle exec bin/image_getter.rb run

require 'net/http'
require 'json'

HTTP_READ_TIMEOUT = 180
INTERVAL = 30
RECOVERY_INTERVAL = 5
DATA_DIR = "#{Dir.pwd}/data/image_getter"

class ThetaController
  def initialize
    @http = Net::HTTP.new('192.168.1.1', 80)
    @http.read_timeout = HTTP_READ_TIMEOUT unless HTTP_READ_TIMEOUT.nil?
  end
  def get_info
    JSON.parse(@http.get('/osc/info').body)
  end
  def get_state
    JSON.parse(@http.post('/osc/state', '').body)
  end
  def set_options(option_hash)
    params = {name: "camera.setOptions", parameters: {sessionId: @session_id, options: option_hash}}.to_json
    puts params
    execute_command(params)
  end
  def get_options(option_array)
    params = {name: "camera.getOptions", parameters: {sessionId: @session_id, optionNames: option_array}}.to_json
    JSON.parse(execute_command(params).body)
  end
  def execute_command(params)
    @http.post('/osc/commands/execute', params)
  end
  def start_session
    puts "start session"
    params = {name: "camera.startSession", parameters: {}}.to_json
    res = execute_command(params)
    @session_id = JSON.parse(res.body)["results"]["sessionId"]
    puts "session_id : #{@session_id}"
  end
  def update_session
    params = {name: "camera.updateSession", parameters: {sessionId: @session_id}}.to_json
    res = execute_command(params)
    @session_id = JSON.parse(res.body)["results"]["sessionId"]
  end
  def close_session
    puts "close session"
    params = {name: "camera.closeSession", parameters: {sessionId: @session_id}}.to_json
    execute_command(params)
  end
  def take_pic
    puts "take a picture"
    params = {name: "camera.takePicture", parameters: {sessionId: @session_id}}.to_json
    execute_command(params)
  end
  def get_last_file_uri
    get_state["state"]["_latestFileUri"]
  end
  def cp_last_pic(local_path)
    file_uri = get_last_file_uri
    puts "downloading... #{file_uri} to #{local_path}"
    params = {name: "camera.getImage", parameters: {fileUri: file_uri}}.to_json
    res = execute_command(params)
    open(local_path, "wb") {|f| f.write(res.body)}
    file_uri
  end
  def mv_last_pic(local_path)
    file_uri = cp_last_pic(local_path)
    delete_pic(file_uri)
  end
  def delete_pic(file_uri)
    params = {name: "camera.delete", parameters: {fileUri: file_uri}}.to_json
    execute_command(params)
  end
end

loop {
  begin
    puts "Start taking pic : #{Time.now}"
    theta = ThetaController.new
    theta.start_session
    # tuning_option_hash =  {fileFormat: {type: 'jpeg', width: 2048, height: 1024}, _wlanChannel: 6, _filter: 'off'}
    tuning_option_hash =  {fileFormat: {type: 'jpeg', width: 2048, height: 1024}}
    theta.set_options(tuning_option_hash)
    puts theta.get_options(['fileFormat', 'fileFormatSupport', '_wlanChannel', '_filter'])
    theta.take_pic
    theta.mv_last_pic("#{DATA_DIR}/#{Time.now.to_i}.jpg")
    theta.close_session
    puts "Finish taking pic : #{Time.now}"
    sleep INTERVAL
  rescue => e
    puts e.message
    sleep RECOVERY_INTERVAL
  end
}

