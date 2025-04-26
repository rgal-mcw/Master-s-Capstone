# Making a Consort Flowchart using this example:
# https://rpubs.com/phiggins/461686


#Make size by step dataframe


# Create a data frame
consort <- data.frame(
  
  Step = c("TrinetX Pull",  
           "Exclude Dead Patients w/ Acception",
           "Filter for Our Date Range",
           "Exclude patients without one of our ICD9/ICD10 codes",
           "Excluce paitents without at least 3 diagnoses of SCD",
           "Exclude patients who are identified as having Sickle Cell Trait",
           "Exclude patinets whose are more than 18 years old",
           "Exclude patients whose are 18+ at any time during their follow-up",
           "Exclude patients whose first and last encounter dates are within 365 days",
           "Exclude patients who don't have follow-up in at least two different calendar years",
           "Exclude patients who didnt have BMI data",
           "Males",
           "Females"
           
           ),
  
  N = c(90124, 
        89184,
        22394,
        19923,
        17814,
        16139,
        7501,
        6294,
        4622,
        4559,
        1220,
        632,
        588
        
        ),
  
  Description = c("Patients pulled from TriNetX database query (whats the criteria??)",
                  "Exclude Dead Patients unless their Date of Death falls within a year of their last encounter",
                  "Exclude Patients who do not have encounters between 2016 and 2020",
                  "/doc/codes/cases.csv has all the ICD codes we use to filter. If a patient doesn't have one these then they're excluded.",
                  "We have reason to believe that there are incorrect/misleading diagnoses. This is a validity check",
                  "Sickle Cell Trait is the genetic possibility of giving SCD to kid. It's mutually exclusive with SCD",
                  "This is our first filter to get only kids. For our earliest year of interest, 1997 is the earliest possible year of birth",
                  "There are kids that turn 18 within the time frame that we have our data. We exclude these individuals",
                  "If all encounters fall within 365 days, then this is not enough follow-up time",
                  "We want at least two consecutive years of follow-up. We want 365 days between the first and last. We also allow for a year between two years. (consec variable)",
                  "Need BMI data",
                  "Male",
                  "Female"
                  
                  
                  
                  )

)



## Build grid
data <- tibble(x= 1:100, y= 1:100)


data %>% 
  ggplot(aes(x, y)) +
  scale_x_continuous(minor_breaks = seq(10, 100, 10)) +
  scale_y_continuous(minor_breaks = seq(10, 100, 10)) +
  theme_linedraw() ->
  p
p

## Add first box and text

p +
  geom_rect(xmin = 32, xmax=68, ymin=94, ymax=102, color='black',
            fill='white', size=0.25, size=0.25) +
  annotate('text', x= 50, y=98,label= paste(consort[1,2], 'Patients pulled from TriNetX'), size=3) ->
  p
p

## Add second box

p +
  geom_rect(xmin = 32, xmax=68, ymin=73, ymax=83, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 50, y=78,label= paste(consort[4,2], 'Patients met date criteria'), size=3) +
  geom_rect(xmin = 70, xmax=99, ymin=80, ymax=98, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 83.5, y=89,label= paste('\n', consort[1,2] - consort[4,2], 'Patients excluded                 \n', consort[1,2]-consort[3,2], 'Had encounter dates \n                  outside of our date range \n    ', consort[1,2] - consort[2,2], 'Did not have a death \n          date within date range\n'), size=2.5) ->
  p
p

#Add Third Box
p +
  geom_rect(xmin = 32, xmax=68, ymin=53, ymax=63, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 50, y=58,label= paste(consort[6,2], 'Patients met clinical criteria'), size=3) +
  geom_rect(xmin = 70, xmax=99, ymin=58, ymax=70, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 83.5, y=64,label= paste('\n', consort[4,2] - consort[6,2], 'Patients excluded                 \n       ', consort[4,2]-consort[5,2], 'Had Sickle Cell Trait \n', consort[5,2] - consort[6,2], 'Did not have our \n               defined SCD codes\n    '), size=2.5) ->
  p
p

#Add Fourth Box
p +
  geom_rect(xmin = 32, xmax=68, ymin=33, ymax=43, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 50, y=38,label= paste(consort[10,2], 'Patients met age criteria'), size=3) +
  geom_rect(xmin = 70, xmax=103, ymin=38, ymax=50, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 83.5, y=44,label= paste('\n', consort[6,2] - consort[10,2], 'Patients excluded                 \n     ', consort[6,2]-consort[7,2], 'Older than 18 years of age \n    ', consort[7,2] - consort[8,2], 'Turned 18 during follow-up \n               ', consort[8,2]-consort[10,2], "Didn't meet follow-up time criteria \n"), size=2.5) ->
  p
p

#Add Fifth Box

p +
  geom_rect(xmin = 32, xmax=68, ymin=13, ymax=23, color='black',
            fill='white', size=0.25) +
  annotate('text', x= 50, y=18,label= paste(consort[11,2], 'Patients had BMI data'), size=3) +
  geom_rect(xmin=6, xmax=30, ymin=0, ymax=10, color='black',
            fill='white', size=0.25) +
  annotate('text', x=18, y=5, label=paste(consort[12,2], 'Male children included'), size=3) +
  geom_rect(xmin=70, xmax=95.5, ymin=0, ymax=10, color='black',
            fill='white', size=0.25) +
  annotate('text', x=83, y=5, label=paste(consort[13,2], 'Female children included'), size=3)->
  p
p

# Add arrows

p +
  geom_segment(
    x=50, xend=50, y=94, yend=83.3, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=50, xend=69.7, y=89, yend=89, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) ->
  p
p

p +
  geom_segment(
    x=50, xend=50, y=73, yend=63.3, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=50, xend=69.7, y=67, yend=67, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) ->
  p
p


p +
  geom_segment(
    x=50, xend=50, y=53, yend=43.3, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=50, xend=69.7, y=47, yend=47, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) ->
  p
p

p +
  geom_segment(
    x=50, xend=50, y=33, yend=23.3, 
    size=0.15, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) -> 
  p
p

p +
  geom_segment(
    x=50, xend=50, y=13, yend=5, 
    size=0.15) +
  geom_segment(
    x=50, xend=30, y=5, yend=5,
    size=0.15,
    arrow=arrow(length=unit(1,'mm'), type='closed')) +
  geom_segment(
    x=50, xend=70, y=5, yend=5,
    size=0.15,
    arrow=arrow(length=unit(1,'mm'), type='closed')) -> 
  p
p = p + labs(title="Consort Diagram for SCD BMI Study") +
  theme_void() +
  theme(plot.title = element_text(hjust=0.5))

ggsave('/Users/ryangallagher/Desktop/MedicalCollegeofWisconsin/SCD_project/consort.jpeg', plot=p)
