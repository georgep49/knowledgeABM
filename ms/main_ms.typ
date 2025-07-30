
#set par(leading: 1.2em)
#set par.line(numbering: i => if calc.rem(i, 5) == 0 { i })

= Erosion of SEM: an ABM

== Introduction

Social-ecological systems can show non-linear and surprising behaviours in response to changes in social and environmental conditions @reyersSocialecologicalSystemsInsights2018. For example, tipping points - where there is rapid change in system state when some threshold is passed - and hysteresis - the difficulties in reversing these changes - challenge xxx [ref!].  The ability of a system to resist such change is called its 'resilience' [ref!].    


Social-ecological memory (SEM) is a fundamental component of a social-ecological system's resilience to change @folkeSynthesisBuildingResilience2002.  It is dynamic, and continually reshaped in positive and negative ways, both internally (e.g. as social norms within a group change) and externally (e.g., as knowledge from beyond a group is transferred into it).  Knowledge-belief-practice (KBP) complexes underpin SEM.  These represent the long-term set of behaviours developed by humans based on repeated interactions with their environments [ref!]. A repeated outcome of colonialism has been the erosion of KBP complexes, whether intentional or otherwise. For example, many indigenous people have been deprived access to traditional resources by legislative means (a direct loss) and through dwindling populations of some species (an indirect loss); of course, these losses interact as perceived conservation threats leadsto regulatory mechanisms aimed at 'protecting' a species @hartelTraditionalEcologicalKnowledge2023.  There is growing interest in understanding the conditions under which KBP are maintained, the trajectory of their loss, and how they might be reinstated if eroded or lost.

Regime shift dynamics in social-ecological systems have been the focus of recent attention #cite(<farahbakhshModellingCoupledHuman2022>), with concepts such as tipping points and hysteresis applied to social systems.  For example, Bausch et al. #cite(<bauchEarlyWarningSignals2016>, form: "year") show how human behaviour in a coupled human-environment system can drive regime shifts in forest cover; likewise, #cite(<mathiasExploringNonlinearTransition2020>, form: "prose") explore how social and ecological regime shifts can influence each other.  The focus of this research is often on how changes in human behaviour or activity trigger ecological change and the feedbacks between them.  Nevertheless, regime shifts could involve rapid change in KBP themselves, and not just the biophysical environment.

#cite(<lyverBioculturalHysteresisInhibits2019>, form: "prose") describe a conceptual model of how social-ecological systems can suffer 'biocultural hysteresis'. In their model, following the erosion of a KBP complex,  positive feedbacks act to maintain a new state potentially even after the mechanisms underpinning the loss are removed. In such settings, the restoration of the biological resource may be insufficient to restore the knowledge associated with it.  As #cite(<lyverBioculturalHysteresisInhibits2019>, form: "prose") and #cite(<hartelTraditionalEcologicalKnowledge2023>, form: "prose") emphasise, hysteresis implies that the loss of KBP persists even if access to the resource is reinstated (the state of the system is a function of its history, not just contemporary social-ecological conditions).  In a similar way, #cite(<hartelTraditionalEcologicalKnowledge2023>) argue that "TEK stays alive and useable in the long term only through reinforcing certain types of feedbacks, values, and beliefs" (p. 213)). Following #cite(<fischerLeveragePointsPerspective2019>, form: "prose") and  et al. #cite(<absonLeveragePointsSustainability2017>, form: "prose"), they envisage social-ecological systems as comprising different levels from shallow to deep (Figure X). Drawing on this framework, #cite(<hartelTraditionalEcologicalKnowledge2023>, form: "prose") identify conditions where KBP might be irreversibly changed: (i) system levels are misaligned (e.g., local practices [parameters and feedbacks] do not align with economic hopes [intent]), (ii) external pressures impose disconnection, (iii) corruption, and (iv) demographic shifts (e.g. immigration into a local community) result in a dilution of the KBP.  

In parallel, quantitative sociologists have explored the conditions under which opinions and culture form and persist, and how these dynamics are influenced by social learning <castellanoStatisticalPhysicsSocial2009>.  For example, agent-based models have been used to explore how different opinions and beliefs might spread through social networks and subsequently persist.  This body of research demonstrates that different types of social interaction and learning will determine how information flows through social systems <flacheModelsSocialInfluence2017>, which influences human-environment feedbacks <farahbakhshModellingCoupledHuman2022>.  Proximity in various forms is an important control on knowledge sharing. #cite(<boschmaProximityInnovationCritical2005>, form: "prose") argues that the effectiveness of knowledge exchange is not likely to be a monotonic response to distance -- for example, if knowledge exchange only occurs very locally (high geographic distance) or within very similar social groups (high social proximity) then lock-in effects may inhibit learning or innovation. There are clear links between these perspectives about proximity and exchange, and the challenges of the dynamic retention of TEK described above.  The mechanisms that underpin the erosion of a KBP complex act in multiple ways to change the proximity between individuals and each other and individuals and the environment.  

