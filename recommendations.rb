module Recommendations
	# A hash of movie critics and their ratings of a small
	# set of movies
	@critics = { 
	'Lisa Rose' 		=> { 
								'Lady in the Water' => 2.5, 
								'Snakes on a Plane' => 3.5, 
								'Just My Luck' => 3.0, 
								'Superman Returns' => 3.5, 
								'You, Me and Dupree' => 2.5, 
								'The Night Listener' => 3.0 
								},
	'Gene Seymour' 	=> { 
								'Lady in the Water' => 3.0,
								'Snakes on a Plane' => 3.5,
								'Just My Luck' => 1.5,
								'Superman Returns' => 5.0,
								'The Night Listener' => 3.0,
								'You, Me and Dupree' => 3.5
								},
	'Michael Phillips' => {
								'Lady in the Water' => 2.5,
								'Snakes on a Plane' => 3.0,
								'Superman Returns' => 3.5,
								'The Night Listener' => 4.0 
								},
	'Claudia Puig' 	=> {
								'Snakes on a Plane' => 3.5,
								'Just My Luck' => 3.0,
								'Superman Returns' => 4.0,
								'The Night Listener' => 4.5,
								'You, Me and Dupree' => 2.5
								},
	'Mick LaSalle'	=> {
								'Lady in the Water' => 3.0, 
								'Snakes on a Plane' => 4.0, 
								'Just My Luck' => 2.0, 
								'Superman Returns' => 3.0, 
								'You, Me and Dupree' => 2.0, 
								'The Night Listener' => 3.0 
								},
	'Jack Matthews'	=> {
								'Lady in the Water' => 3.0, 
								'Snakes on a Plane' => 4.0, 
								'Superman Returns' => 5.0, 
								'You, Me and Dupree' => 3.5, 
								'The Night Listener' => 3.0 
								},
	'Toby'					=> {
								'Snakes on a Plane' => 4.5, 
								'Superman Returns' => 4.0, 
								'You, Me and Dupree' => 1.0 }
	}

	def self.critics
		return @critics
	end
	# Euclidean distance for similarity score

	# Returns a distance-based similarity score for person1 and person2
	def self.sim_distance(prefs, person1, person2)
		# Get the list of shared_items
		si={}
	
		prefs[person1].each_key do |key|
			if prefs[person2].has_key? key
				si[key] = key
			end 
		end

		# if they have no ratins in common, return 0
		return 0 if si.empty?
		# Add up the square of all the differences
		sum_of_squares = 0
	
		prefs[person1].each do |key, value| 
			if prefs[person2].has_key? key
				sum_of_squares += (value - prefs[person2][key])**2
			end
		end

		return 1/(1+Math.sqrt(sum_of_squares))
	end

	# Returns the Pearson correlation coefficient for p1 and p2
	def self.sim_pearson(prefs,p1,p2)
		# Get the list of mutually rated items
		si={}

		prefs[p1].each_key do |key|
			if prefs[p2].has_key? key
				si[key] = 1 
			end 
		end

		# Find the number of elements
		n = si.length

		# if they have no ratins in common, return 0
		return 0 if n==0

		# Add up all the preferences
		sum1 = si.map{ |k,i| prefs[p1][k] }.inject(:+)
		sum2 = si.map{ |k,i| prefs[p2][k] }.inject(:+)

		# Sum up the squares
		sum1Sq = si.map{ |k,i| prefs[p1][k]**2 }.inject(:+)
		sum2Sq = si.map{ |k,i| prefs[p2][k]**2 }.inject(:+)

		# Sum up the products
		pSum = si.map{ |k,i| prefs[p1][k]*prefs[p2][k] }.inject(:+)

		# Calculate Pearson score
		num = pSum-(sum1*sum2/n)
		den = Math.sqrt(((sum1Sq-(sum1**2))/n)*((sum2Sq-(sum2**2))/n))

		return 0 if den==0

		num/den
	end

	def self.similarity(sim, prefs, person1, person2)
		if sim == 'sim_distance'
			self.sim_distance(prefs, person1, person2)
		else
			self.sim_pearson(prefs, person1, person2)
		end
	end

	# Returns the best matches for person form the prefs dictionary.
	# Number of results and similarity function are optional params.
	def self.top_matches(prefs, person, n=5, similarity='sim_pearson')
		scores = prefs.map{ |other,values| [self.similarity(similarity, prefs, person, other),other] if other != person }.compact #compact to remove nil

		# Sort the list so the highest scores appear at the top
		scores.sort!
		scores.reverse!
		scores[0,n]
	end

	# Get s recommmendations for a person by using a weighted average
	# of every other user's rankings
	def self.get_recommendations(prefs, person, similarity='sim_pearson')
		totals = {}
		totals.default = 0
		sim_sums = {}
		sim_sums.default = 0

		prefs.each do |other, values|
			# don't compare me to myself
			next if other==person
			sim = self.similarity(similarity, prefs, person, other)
		
			# ignore scores of zero or lower
			next if sim <= 0

			prefs[other].each do |movie_name, rating|
			
				# only score movies I haven't seen yets
				if !prefs[person].has_key?(movie_name) || prefs[person][movie_name].nil?
					# Similarity * Score
					totals[movie_name] += prefs[other][movie_name] * sim
					# Sum of similarities
					sim_sums[movie_name] += sim
				end
			end
		end

		# Create the normalized list
		rankings = totals.map do |item, total|
			[total/sim_sums[item], item]
		end

		# Return the sorted list
		rankings.sort!
		rankings.reverse!
	end

	def self.transform_prefs(prefs)
		result={}
		prefs.each do |person, movies|
			movies.each do |movie, rating|
				result[movie] = {} if !result.has_key? movie
				result[movie][person] = rating
			end
		end
		return result
	end

	# Item based filtering
	def self.calculate_similar_items(prefs, n=10)
		# Create a dictionary of items showing which other
		# items they are more simlar to
		result = {}
	
		# Invert Prefs matrix to be item centric
		item_prefs = self.transform_prefs(prefs)
		counter = 0
		item_prefs.each do |key,items|
			# Status updates for large datasets
			counter += 1
			puts "#{counter} / #{item_prefs.length}" if counter%100==0
		
			#Find the most similar items to this one
			#puts key
			scores = self.top_matches(item_prefs, key, n=n, similarity='sim_distance')
			result[key] = scores
		end
		return result
	end

	def self.get_recommended_items(prefs, item_match, user)
		user_ratings = prefs[user]
		scores = {}
		scores.default = 0
		total_sim = {}
		total_sim.default = 0

		# Loop over items rated by this user
		user_ratings.each do |key, value|
			
			# Loop over items similar to this one
			item_match[key].each do |value2, key2|
				
				# Ignore if this user has already rated this item
				next if user_ratings.has_key? key2
				# Weighted sum of rating times	
				scores[key2] += value2 * value

				# Sum of all the similarities
				total_sim[key2] += value2
			end
		end
		#Divide each total score by the total weighting to get an average
		rankings = scores.map do |item, score| 
			[score/total_sim[item], item]	
		end

		# Return the rankings from highest to lowest
		rankings.sort!
		rankings.reverse!
	end
	
	def self.load_movie_lens(path='./data')
		# Get movie title
		movies = {}
		File.open(path + '/u.item')	do |f|
			while line = f.gets
				id,title = line.scrub!.split("|")[0,2]
				movies[id] = title
			end
		end

		# Load data
		prefs = {}
		prefs.default = {}
		File.open(path + '/u.data') do |f|
			while line = f.gets
				user,movieid,rating,ts = line.split("\t")	

				if !prefs.has_key? user
					prefs[user] = {}
				end
				prefs[user][movies[movieid]] = rating.to_f
			end
		end
		return prefs
	end
end
