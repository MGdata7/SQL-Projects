# Texas Cosmetology Project
## Data Cleaning Project in SQL

![image](https://user-images.githubusercontent.com/14934475/222164529-72b351e1-65a6-46b6-814d-674b5a45a2e1.png)

In today's project, I'm examining cosmetology license data from the state of Texas and comparing it to U.S. Census Bureau data filtered by Texas. A stakeholder is asking me
whether aesthetician licenses are more densely occurring in higher-income areas. They also invite me to share other insights around geographical characteristics and aesthetician licensure.

Aesthetic services are typically expensive so this may seem intuitive. But this insight might drive business choices - like how to approach marketing salon products to aestheticians, for example - so it's worth asking a data analyst to run the numbers and make sure.
Additionally, an unexpected insight that aestheticians are equally common in lower income areas might point to a new area of the market. It's time to see what the data can tell us.

Before any analysis can happen, the data has to be formatted in a way that makes it easy to analyse. It needs to be cleaned. We'll clean the data and then see what we can find.

This project prompt was designed by David Langer. First I'll download the datasets.

### Viewing the Data

![image](https://user-images.githubusercontent.com/14934475/222166369-5cef278a-e327-4333-b0bd-d0d001f3877d.png)

![image](https://user-images.githubusercontent.com/14934475/222166583-52ee8345-d554-4f61-843d-2e937df7958f.png)

![image](https://user-images.githubusercontent.com/14934475/222166948-bf637ea0-b928-46f0-9bb7-1f221ab3df29.png)

The DP03 is the U.S. Census' dataset on economic characteristics of the US population, derived from the American Community Survey. I used 2021 data and only selected Texas counties there.

Let's have a look at the data in Excel. Looking at the census data, right away I can see something that needs tweaking. The county information is tied in with state information. I'll need to change that to merge it with the Texas cosmetology data.

![image](https://user-images.githubusercontent.com/14934475/222171185-c31d107f-c667-42c2-bf4a-83417ee35850.png)

The columns are also named by coding for which the Census provided a dictionary spreadsheet. I'll likely rename the columns I'm working most with.

In the Texas cosmetology info, it looks like the counties are isolated, though the capitalisation is different so I will fix that later. I'm happy to see some of the data has been sanitised and addresses have been removed, that saves me a step.

![image](https://user-images.githubusercontent.com/14934475/222172158-24392289-063b-4075-935e-f6e5d6631e4b.png)

### Cleaning in SQL Server

Next I'll import the two spreadsheets into SQL Server and create databases like so:

![image](https://user-images.githubusercontent.com/14934475/222178390-bd3262eb-c72f-4c5e-8d45-968872351ba1.png)






