require 'rest-client'
require 'json'
# See https://delicious.com/rss for help
# Recent bookmarks by tag
# http://feeds.delicious.com/v2/{format}/tag/{tag[+tag+...+tag]}
# I'll keep it like this for now
module Delicious
	@url = 'http://feeds.delicious.com/v2/json'
	# Returns an array of the latest 100 bookmarks. 
	# If tag parameter is given the popular bookmarks for that tag
	# are returned

	# Contents of the hash
	# a = user, d = title, n = i dont know, u = url, t = tags (array), dt = date
	# Dont complicate yourself. If tag is given, only look for post by that tag. 
	# This is called low-level hacking :p
	def Delicious.get_popular(tag='',count=100)
		
		if !tag.empty?
			response = RestClient.get @url + "/tag/#{tag}", :params => { :count => count }
		else
			response = RestClient.get @url, :params => { :count => count }
		end

		return JSON.parse(response)			
	end	

	def Delicious.get_userposts(user)
		response = RestClient.get @url + "/#{user}"
		return JSON.parse(response)	
	end

	
end
