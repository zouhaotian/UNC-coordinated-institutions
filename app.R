# Create dashboard: input: how many top collaborating institutions you want to see? 
# Output: institution: the insitution name; subject: abstract keyword; No. abstract: number of abstracts
 
library(shiny)
library(tidyverse)

app_data <- read.table('app.csv', sep = '^', header = T, quote = "", col.names = 
                       c('institution', 'subject', 'abstract.No'))
new_app_data <- tibble('institution' = '', 'subject' = '', 'abstract.No' ='')

# get rid of ""
for (i in 1:nrow(app_data)){
  new_app_data[i,1] <- str_sub(app_data[i,1], 2, str_length(app_data[i,1])-1)
  new_app_data[i,2] <- str_sub(app_data[i,2], 2, str_length(app_data[i,2])-1)
  new_app_data[i,3] <- str_sub(app_data[i,3], 2, str_length(app_data[i,3])-1)
}

# Sort the first column of app_data: institution, to get the top institutions collaborating with UNC, 
# and the number of abstracts.
x <- sort(table(new_app_data[,1]), decreasing = T) %>% 
  as.tibble() %>% 
  rename('institution' = 'Var1')

# Left join top institutions with app_data
sorted <- x %>% 
  left_join(new_app_data, by = 'institution') %>% 
  select(-abstract.No)

# Paste all keywords for same institution as one item

app_board <- tibble('institution' = '', 'subject' = '', 'No. abstracts' = 0)
count <- 1
count2 <- 1
for (i in 1:50){
  count2 <- count + as.numeric(sorted[count, 2])
  subject <- ''
  for (j in count:(count2-1)) {
    subject <- paste(subject, sorted[j,3], sep = ', ')
  }
  subject <- str_sub(subject, 3, str_length(subject))
  app_board[i,1] <- sorted[count, 1]
  app_board[i,2] <- subject
  app_board[i,3] <- as.numeric(sorted[count, 2])
  count <- count2
}

ui <- fluidPage(
  titlePanel('Project 3: Haotian Zou'),
  
  sidebarLayout(
      
      sliderInput(
        inputId = 'top',
        label = 'Top # of collaborating institutions with UNC:',
        min = 1,
        max = 50,
        value = 10
      ),
      
      mainPanel(dataTableOutput(outputId = 'popTable'))
  )
)

server <- function(input, output){
  output$popTable <- renderDataTable({app_board[1:input$top,]})
}

shinyApp(ui, server)