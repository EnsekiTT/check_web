require 'bundler/setup'
require 'capybara/poltergeist'
require 'csv'
require 'diffy'
require 'slack/incoming/webhooks'
Bundler.require

CURRENT = "./"
TARGET_CSV = CURRENT + "target.csv" #STDIN.gets
TEMP = CURRENT + "temp/"
ARCHIVE = CURRENT + "archive/"

def slack(msg, address)
  slack = Slack::Incoming::Webhooks.new ENV["WEBHOOK_URL"]

  attachments = [{
  title: "新しい変更があったみたい",
  title_link: address,
  text: msg,
  color: "#7CD197"
  }]
  slack.post "変更通知だよ", attachments: attachments
end

# カピバラのインスタンスを作成する
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {inspector: true, js_errors: false, timeout: 1000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any']})
end
session = Capybara::Session.new(:poltergeist)
# CSVを読み込み
csv_data = CSV.read(TARGET_CSV, headers: true)

# CSV1行ごとに繰り返し
csv_data.each do |data|
  current = ""
  last = ""
  if data["id"] == "" then
    break
  end
  puts data["id"]
  session.visit data["address"]
  File.open(TEMP + "TEMP", "w"){ |f| f.puts session.find(data["selector"]).text }
  File.open(TEMP + "TEMP", "r") do |f|
    current = f.read
  end
  if File.exist?(TEMP + data["id"]) then
     File.open(TEMP + data["id"], "r") do |f|
       last = f.read
       @diffs = Diffy::Diff.new(last, current)
       if @diffs.to_s.length > 0 then
	        slack(@diffs.to_s, data["address"])
       end
     end
  end
  File.open(TEMP + data["id"], "w"){ |f| f.puts current }
  File.open(ARCHIVE + data["id"] + "_" + Time.now.strftime("%y%m%d_%H%M%S"), "w"){ |f| f.puts current }
end
