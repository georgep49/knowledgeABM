---
title: "An agent-based model of biocultural hysteresis"
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

### Introduction

Social-ecological memory (SEM) is a fundamental component of a social-ecological system's resilience to change [@folkeSynthesisBuildingResilience2002].  It is dynamic, and continually reshaped in positive and negative ways, both internally (e.g. as social norms within a group change) and externally (e.g., as knowledge from beyond a group is transferred into it).  Knowledge-belief-practice complexes underpin SEM.  These represent the long-term set of behaviours developed by humans based on repeated interactions with their environments [ref!]. A repeated outcome of colonialism has been the erosion of knowledge-beiief-practice (KBP) complexes, whether deliberate or otherwise. For example, many indigenous people have been deprived access to traditional resources by legislative means (a direct loss) and through dwindling populations of some species (an indirect loss); of course, these interact as the perceived conservation threat leads to regulatory mechanisms aimed at 'protecting' a species [@hartelTraditionalEcologicalKnowledge2023].  There is growing interest in understanding the conditions under which KBP are maintained, the trajectory of their loss, and how they might be reinstated if eroded or lost.


Regime shift dynamics in social-ecological systems have been the focus of recent attention [ref!]; concepts such as tipping points and hysteresis, developed in ecology, have been applied to social systems.  However, the focus of this research has typically been on how changes in human behaviour trigger ecological change.   For example, Bausch et al. [ref!] show how human behaviour in a coupled human-environment system can drive regime shifts in forest cover; likewise, Mathais et al. [ref!] explore how social and ecological regime shifts can infleunce each other. Lyver et al. [@lyverBioculturalHysteresisInhibits2019] describe a conceptual model of how social-ecological systems can suffer 'biocultural hysteresis'. In their model, following the erosion of a KBP complex,  positive feedbacks act to maintain a new state potentially even after the mechanisms underpinning the loss are removed. In such settings, the restoration of the biological resource may be insufficient to restore the knowledge associated with it  Hysteresis implies that the loss of KBP persists even if access to the resource is reinstated (the state of the system is a function fo its history not just contemporary social-ecological conditions). However, it is not clear under which conditions such hysteresis in KBP might occur, how they might be avoided, and how KBP might be reinstated under hysteresis. 

- Regime shifts in SES (see Lyver paper, Yletyinen et al. ) - docuemtned or beleived likely in large range of contexts...

