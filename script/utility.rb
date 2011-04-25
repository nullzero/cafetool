#!/usr/bin/ruby

module Utility
	def self.readfile(path)
		path_fp = File.new(path)
		data = path_fp.read
		path_fp.close
		return data
	end
	
	def self.initial(file)
		plugin_dir = File.expand_path(File.dirname(file) + '/..')
		path_config = readfile(plugin_dir + '/config/path')
		h = {}
		path_config.each_line do |s|
			words = s.split
			h[ words[0] ] = words[1]
		end
		return plugin_dir, h
	end
	
	def self.find_info(name, path)
		data = readfile(path)
		if data == nil
			return nil
		end
		data.each_line do |s|
			words = s.split
			if words[0] =~ name
				return words[1]
			end
		end	
		return nil
	end
	
	def self.mysql_connect(cafedir)
		database = cafedir + '/web/config/database.yml'
		db = find_info(/^database:/, database)
		username = find_info(/^username:/, database)
		password = find_info(/^password:/, database)
		return Mysql.new('localhost', username, password, db)
	end
end
