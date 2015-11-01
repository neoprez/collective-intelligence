module Cluster
	def self.read_file(file_name)
		lines = []
		File.open(file_name) do |f|
			while line = f.gets
				lines << line
			end
		end	
		col_names = lines[0].strip().split("\t")[1,lines[0].length-1]
		row_names = []
		data = []
		lines[1,lines[1].length-1].each do |line|
			p = line.strip().split("\t")
			# First column in each row is the rowname
			row_names << (p[0])
			# The data for this row is the reaminder of the row
			tmp = []
			p[1,p.length-1].each do |x|
				tmp << x.to_f	
			end
			data << tmp
		end

		return row_names, col_names, data
	end

	def self.pearson(v1,v2)
		# simple sums
		sum1 = v1.inject(:+)
		sum2 = v2.inject(:+)

		# sum of the squares
		sum1Sq = v1.map{ |v| v**2 }.inject(:+)
		sum2Sq = v2.map{ |v| v**2 }.inject(:+)

		# Sum of the products
		pSum = (0...v2.length).to_a.map{ |i| v1[i] * v2[i] }.inject(:+)

		# Calculate r (Pearson score)
		num = pSum-(sum1*sum2/v1.length.to_f)
		den = Math.sqrt((sum1Sq-(sum1**2)/v1.length.to_f)*(sum2Sq-(sum2**2)/v1.length.to_f))
		return 0 if den == 0
	
		return 1.0-num/den
	end
end
