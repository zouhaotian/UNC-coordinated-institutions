Clone_Directory:
	./Clone_Directory.sh

app.csv: Clone_Directory
	nextflow main.nf

run_app: app.csv
	./run_app.sh

