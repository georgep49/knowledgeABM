---
title: "An agent-based model of biocultural hysteresis - ODD"
author: "George L.W. Perry ... "
date: "`r format(Sys.time(), '%d %B, %Y')`"
output:
  pdf_document: default
  html_document:
    df_print: paged
header-includes:
 \usepackage{float}
 \floatplacement{figure}{H}
bibliography: bcHysteresis.bib
csl: global-ecology-and-biogeography.csl
---
 
Our model description follows the ODD (Overview, Design concepts, Details) protocol for describing  agent-based models [@grimmStandardProtocolDescribing2006] and updated by Grimm et al. [-@grimmODDProtocolDescribing2020].

# Purpose and patterns
The purpose of our agent-based model (ABM) is to explore the conditions under hysteresis in knowledge-belief-practice (KBP) complexes can emerge under different modes of individual and social learning and how such hystersis effects can be broken.  It is abstract and does not seek to represent a specific landscape, group of people, or set of resources.  Our ABM is implemented in NetLogo 6.4 [@wilenskyNetLogo6401999].

# Entities, state variables, and scales

## Entities
The two fundmanental entities in our ABM are grid cells and agents.  The grid cells represent locations in space where different resources are available; the grid is static during esach model run.  The agents represent individual people who move through the landacape and use the resources they encounter.  Individual agents may belong to broader social groups, representing broader collectives who share knowledge internally.

## State variables
The main state variable in the model is the knwoeldge of each resource type held be each agent.  This takes a floating point value from 0 - 100 for each and changes over time as the agent interacts with the environment and learns from other agents and the social network. 

## Scale
Our ABM is abstract and does not reference specific scales.  Nevertheless, we envisage the world as being landscape size (000s of ha).

# Process overview and scheduling

FIGURE

At each time-step each agent moves to a new grid cell within distance `spatial-nhb` (courier type denotes model parameter).  After moving, the agent updates its knowledge of each resource type (`knowldege-a` or `knowledge-b`, respectively.  If the agent dies (i.e., leaves the system in some form) it passes on some fraction of this knowledge to its offspring (we assume one offspring per adult) and the credibility + N(0.5).  Finally, depending on the scenario being evaluiated there may be a landscape-level loss or gain in resource availability.

# Design concepts

## Basic principles
Our ABM addresses the idea of hysteresis in social-ecological KBP as discussed by Luyver et al. [-@lyverBioculturalHysteresisInhibits2019].  To do thise we use an abstract model where agents learn from each other and within social groups about the use of different resources under different individual and social learning and environmental conditions.

## Emergence
The fundamental emergent propert of the model is the knowledge of individuals and groups and the distribution of this knowledge across them.
 
## Adaptation
The only source of adaptation is the agents' decision as to where to mvoe in successive time-steps -- this may either be random or based on their knowledge of resource use. 

## Objectives
There is no direct objective seeking.
 
## Learning
Agents can learn in tmree ways: (i) direct encounmter with a resource, (ii) interaction with another agent of any social unit when they are present in the same grid cell, and (iii) through exchange within their social unit. The encounter procedure represents an individual learning via direct encounter with a resource, whereas the other two are forms of social learning.

## Prediction
There is no prediction implemented in the model.

## Sensing
All agents have perfect local knowledge of resources in their immediate environment (`spatial-nhb`); they also have a memeory of the most recent `memory-length` patches that they have visited. 

## Interaction

## Stochasticity
Nearly all elements in our model are stochastic.

## Collectives
Agents are members of one of `n-units` (an integer of one or more) social groups. If agents have social learning, this occurs with other agents of the same social group.  

## Observation
The key state variable we observe is the distribution of knowledge of the two resource types across the individual agents and the social groups.

# Initialisation

## Landscape
The landscape is a lattice of grid cells characterised by one of two resource types.  At the start of each model run each grid cell is allocated a resource type at random with probability of `n-p-a` and `1 - n-p-a` for resource types a and b, respectively.

## Agents
At initialisation `n-agents` agents are created.  These have initial values of N(50, 10) for `knowledge-a` and `knowledge-b`, respectively (where N(m, s) is a normal distribution with mean m and SD s)).  Each agent also has an initial credibility of N (50, 10). Every agent belongs to one of `n-units` social groups (families or tribes), which are allocated at random at model initialisation.  On agent death, offspring become members of the same social group with probability `1 - defect-unit` or join another unit at random with probability `defect-unit`.

# Input data
None

# Sub-models

## Movement
At each time-step agents move to a cell within a distance of`spatial-radius`, which is not in their memory (the most recently visited `memory-length` patches). The cell can be selected at random or agents can preferentially move to a neighbouring cell with the type they are most knowledgeable about.    

## Learning
As the agents move through the landscape their understanding of how to 'use' each of the two resource types (the KBP associated with that resource) changes; this knowledge is represented as a value from 0-100. This updating happens in three ways:

1. Encounter - at each time step, each agent updates its knowledge based on the current patch following a logistic curve (with _r_ = 0.1 and _K_ = 100). At each time step, there is a slight loss of knowledge of the use of the resource type different to the one the agent is in; this loss occurs at rate `k-erosion`.    
2. Spatial learning - if there are other agents within some radius `spatial-nhb`, then each agent will gain a fraction (`transfer-fraction`) of the difference between its knowledge and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all other agents on the patch for both resource types.  This model of learning assumes that an agents knowledge will not be **reduced** through interactions with other agents.     
3. Social learning - each agent will gain a fraction (`transfer-fraction`) of the difference between it and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all agents in its social network (unit) for both resource types; this transfer occurs irrespective of location. This exchange represents internal knowledge transfer [ref!].  

For both spatial and social learning a threshold can be imposed such that agents cannot learn from other agents who have knowledge `cognitive-distance-threshold` more than their own.  This dynamic represents cognitive distance - that is the fact that once the knowledge base between two entities is sufficiently large learning can be impeded (e.g., through an absence of shared language or perspective).  A second test can be in place which tests the credibility of the agent being learned from under spatial elarning - in this case, a deviate U(0,1) is generated and learning only occurs if this value is less than the credibility of the agent being learnined from.

## Inter-generationl exchange
Each time-step after an agent has reached an age of ten, there is a 10% chance of mortality per time-step.  On an agent's death, their offspring inherit some fraction of their knowledge (based on a uniform distribution, U[`parent-transfer`, 1], their credbility plus N(0,5), and all other attributes other than their patch visit memory, which is empty.  As `parent-transfer` declines, on average s amller fraction of knowledge is passed down. There is a chance (`defect-unit`) that the offspring will become a member of another unit, which represents an external transfer of knowledge to that unit [ref!]. 

# References
