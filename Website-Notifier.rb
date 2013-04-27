#!/usr/bin/env ruby
#
# Copyright (c) 2013 Matthew Price, http://mattprice.me/
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'digest/md5'
require 'json'
require 'open-uri'
require 'terminal-notifier'
require 'yaml'

CONFIG_FILE = 'config.yml'
DB_FILE     = 'db.json'

# Make sure the configuration file exits.
unless File.exists? CONFIG_FILE
   TerminalNotifier.notify(
      "ERROR: The configuration file `#{CONFIG_FILE}` does not exist.",
      :title => 'Website Notifier'
   )

   # puts "ERROR: The configuration file `#{CONFIG_FILE}` does not exist."
   exit
end

# Make sure the cnfiguration file is not empty.
if File.zero? CONFIG_FILE
   TerminalNotifier.notify(
      "ERROR: The configuration file `#{CONFIG_FILE}` is emtpy. Did you forget to set it up?",
      :title => 'Website Notifier'
   )

   # puts "ERROR: The configuration file `#{CONFIG_FILE}` is emtpy. Did you forget to set it up?"
   exit
end

# Read in the configuration file and attempt to parse it.
config = YAML.load_file CONFIG_FILE

# Read in the database file and attempt to parse it.
if !File.exists?(DB_FILE) || File.zero?(DB_FILE)
   File.new(DB_FILE, 'w+')
   db = {}
else
   db = YAML.load_file DB_FILE
end

# Loop through each website in our configuration and see if it's updated.
config.each do |site, options|
   next if site == 'debug'

   # Is the site already in the database?
   if db.has_key? site
      # Make sure we don't check websites too frequently.
      time_since = DateTime.now - DateTime.parse(db[site]['lastcheck'])
      time_since = time_since * 24 * 60

      if time_since.to_i < options['frequency']
         if config['debug']
            # Calculate how many minutes/hours until the next check.
            time_remaining = options['frequency'] - time_since.to_i

            if time_remaining > 1440
               pretty_time = "#{time_remaining / 60 / 24} day(s)"
            elsif time_remaining > 24
               pretty_time = "#{time_remaining / 60} hour(s)"
            else
               pretty_time = "#{time_remaining} minute(s)"
            end

            TerminalNotifier.notify(
               "Skipping #{site}. Recheck in #{pretty_time}.",
               :title => 'Website Notifier [DEBUG]'
            )

            # puts "[DEBUG] Skipping #{site}. Recheck in #{pretty_time}."
         end

         next
      end
   else
      db[site] = {}

      TerminalNotifier.notify(
         "New website detected: #{site}",
         :title => 'Website Notifier [DEBUG]'
      ) if config['debug']

      # puts "[DEBUG] New website detected: #{site}" if config['debug']
   end

   # Update the MD5 for any remaining websites.
   md5 = open(site) do |data|
      Digest::MD5.hexdigest(data.read)
   end

   if db[site].has_key?('md5') && db[site]['md5'] != md5
      TerminalNotifier.notify(
         options['alert'],
         :open => site,
         :title => 'Website Notifier'
      )

      # puts #{options['alert']}
   end

   db[site]['md5'] = md5
   db[site]['lastcheck'] = DateTime.now.to_s
end

# Save the updated database.
File.write(DB_FILE, db.to_json)