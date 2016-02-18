#!/usr/bin/env ruby
# encoding: utf-8
require 'json'
require 'pp'
class SmileGetter

  TOKEN='Please set your token :)'

  def self.score(images)
    param = images.map{|img| %Q{-F "inputFile=@#{img}"}}.join(" ")
    json = `curl -X POST -s -H 'Content-type: multipart/form-data' #{param}  "https://api.apigw.smt.docomo.ne.jp/puxImageRecognition/v1/faceDetection?APIKEY=#{TOKEN}&response=json"`

    response = JSON.parse(json)
    return false if response["results"]["faceRecognition"]["errorInfo"] == "NoFace"

    smile_score =  response["results"]["faceRecognition"]["detectionFaceInfo"][0]["smileJudge"]["smileLevel"]

    if smile_score > 40
      return true
    else
      return false
    end
  end
end