- [Exploring non-linear transition pathways in social-ecological systems | Scientific Reports](https://www.nature.com/articles/s41598-020-59713-w)

- https://www-pnas-org.ezproxy.auckland.ac.nz/doi/full/10.1073/pnas.1604978113

- https://www.nature.com/articles/s44168-024-00131-3

- https://royalsocietypublishing.org/doi/10.1098/rstb.2021.0382  (Section 4, para starting "In output-limited models,...")


- " The traditional ecological knowledge conundrum"

Add classic hysteresis type plot here

In parallel to this social-ecological approach, quantitative sociologists have explored the conditions under which opinions and culture form and persist, and how these dynamics are influenced by social learning [@castellanoStatisticalPhysicsSocial2009].  For example, agent-based models have been used to explore how different opinions and beliefs might spread through social networks and subsequently persist.  This body of research demonstrates that different types of social interaction and learning will determine how information flows through social systems [-@flacheModelsSocialInfluence2017].  Proximity in various forms is an important control on knowledge sharing. Boschma  [@-boschmaProximityInnovationCritical2005] recognises five types of proximity -- geographic, social, cognitive, institutional, and organisational -- that relate to how the distance between those sharing knowledge influences this process.  For example, when individuals exchange knowledge the similarity of their shared experience and expertise  may influence learning -- if it is too disparate (low cognitive proximity), learning may be impeded.  Crucially, ref! argues that the effectiveness of knowledge exchange is not likely to be a monotonic response to distance -- for example, if knowledge exchange only occurs very locally (high geographic distance) or within very similar social groups (high social proximity) then lock-in effects may inhibit learning or innovation. There are clear links between these perspectives about proximity and exchange, and the challenges of the dynamic retention of TEK described above.  The mechanisms that underpin the erosion of a KBP complex act in multiple ways to change the proximity between individuals and each other and individuals and the environment.  



Here, we use an agent-based model (ABM; ref!) to explore the conditions under which biocultural hysteresis might arise.  In our model, agents interact with two types of resources and develop inter-generational understanding of their use through direct interaction and social learning. In particular we ask the following questions:

1. Do different modes of social learning affect baseline levels of knowledge about the use of a resource?    

2. Do different modes of learning provide resilience against erosion of knowledge following the permanent reduction or loss of access to a resource?

3. Under what conditions do biocultural hysteresis affects emerge following the reduction or loss and then reinstatement of access to a resource?

## 

## Methods

Here we provide a high-level description of the agent-based model we used to explore the conditions under which biocultural hysteresis might arise; a full description using the ODD protocol (Grimm ref!) is provided as Supplementary Material. Our ABM is implemented in NetLogo 6.4 [ref!].

#### 

#### Model description

*Landscape*
The model landscape is a grid with two types of grid cells (labelled 'a' and 'b') representing sources of different knowledge - these represent places where specific species or geographic features are present. The grid comprises 50 x 50 square grid cells (patches). We assume that a patch can not contain both types of resource. The types are not inherently positive or negative, just different.  The initial amount of type 'a' in the landscape is controlled by the `n-p-a` parameter, with patches allocated to each type at random.  

*Agents*
Agents belong to units (i.e., a social network), with the number of agents and units controlled by the `n-agents` and `n-unit` parameters, respectively.  The units are not antagonistic but are social groupings that internally share knowledge.  Agents move through the landscape, and, as they do so, their understanding of how to 'use' each of the two resource types changes; this knowledge is represented as a value from 0-100.  This updating happens in three ways:

1. Encounter - at each time step, each agent updates its knowledge based on the current patch following a logistic curve. At each time step, there is a slight loss of knowledge of the use of the resource type different to the one the agent is in; the rate of this loss is controlled by `k-erosion`.    
2. Spatial learning - if there are other agents within some radius `spatial-nhb`, then each agent will gain a fraction (`transfer-fraction`) of the difference between its knowledge and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all other agents on the patch for both resource types.     
3. Social learning - each agent will gain a fraction (`transfer-fraction`) of the difference between it and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all agents in its social network (unit) for both resource types; this transfer occurs irrespective of location. This exchange represents internal knowledge transfer [ref!].  


For the spatial and social learning a  threshold can be imposed such that agents cannot learn from other agents who have knowledge `cognitive-distance-threshold` more than their own.  This dynamic represents cognitive distance - that is the fact that once the knowledge base between two entities is sufficiently large learning can be impeded (.e.g, through an absence of shared language or perspective).

The encounter procedure represents an individual learning via direct encounter with a resource, whereas the other two are forms of social learning.

At each time-step, agents move to a neighbouring patches (eight-cell neighbbourhood), following:

1. agents can not move to a patch that is in their memory (the most recently visited memory-length` patches)    

2. movement can be at random, or agents can preferentially move to a neighbouring cell with the type they are most knowledgeable about    

Eache time-step after an agent has reached an age of ten, there is a 10% chance of mortality.  On an agent's death, their offspring inherit some fraction of their knowledge (based on a uniform distribution, U[`parent-transfer`, 1) and all other attributes other than their patch visit memory. There is a chance (`defect-unit`) that the offspring will become a member of another unit, which represents an external transfer of knowledge to the unit [ref!]. 


#### Sensitivity Analysis

We conducted a local sensitivity analysis by altering each of the parameters by +-20% and calculated the change in the man knowledge about resource a held in unit 1.  If a 20% change in the input resulted in a more than 20% change in the state variable we deemed this parameter as sensitive.  We calculated a sensitivity index following Hamby [-@hambyReviewTechniquesParameter1994]:

$$ \phi_i = \frac{\% \Delta Y}{\% \Delta X_{i+i}} $$        
Eq. 1
 
#### Scenarios

**No change scenarios**

1. Baseline conditions

First, we explored the dynamics of the model under the different learning conditions and movement rules without any change in the availability of the resources over time.  Thus, we ran each combination of spatial learning, network learning, and random vs. preferential patch movement.  We ran 30 replicates for 30 generations with XXagents in XX social units for each of the eight learning/movement combinations [SM for SA on this?]. To evaluate the outcomes we measured the mean amount of knowledge for resource 'a' over generations and the risk of loss of knowledge (using a quasi-extinction threshold of five).

2. Effects of transfer-fraction etc.
3. 

**Amount of loss scenarios**

We explored the implications of the loss of access/availability of one of the resource types (type 'a') to assess how different modes of learning influence the retention of knowledge.  We simulate this loss by changing patches from one type to another at a specified rate; this could represent the loss of a species or the loss of access to the species (e.g., via protectionist regulations).   For each of the eight learning combinations explored under baseline conditions we evaluated four different rates of loss that results in a decline to  80%, 60%, 20% and 0% of initial resource availability.  The loss of knowledge occurred over a 250 time-step period.

**Rate of loss scenarios**

Same total amount lost butover different periods.

Total loss of 1000 (20%) over 100, 250, 500, 1000 ticks

**Loss and reinstatement scenarios**

- same as loss but reduce to 10% and then return to initial value with rate varying- 

- We also ran 10 replicates for each combination  for initial amounts of resource 'a' from 0.1 to 0.5 by a step of 0.05 with no change in availability over time; this allows us to provide estimate the quasi-equilibrial knowledge of each resource under different availabilities.

- 

**Resource preference**


| Scenario | Question | Parameterisation |
| :------- | :------- | :--------------- |
| a        | who      | 1                |
| b        | what     | 2                |
| c        | where    | 3                |
| d        | why      | 4                |
| e        | when     | 5                |


****

**Analysis**

We analysed the data visually and did not use frequentist statstics (following White et al. (2014, ref!). We used R version X for the analyses with packages XYZ.

### 



### Results

**SA**

...



**Scenarios **

...



### Discussion

**Retention of knowledge**

xyz



**Conditions for BCH**

aaa



Next steps**

- agent heterogeneity - propensity to learn, credibility of other agents., etc.

- spatial structure of both resources and agent movement (sort of a home range)

- multiple resource types

- empirical/place grounding

### References

### SM

- effects of n agents and n units

- transfer fractrion stuff

- who tl lear from in nwo