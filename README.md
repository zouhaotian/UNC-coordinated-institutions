# project-3-zouhaotian
project-3-zouhaotian created by GitHub Classroom

To run the whole project, just clone the whole repository, and run command: make run_app. 
And waiting for about one minute, navigate the browser to vcl-host-ip:3838. Then the app is online!

The whole project contains three modules: Clone_Directory, create app.csv, run app to create the dashboard.

The Clone_Directory is just cloning the 'datasci611' repository, and change the branch to gh-pages.

The second module uses nextflow. The main.nf containes two processes. 

The first process is to read in all text files using for loop, clean up the 'conflict' line, process to a tibble, and append to 'abstract.csv'. The 'abstract.csv' has one observations for each abstract, and six columns: journal, title, author, author information, abstract, other.

The second process is to process the 'abstract.csv' to 'app.csv'. The 'app.csv' contains three columns (institutions, abstract keyword, abstract number) for all abstracts. One abstract has multiple institutions, and a specific abstract keyword. The method I used is that: read in abstract.csv to a tibble; for each observation, figure out the abstract and author information; for abstract, find the word appearing most times (length>4); for author information, split the full sentence to different authors, if the author doesn't belong to Chapel Hill, then split this author's information, using keywords to find his institution; finally, append this record a dataframe.

The third module creates dashboard. The input: how many top collaborating institutions you want to see? The output (a table having three columns): the insitution name; abstract keyword; number of abstracts.
