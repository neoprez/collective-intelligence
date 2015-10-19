# A hash of movie critics and their ratings of a small
# set of movies
$critics = { 
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

# Euclidean distance for similarity score

# Returns a distance-based similarity score for person1 and person2
def sim_distance(prefs, person1, person2)
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
