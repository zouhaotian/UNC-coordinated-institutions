#Create app.csv: three columns (institutions, abstract keyword, abstract number) for all abstracts.
#One abstract has multiple institutions, and a specific abstract keyword.

library(tidyverse)

abstract <- read.csv('abstract.csv', sep = '^', header = F, quote = "",
                     col.names = c('journal', 'title', 'author', 'institution', 'abstract', 'other'))

# This function returns the most frequent abstract keyword

find_subject <- function(abs){
  word_1 <- str_split(abs, boundary("word"))[[1]]
  word_2 <- gsub("[,]", '', word_1)
  word <- gsub("[.]", '', word_2)
  word <- tolower(word)
  subject <- sort(table(word), decreasing = T) %>% 
    as.tibble %>% 
    filter(str_length(word)>4) %>% 
    head(1)
  return(subject)
}

# This function returns whether this author belongs to Chapel Hill

if_not_Chapel_Hill <- function(name_of_inst){
  flag <- T
  for (k in 1:20){
    locate_space <- str_locate(name_of_inst[k], 'Chapel Hill')
    locate <- str_locate(name_of_inst[k], 'ChapelHill')
    if (!is.na(locate_space[1,1]) | !is.na(locate[1,1])) {flag <- F}
  }
  return(flag)
}

# This function returns the the institution for this author

find_institution <- function(name_of_inst){
  for (k in 1:20){
    school <- str_locate(name_of_inst[k], 'School')[1,1]
    institute <- str_locate(name_of_inst[k], 'Institute')[1,1]
    university <- str_locate(name_of_inst[k], 'University')[1,1]
    hospital <- str_locate(name_of_inst[k], 'Hospital')[1,1]
    hospital_2 <- str_locate(name_of_inst[k], 'hospital')[1,1]
    centre <- str_locate(name_of_inst[k], 'Centre')[1,1]
    lifehouse <- str_locate(name_of_inst[k], 'Lifehouse')[1,1]
    if (!is.na(school) | !is.na(institute) | !is.na(university) 
        | !is.na(hospital) | !is.na(centre) | !is.na(lifehouse)
        | !is.na(hospital_2)) {return(name_of_inst[k])}
  }
  p <- str_length(toString(name_of_inst[2]))
  if (p>=10) {return(name_of_inst[2])}
    else {return(name_of_inst[1])}
}

institution_subject <- tibble('institution' = '', 'subject' = '', 'abstract.No' = '')
for (i in 1:nrow(abstract)){
  x <- tibble('institution' = '', 'subject' = '', 'abstract.No' = '')
  
  abs <- abstract[i,5]
  inst <- abstract[i,4]
  
  if (abstract[i,5] == '') {
    abs <- abstract[i,4]
    inst <- abstract[i,3]
  }
  
  if (str_length(abstract[i,6]) >= 300) {
    abs <- abstract[i,6]
    inst <- abstract[i,4]
  }
  
  if (!is.na(str_locate(abstract[i,5], 'Author information')[1,1])) {
    abs <- abstract[i,6]
    inst <- abstract[i,5]
  }
  
  subject <- find_subject(abs)
  
  count <- str_count(inst, '\\(')
  location <- str_locate_all(inst, '\\(')
  collaborate <- 0
  for (j in 1:count){
    if (j>=10) {start_loc <- location[[1]][j] + 4}
    else {start_loc <- location[[1]][j] + 3}
    if (j!=count) {end_loc <- location[[1]][j+1] - 1}
    else {end_loc <- str_length(inst)}
    
    full_name <- str_sub(inst, start_loc, end_loc)
    
    name_of_inst <- str_split(full_name, ',')[[1]]
    name_of_inst <- trimws(name_of_inst, 'l')
    name_of_inst <- gsub("[.]", '', name_of_inst)
    
    if (if_not_Chapel_Hill(name_of_inst)){
      collaborate <- collaborate + 1
      x[collaborate, 1] <- find_institution(name_of_inst)
      x[collaborate, 2] <- subject[1,1]
      x[collaborate, 3] <- i
    }
  }
  institution_subject <- rbind(institution_subject, x)
}

new <- institution_subject %>% filter(institution != '')
new <- unique(new)
write.table(new, file = 'app.csv', sep = '^', append = F, row.names = F)