Agent-based models (ABMs) represent complex systems in an atomistic way.  That is they seek to represent the units of a system and their interactions to explore how macroscopic dynamics emerge from them [ref!].  They have ben widely used in the social sciences to explore how society-level dynamics (e.g., civil unrest) can be generated from interactions between individual humans and groups.  In the specific context of knowledge loss, analytic models and ABMS have been used to explore changes in linguistic diversity and the extinction of languages, potentially one of the greatest possible erosions of social-ecological memory. 

Abrams and Strogatz [ref!] present a minimal model of language change between speakeRs of two languages (X and Y), which is aggregated and not spatial but informative:
$ (d x) / (d t) = y P_(y x)(x, s) - x P_(x y)(x, s) $

where: x is the fraction of the population speaking language X, s is the languages statues ($0 <= s <= 1$), $P_(x y)(x, s)$ is the probability of a speaker of x switching to y and vice versa.

#linebreak()

Analysis of this model suggests that a truly bilingual society with mixed populations of speakers is unstable.,  However, the status ($s$) of a language (i.e., the opportunities its users derive) is critical in persistence, and Abrams and Strogatz [ref!] argue that education an other policies have a critical role in increasing it and can lead to a stable bilingual population. In a spatial agent-based model informed by XYZ, Civico ref! explored how speakers might shift between competing languages and the implications for these dynamics of the persistence of minority language.  The model suggests that exogamy has major NEGATIVE EFFECts on persistence especially via effects on intergenenerational  transmission but that active education of the minority language has strong and persistent effects, especially if initiated prior to significant decline. Thus, these models point to the importance of knowledge transmission, and benefits and opportunity for use as key determinants of the persistence of minority languages.

Here, we use an agent-based model (ABM; ref!) to explore the conditions under which biocultural hysteresis might arise.  In our model, agents interact with two types of resources and develop inter-generational understanding of their use through direct interaction and social learning; learning is affected by spatial cognitive, and social proximity. In particular we ask the following questions:

1. How do social, geographic, and cognitive proximity affect levels of knowledge about the use of a resource in a stable environment?    

2. How do different modes of knowledge exchange affect levels of knowledge about the use of a resource in a stable environment?    

3. How do KBP respond to socio-ecological change (loss and reinstatement of access):
   (a) Do different modes of learning provide resilience against erosion of knowledge following the permanent reduction or loss of access to a resource?
   (b) Under what conditions do biocultural hysteresis affects emerge following the reduction or loss and then reinstatement of access to a resource?


= Methods

Here we provide a high-level description of the agent-based model we used to explore the conditions under which biocultural hysteresis might arise; a full description using the ODD protocol (Grimm ref!) is provided as Supplementary Material. Our ABM is implemented in NetLogo 6.4 @wilenskyNetLogo6401999.


== Model description

==== Landscape
The model landscape is a grid with two types of grid cells (labelled 'a' and 'b') representing sources of different knowledge - these represent places where specific species or geographic features are present. The grid comprises 50 x 50 square grid cells (patches). We assume that a patch can not contain both types of resource. The types are not inherently positive or negative, just different.  The initial amount of type 'a' in the landscape is controlled by the `n-p-a` parameter, with patches allocated to each type at random.    

==== Agents
Agents belong to units (i.e., a social network), with the number of agents and units controlled by the `n-agents-per-unit` and `n-unit` parameters, respectively.  There is neither antagonism nor collaboration between different units; rather they are social groupings that internally share knowledge.  Agents move through the landscape, and, as they do so, their understanding of how to 'use' each of the two resource types changes; this knowledge is represented as a value from 0-100.  This updating happens in three ways:
  + Encounter - at each time step, each agent updates its knowledge based on resource of the current patch, following a logistic curve. At each time step, there is a slight loss of knowledge of the use of the resource type different to the one of the agent is in; the rate of this loss is controlled by `k-erosion`.    
  + Spatial learning - if there are other agents within some radius `spatial-nhb`, then each agent will gain a fraction (`transfer-fraction`) of the difference between its knowledge and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all other agents on the patch for both resource types.     
  + Social learning - each agent will gain a fraction (`transfer-fraction`) of the difference between it and that of either: (i) a random, (ii) the most knowledgeable agent, or (iii) the median knowledge across all agents in its social network (unit) for both resource types; this transfer occurs irrespective of location. This exchange represents internal knowledge transfer [ref!].  
  
#linebreak()

For both spatial and social learning a threshold can be imposed such that agents cannot learn from other agents who have knowledge `cognitive-distance-threshold` more than their own.  This dynamic represents cognitive distance - that is the fact that once the knowledge base between two entities is sufficiently large learning can be impeded (e.g., through an absence of shared language or perspective). The encounter procedure represents an individual learning via direct encounter with a resource, whereas the other two are forms of social learning.

At each time-step, agents move to a neighbouring patches, under the following constraints:

