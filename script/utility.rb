#!/usr/bin/ruby

module Utility
	def self.readfile(path)
		return nil if !FileTest.exist?(path)
		path_fp = File.new(path)
		data = path_fp.read
		path_fp.close
		return data
	end
	
	def self.create_hash(data)
		h = {}
		data.each_line do |s|
			words = s.split
			h[ words[0] ] = words[1]
		end
		return h
	end
	
	def self.initial(file)
		plugin_dir = File.expand_path(File.dirname(file) + '/..')
		return plugin_dir, 
				create_hash(readfile(plugin_dir + '/config/path'))
	end
	
	def self.find_info_str(name, data)
		return nil if data == nil
		data.each_line do |s|
			words = s.split
			if words[0] =~ name
				return words[1]
			end
		end
		return nil
	end
	
	def self.find_info(name, path)
		return find_info_str(name, readfile(path))
	end
end

class SqlGrader
	def initialize(cafedir)
		database = cafedir + '/web/config/database.yml'
		db = Utility.find_info(/^database:/, database)
		username = Utility.find_info(/^username:/, database)
		password = Utility.find_info(/^password:/, database)
		@conn = Mysql.new('localhost', username, password, db)
	end
	
	def close
		@conn.close
	end
	
	def query(str)
		return @conn.query(str)
	end
	
	def find_id(problem)
		return self.query("SELECT id FROM problems WHERE name = \
'#{problem}'").fetch_row[0]
	end
		
	ALL = 0
	AVAIL = 1
	
	def list_problem(option = ALL)
		suffix = ''
		suffix = " WHERE AVAIL = '1'" if option == AVAIL
		rs = self.query("SELECT name FROM problems" + suffix)
		list = []
		rs.each do |s|
			list << s.to_s
		end
		return list.sort
	end
	
	def insert(name)
		self.query("INSERT INTO problems(name, full_name, \
full_score, date_added, available, test_allowed, output_only, \
description_filename) VALUES('#{name}', '#{name}', '100', \
'#{Time.new.strftime("%Y-%m-%d")}', '1', '1', '0', '#{name}.pdf')");
		return self.find_id(name)
	end
end
