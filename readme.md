# Netflix Data Analysis Using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project focuses on analyzing Netflix data using SQL to uncover trends, insights, and actionable business strategies. By querying a dataset containing information about Netflix’s content, we aim to address key business problems related to content distribution, audience preferences, and platform growth.

---

## Key Business Problems Solved

1. **[Distribution of Content Types](#distribution-of-content-types)**: Analyzed the proportion of Movies versus TV Shows to understand content distribution.
2. **[Common Ratings Analysis](#common-ratings-analysis)**: Identified the most frequent ratings assigned to content to infer target audience demographics.
3. **[Content Release Analysis](#content-release-analysis)**:
   - By Year: Examined the number of releases per year to identify trends over time.
   - By Country: Determined the volume of content produced by different countries to assess regional production strengths.
4. **[Content Duration Analysis](#content-duration-analysis)**:
   - Movies: Analyzed the distribution of movie durations to understand standard lengths.
   - TV Shows: Assessed the number of seasons to gauge series longevity.
5. **[Genre and Keyword Categorization](#genre-and-keyword-categorization)**: Explored content descriptions to categorize shows and movies based on genres and prevalent themes.
6. **[Actor and Director Collaboration Networks](#actor-and-director-collaboration-networks)**: Investigated common collaborations between actors and directors to identify frequent partnerships.
7. **[Content Addition Trends](#content-addition-trends)**: Analyzed the timeline of content additions to Netflix to understand platform growth and content acquisition strategies.
8. **[Missing Data Identification](#missing-data-identification)**: Identified records with missing information to assess data quality and areas requiring data enrichment.

---

## Objectives
- Perform SQL-based analysis on Netflix’s content dataset.
- Derive actionable insights to inform content strategy and platform growth.
- Utilize advanced SQL techniques such as joins, subqueries, and window functions.

---

## Dataset Overview
The dataset contains information on Netflix’s Movies and TV Shows, including:

- **Title**: Name of the content.
- **Type**: Content category (Movie or TV Show).
- **Director**: Director of the content (if available).
- **Cast**: Key cast members.
- **Country**: Country of production.
- **Date Added**: When the content was added to Netflix.
- **Release Year**: Year the content was released.
- **Rating**: Content rating (e.g., PG, R).
- **Duration**: Length of the Movie or number of seasons for TV Shows.
- **Genre**: Categories or keywords describing the content.
- **Description**: Brief summary of the content.

---

## List of Business Problems and Solutions

### Distribution of Content Types
```sql
SELECT
    type,
    COUNT(*) AS count
FROM netflix_data
GROUP BY type;
```
**Insight**: Determines the balance between Movies and TV Shows on the platform.

### Common Ratings Analysis
```sql
SELECT
    rating,
    COUNT(*) AS count
FROM netflix_data
GROUP BY rating
ORDER BY count DESC;
```
**Insight**: Identifies the most frequently assigned ratings to target specific audience demographics.

### Content Release Analysis
#### By Year
```sql
SELECT
    release_year,
    COUNT(*) AS count
FROM netflix_data
GROUP BY release_year
ORDER BY release_year DESC;
```
#### By Country
```sql
SELECT
    country,
    COUNT(*) AS count
FROM netflix_data
WHERE country IS NOT NULL
GROUP BY country
ORDER BY count DESC
LIMIT 10;
```
**Insight**: Tracks trends in content production over time and highlights key production regions.

### Content Duration Analysis
#### Movies
```sql
SELECT
    duration,
    COUNT(*) AS count
FROM netflix_data
WHERE type = 'Movie'
GROUP BY duration
ORDER BY count DESC;
```
#### TV Shows
```sql
SELECT
    duration AS seasons,
    COUNT(*) AS count
FROM netflix_data
WHERE type = 'TV Show'
GROUP BY seasons
ORDER BY count DESC;
```
**Insight**: Understands typical durations for Movies and TV Shows.

### Genre and Keyword Categorization
```sql
SELECT
    genre,
    COUNT(*) AS count
FROM netflix_data
GROUP BY genre
ORDER BY count DESC
LIMIT 10;
```
**Insight**: Identifies popular genres and themes.

### Actor and Director Collaboration Networks
```sql
SELECT
    director,
    GROUP_CONCAT(DISTINCT actor) AS actors
FROM netflix_data
CROSS APPLY STRING_SPLIT(cast, ', ')
GROUP BY director;
```
**Insight**: Maps frequent collaborations between directors and actors.

### Content Addition Trends
```sql
SELECT
    YEAR(date_added) AS year,
    COUNT(*) AS count
FROM netflix_data
WHERE date_added IS NOT NULL
GROUP BY year
ORDER BY year DESC;
```
**Insight**: Tracks growth in Netflix’s content library over time.

### Missing Data Identification
```sql
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_directors,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_countries
FROM netflix_data;
```
**Insight**: Highlights areas requiring data enrichment to improve analysis accuracy.

---

## Future Enhancements
- **Predictive Analysis**: Use time-series forecasting to predict future content trends.
- **Sentiment Analysis**: Leverage viewer reviews to analyze content reception (if data available).
- **Recommendation Systems**: Build collaborative filtering models using SQL and machine learning.
- **Regional Insights**: Deeper exploration of regional trends and preferences.

---

## Tech Stack Used
- **Database**: MySQL
- **Development Tool**: MySQL Workbench
- **Version Control**: GitHub

---

## Conclusion
This project showcases the utility of SQL in deriving actionable insights from Netflix’s content dataset. By addressing critical business problems, it provides a foundation for informed decision-making in content strategy and platform growth.

Explore the complete repository and contribute: [GitHub Repository](https://github.com/YashChowdhary34/netflix-data-analysis-SQL).

