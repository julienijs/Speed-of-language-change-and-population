# Speed of language change and population
## About the project
This repository contains the script and datasets accompanying [the presentation (Nijs 2022)](https://kzm.be/programma-herfstvergadering-2022-15-oktober-2022-9-45-kantl-gent/) and article about the impact of population size on the speed of language change. I investigate whether language changes more rapidly in more densely populated cities, compared to less populated towns.

There exists a correlation between the demographic structure of the speech community and a language’s morphosyntactic structure. Bigger languages in high-contact communities have been found to be morphologically less complex and more reliant on lexical strategies and word order compared to smaller languages in close-knit communities (Lupyan & Dale 2010). This can be explained by the proportion of L2-speakers. Complex morphology is harder to acquire for adults, so a high proportion of L2-speakers leads to morphological simplification (Dale & Lupyan 2012). Since differences in morphosyntactic complexity are the result of diachronic processes, the propagation of these processes should occur more rapidly in more densely populated areas. The idea is that the propagation of language change will be faster in cities with a larger population compared to cities with a smaller population, since the growth of cities is often due to immigration, rather than natural growth, yielding an influx of L2-learners, with knock-on effects on the speech of the indigenous population.

## Data & code
This project incorporates three datasets: 
- A dataset of the hortative alternation (*laat ons naar het park gaan* vs *laten we naar het park gaan*)
- A dataset of the deflexion of *veel* (*in het gezelschap van vele mensen* vs *in het gezelschap van veel mensen*)
- A dataset with population sizes of cities in Belgium and the Netherlands in the 19th and 20th century (De Vries 1948; Chandler 1987; Bairoch, Batou, Chèvre 1988; Mitchell 1998)

The data for the two changes, together with the birthplaces of the authors, was extracted from C-CLAMP (Piersoul, De Troij & Van de Velde 2021), a corpus of Dutch excerpts from cultural magazines, written between 1837 and 1999. The data were then linked with population numbers from the year 1850 of the birthplaces of the authors. The resulting dataset was split into three bins, based on the size of the population for each birthplace, where each bin contains larger cities compared to the pervious bin. For each bin, one logistic regression model was fitted per change, with the variant as the response variable and the year as the predictor. Next, the slopes of these models were taken as a proxy for the speed of the change. For both changes, the largest slope belongs to the bin that contains the cities with the largest population count. However, there is considerable overlap between the confidence intervals of the slopes for both changes.

Results for the hortative alternation:

![Rplot](https://user-images.githubusercontent.com/107923146/212690814-0069dc5d-e288-4e78-b788-a28e6501a8e1.png)


Results for the deflection of *veel*:

![Deflexie van veel](https://user-images.githubusercontent.com/107923146/212686616-e951b6ff-717a-4384-97af-1e0f118c78c2.png)


Note: since the presentation and article are both in Dutch, the R script also produces graphs with annotations in Dutch.

## References
Datasets:
- Bairoch, P., Batou, J. & Chèvre, P. (1988). La population des villes européennes de 800 à 1850. Geneva: Librarie Droz.
- Chandler, T. (1987). Four thousand years of urban growth. Lewiston: St.David's University Press.
- De Vries , J. (1984). Europeanurbanization, 1500-1800. London: Methuen & Co.
- Mitchell, B.R. (1998). International historical statistics: Europe 1750-1993.London: Macmillan.
- Piersoul, J., Van de Velde, F., & De Troij, R. (2021). 150 Years of written Dutch: the construction of the Dutch corpus of contemporary and late modern periodicals (Dutch C-CLAMP). Nederlandse Taalkunde, 26(3), 339–362.

Language change:
- Dale, G. & Lupyan R. (2012). Understanding the origins of morphological diversity: the linguistic niche hypothesis. Advances in Complex Systems 15(3), 1150017-1-1150017-16.
- Lupyan, G. & Dale R. (2010). Language structure is partly determined by social structure. PLoS One 5(1).

Own research output:
- Nijs, J. (2022). Populatie en de verspreiding van taalverandering. KZM, oktober 2022.
