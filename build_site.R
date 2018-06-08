#Set our working directory. 
#This helps avoid confusion if our working directory is 
#not our site because of other projects we were 
#working on at the time. 
setwd("G:/Mi unidad/R_LEARNING/GitHub/alvaro.gutyerrez")


#type on the following two lines on  the Terminal
#git clone https://github.com/AlvaroGutyerrez/alvaro.gutyerrez.github.io.git
#cd alvaro.gutyerrez.github.io



#Let's add all the files to our git staging area
#git add -A #the -A flag tells it git you want everything

#Now we can commit
#git commit -m "My first website commit. The begining of greatness"

#Now we push. Note the addendum to normal pushing
#git push origin master



#render your sweet site. 
rmarkdown::render_site()



