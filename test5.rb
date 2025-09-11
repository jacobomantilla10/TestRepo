{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/usr/bin/env ruby\
require 'json'\
require 'net/http'\
require 'sqlite3'\
require 'thread'\
\
# ---------------- LOGGER MODULE ----------------\
module Logger\
  def log(message)\
    puts "[#\{Time.now.strftime('%H:%M:%S')\}] #\{message\}"\
  end\
end\
\
# ---------------- ALERT MANAGER ----------------\
class AlertManager\
  include Logger\
\
  def initialize(webhook_url)\
    @webhook_url = URI(webhook_url)\
  end\
\
  def send_alert(message, severity)\
    payload = \{ text: "[#\{severity\}] #\{message\}" \}.to_json\
    begin\
      Net::HTTP.post(@webhook_url, payload, "Content-Type" => "application/json")\
      log("Alert sent: #\{message\}")\
    rescue => e\
      log("Failed to send alert: #\{e\}")\
    end\
  end\
end\
\
# ---------------- DATABASE HANDLER ----------------\
class LogDatabase\
  include Logger\
\
  def initialize(db_file = "logs.db")\
    @db = SQLite3::Database.new(db_file)\
    setup\
  end\
\
  def setup\
    @db.execute <<~SQL\
      CREATE TABLE IF NOT EXISTS log_stats (\
        id INTEGER PRIMARY KEY AUTOINCREMENT,\
        timestamp TEXT,\
        level TEXT,\
        message TEXT\
      );\
    SQL\
  end\
\
  def insert(level, message)\
    @db.execute("INSERT INTO log_stats (timestamp, level, message) VALUES (?, ?, ?)",\
                [Time.now.to_s, level, message])\
  end\
end\
\
# ---------------- LOG MONITOR ----------------\
class LogMonitor\
  include Logger\
\
  LEVELS = \{\
    error: /ERROR/,\
    warning: /WARN/,\
    info: /INFO/\
  \}\
\
  def initialize(file_path, alert_manager, db)\
    @file_path = file_path\
    @alert_manager = alert_manager\
    @db = db\
    @queue = Queue.new\
  end\
\
  def start\
    Thread.new \{ watch_file \}\
    Thread.new \{ process_queue \}\
  end\
\
  private\
\
  def watch_file\
    File.open(@file_path, "r") do |file|\
      file.seek(0, IO::SEEK_END) # start at end like tail -f\
      loop do\
        line = file.gets\
        if line\
          @queue << line.strip\
        else\
          sleep 0.2\
        end\
      end\
    end\
  end\
\
  def process_queue\
    loop do\
      line = @queue.pop\
      LEVELS.each do |level, regex|\
        if line.match?(regex)\
          log("Detected #\{level.to_s.upcase\}: #\{line\}")\
          @db.insert(level.to_s, line)\
          if [:error, :warning].include?(level)\
            @alert_manager.send_alert(line, level.to_s.upcase)\
          end\
        end\
      end\
    end\
  end\
end\
\
# ---------------- MAIN ----------------\
if __FILE__ == $0\
  webhook = "https://httpbin.org/post" # Replace with Slack/Discord webhook\
  log_file = "application.log"\
\
  # Ensure log file exists\
  File.write(log_file, "", mode: "a")\
\
  alert_manager = AlertManager.new(webhook)\
  db = LogD\
}
