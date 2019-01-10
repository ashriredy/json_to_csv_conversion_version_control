#### Setting up the environment ####
setwd("C:/Users/user/Desktop/Data_Retrieval/JSON")
if(!require("pacman")){install.packages("pacman",dependencies = TRUE); library("pacman");}
pacman::p_load(RJSONIO,magrittr,plyr,crayon,data.tree, rsvg, DiagrammeR, devtools) 
devtools::install_github("rich-iannone/DiagrammeRsvg")
rm(list=ls()); cat("\014"); gc();

#### Determine JSON hierarchy ####
root      <- RJSONIO::fromJSON(content = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=categories&titles=Google")
root_node <- root %>% data.tree::as.Node()
file_name <-  paste0("json_hierarchy_",gsub(":","-",Sys.time()),".pdf")
export_graph(ToDiagrammeRGraph(root_node), file_name)
shell.exec(file_name)

#### User input for path ####
all_selections <- NULL
pivot          <- root 
while(1){
    selection      <- menu(names(pivot), title="Selection", graphics = T)
    all_selections <- c(all_selections,names(pivot)[selection])
    pivot          <- pivot[[names(pivot)[selection]]]
    
    exit_selection <- menu(c("Yes","No"), title="Do you want to go deeper?", graphics = T)
    if(exit_selection == 2){
        break
    }
}

# Navigating to node of interest
desired_node <- root
for(i in all_selections){
    desired_node <- desired_node[[i]]    
}

#### Conversion of JSON to data.frame ####
final_df <- data.frame(stringsAsFactors = F)
for(i in seq_along(desired_node)){
    piece              <- desired_node[[i]]
    unlisted_piece     <- unlist(piece)  
    unlisted_dataframe <- t(unlisted_piece) %>% as.data.frame()
    final_df           <- rbind.fill(final_df,unlisted_dataframe)
    cat( cyan(paste0(i,"/",length(desired_node)," Completed")),"\n" )
}
row.names(final_df) <- names(desired_node)
file_name <-  paste0("json_converted_to_csv_",gsub(":","-",Sys.time()),".csv")
write.csv(final_df,file_name)
shell.exec(file_name)

#### Junk code below: wont get executed #### 
if(F){
    # print(root_node)
    # plot(root_node)
    # data.tree:::plot.Node(root_node)
    # root = RJSONIO::fromJSON(content <- "http://api.fantasy.nfl.com/v1/players/stats?statType=seasonStats&season=2017&week=1&format=json")
    # root = RJSONIO::fromJSON(content <- "https://api.github.com/users/hadley/repos")
    #all_selections
    #desired_node <- root %>% `[[`(all_selections) #root[[all_selections]]
    #desired_node <- root$players
    #selection    <- menu(names(root), title="Selection", graphics = T)
}