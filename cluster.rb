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
end