1. agents can not move to a patch that is in their memory (the most recently visited `memory-length` patches)    
2. movement can be at random, or agents can preferentially move to a neighbouring cell with the type they are most knowledgeable about    

Each time-step after an agent has reached an age of ten, there is a 10% chance of mortality.  On an agent's death, their offspring inherit some fraction of their knowledge (based on a uniform distribution, U[`parent-transfer`, 1]) and all other attributes other than their patch visit memory. There is a chance (`defect-unit`) that the offspring will become a member of another unit, which represents an external transfer of knowledge to the unit [ref!]. 
  
#linebreak()

== Metrics
We used two metrics to describe the state of the system: (i) median knowledge held about resource _a_ across all social units and (ii) the bimodality coefficient @pfisterGoodThingsPeak2013, which takes values [0,1] with values greater than 5/9 indicating a bimodal distribution:

$ B C = g^2 + 1 / (k + 3 (n-1)^2 / ((n-2)(n-3))) $

where _n_ is the sample size, and _g_ and _k_ are the sample skewness and kurtosis, respectively
 
== Sensitivity Analysis
We conducted a local sensitivity analysis by altering each of the parameters by 20% and calculated the change in the median knowledge about resource _a_ across all social units.  If a 20% change in the input resulted in a more than 20 change in the state variable we deemed this parameter sensitive.  We calculated a sensitivity index following #cite(<hambyReviewTechniquesParameter1994>, form: "prose") 

== Scenarios

==== No change scenarios

1. Baseline conditions

First, we explored the dynamics of the model under the different learning conditions and movement rules without any change in the availability of the resources over time.  Thus, we ran each combination of spatial learning, network learning, and random vs. preferential patch movement.  We ran 30 replicates for 50 generations with 120 agents evenly distributed across three social units for each of the eight learning/movement combinations. To evaluate the outcomes, we measured the mean amount of knowledge for resource 'a' over generations and the risk of loss of knowledge (using a quasi-extinction threshold of five).

2. Effects of number of units and agents
- varied 1 with n-units 1-6 and n-agents-per-unit 20-10-60

2. Effects of different proximities

- scenario 1 with cognitive distance (10, 20, 30, 60) and credibility threshold (on-off)

3. Effects of different transfer types

4. Effects of different resource preferences
	 - scenario 1 w/ res-a-preference from 1 to 1.5, 0.05, n = 30

==== Amount of loss scenarios

We explored the implications of the loss of access/availability of one of the resource types (type 'a') to assess how different modes of learning influence the retention of knowledge.  We simulate this loss by changing patches from one type to another at a specified rate; this could represent the loss of a species or the loss of access to the species (e.g., via protectionist regulations).   For each of the eight learning combinations explored under baseline conditions we evaluated four different rates of loss that results in a decline to 80%, 60%, 20% and 0% of the initial resource availability in the landscape.  The loss of knowledge occurred over a 250 time-step period.

==== Rate of loss scenarios

Same total amount lost but over different periods.

Total loss of 1000 (20%) over 100, 250, 500, 1000 ticks

==== Loss and reinstatement scenarios

- same as loss but reduce to 10% and then return to initial value with rate varying- 

- We also ran 10 replicates for each combination for initial amounts of resource 'a' from 0.1 to 0.5 by a step of 0.05 with no change in availability over time; this allowed us to estimate the quasi-equilibrial knowledge of each resource under different availabilities.

- 



| Scenario | Question | Parameterisation |
|:-------- |:-------- |:---------------- |
| a        | who      | 1                |
| b        | what     | 2                |
| c        | where    | 3                |
| d        | why      | 4                |
| e        | when     | 5                |


*Analysis*

We analysed the data visually and did not use frequentist statistics, following #cite(<whiteEcologistsShouldNot2014>, form: "prose"). We used R version X for the analyses with packages XYZ.
 

= Results

== SA

...

== Scenarios

...

= Discussion

*Retention of knowledge*

xyz

*Conditions for BCH*

aaa
norms Perry et al. ref!

=== Next steps

Our ABM is stylised and does not represent some characteristics of real social-ecological systems.  Nevertheless, it is sufficient to enable us to explore the conditions under which social-ecological KBP are maintained or otherwise.  There are some key areas where the model representation could be refined:

- the agents are homogeneous in their propensity to learn, etc.

- spatial structure of both resources and agent movement (sort of a home range)  ---> Prochazka and Vogl note the spatial dimensions as strong as the temporal ones in language change

- two resources - multiple resource types

- empirical/place grounding

- what is erosion - practice vs protocol 

#bibliography("bcHysteresis.bib", style: "global-ecology-and-biogeography.csl")


// ### SM

// - effects of n agents and n units
  
//   - baseline_nunits: 0-5 units, 60, 120, 180, 240 agents, n = 10

// - transfer fraction stuff
// 	- transfer_fraction, parent_transfer, n = 10

// - who to lear from in nw
// 	- max, median, rnd, n = 30