#!/usr/bin/env nextflow

params.out_dir = '.'

process create_raw_data {

        container '/rocker/tidyverse'
	publishDir params.out_dir, mode: 'copy'

        output:

        file 'abstract.csv' into raw_data

        script:
	"""
        #!/usr/bin/Rscript
	
	library(tidyverse)
	for (i in 0:439) {
	filename = paste('$baseDir/datasci611/data/p2_abstracts/','abs', i, '.txt', sep = '')
  	x <- readLines(filename, n = 6)
  	x <- as.tibble(x)
  	conflict <- str_locate(toString(x[1,1]), "Conflict")[1,1]
  	if (!is.na(conflict)) {x <- x[-1,]}
  	x <- t(x)
  	write.table(x, file = 'abstract.csv', sep = '^', append = T, quote = F, col.names = F, row.names = F)
	}
        """
}

process create_app_data {
	
	input:
	file f from raw_data.collectFile(name:'abstract.csv')

	"""
	docker run -d -v $baseDir:$baseDir -w $baseDir rocker/tidyverse /bin/bash -c "Rscript create_app_data.R"
	"""
}

