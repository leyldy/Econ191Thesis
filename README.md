# Econ191Thesis
Thesis written for Economics 191 in UC Berkeley: Topics in Economic Research. Measured latent shadow economy levels per state-year in United States, and determined its causal effects on harming the efficacy of Housing First policy in reducing homelessness.


# Data 
## Homelessness and Housing Data: U.S. Department of Housing and Urban Development
- Housing Inventory Count (HIC): contains information about number of housing units and beds, segmented into different housing types from emergency shelters to Rapid Re-Housing – which stems from a Housing First approach.
- Point-in-Time Count (PIT): contains information on the number of shelter and unsheltered homelesspeople on a single night in January,  providing a snapshot of homelessness by state.

## Data on Various Economic Factors
- Collected data on economic factors relevant to determining the level of the latent shadow economy levels, which are not officially reported and hence needs to be estimated.
- Economic Factors: real GDP per capita, unemployment rate, labor force growth, % w/ high school diploma, electricity consumption per GDP, Charges Revenue as % GDP, Protective Inspection & Regulation expenditures as % GDP, Government expenditures as % GDP, Indirect Tax revenue as % GDP, Insurance Trust, unemployment compensation, employee retirement, and workers’ compensation expenditures as % of GDP.
- Data Sources: U.S. Bureau of Labor Statistics, Bureau of Economic Analysis, U.S. Energy Information Administration, U.S. Department of Commerce, Census Bureau.

- Cleaning, wrangling, aggregating, and joining all such data implemented through R scripts. 


# Methodology (STATA)
## Measuring the Level of Shadow/Underground Economy
- Utilized Multiple-Indicators, Multiple-Causes (MIMIC) method General Additive Model to determine the latent shadow economy levels.
- Related shadow economy's causal factors (tax revenue, gov't expenditures, regulation expenditures, etc) and indicator factors (electricity consumption, real GDP per capita, etc) in MIMIC Method.
- Measured the relative shadow economy levels for each state-year.

## Identifying Causal Effect of Shadow Economy on Housing First
- Utilized fixed time and state effects panel regression relating homelessness numbers, Housing First policy, shadow economy level, controlling for covariates.
- Variable of interest: Interaction term of Housing First policy X Shadow Economy levels.
