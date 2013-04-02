#!/usr/bin/env ruby
require 'open-uri'
require 'digest/md5'
require 'json'

CONFIG_FILE = 'config.json'
DB_FILE     = 'db.json'

# Make sure the configuration file exits.
unless File.exists?(CONFIG_FILE)
   puts "ERROR: The configuration file `#{CONFIG_FILE}` does not exist."
   exit
end

# Make sure the cnfiguration file is not empty.
if File.zero?(CONFIG_FILE)
   puts "ERROR: The configuration file `#{CONFIG_FILE}` is emtpy. Did you forget to set it up?"
   exit
end

# Read in the configuration file and attempt to parse it.
config = File.open(CONFIG_FILE, 'r') { |file|
   JSON.parse(file.read)
}

# Read in the database file and attempt to parse it.
File.new(DB_FILE, 'w+') unless File.exists?(DB_FILE)
db = File.open(DB_FILE,'r+') { |file|
   (file.size > 0) ?  JSON.parse(file.read) : {}
}

# Loop through each website in our configuration and see if it's updated.
config['websites'].each do |site, options|
   # Is the site already in the database?
   if db.has_key?(site)
      # Make sure we don't check websites too frequently.
      time_since = DateTime.now - DateTime.parse(db[site]['lastcheck'])
      time_since = time_since * 24 * 60

      if time_since.to_i < options['frequency']
         # puts "Should not check #{site} for update."
         next
      end
   else
      puts "Adding #{site} to the database."
      db[site] = {}
   end

   # Update the MD5 for any remaining websites.
   md5 = open(site) do |data|
      Digest::MD5.hexdigest(data.read)
   end

   if db[site].has_key?('md5') && db[site]['md5'] != md5
      puts "ALERT: #{options['alert']}"
   end

   db[site]['md5'] = md5
   db[site]['lastcheck'] = DateTime.now.to_s
end

# Save the updated database.
File.write(DB_FILE, JSON.generate(db))