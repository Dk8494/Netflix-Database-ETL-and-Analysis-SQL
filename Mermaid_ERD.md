# Netflix Database Entity-Relationship Diagram (ERD)

## Overview
This ERD (Entity-Relationship Diagram) provides a visual representation of the relationships between the various tables in the Netflix shows and movies database. It is designed to help users understand how different tables are interconnected and how data flows within the database. 

## ERD Diagram
To view the ERD, you can use tools that support the Mermaid syntax. Below is the ERD code written in Mermaid format (click on the copy icon on the ERD to retrieve the code):

```mermaid
erDiagram
ALL_SHOW_INFO ||--o{ MISC : "includes"
ALL_SHOW_INFO ||--o{ MOVIES : "includes"
ALL_SHOW_INFO ||--o{ TIME_INFO : "includes"
ALL_SHOW_INFO ||--o{ CASTING : "includes"
ALL_SHOW_INFO ||--o{ DATA_RATING : "includes"
ALL_SHOW_INFO ||--o{ MOVIE_INFO : "includes"
ALL_SHOW_INFO ||--o{ DATA_LISTED_IN : "includes"
ALL_SHOW_INFO ||--o{ MOVIE_DESCRIPTIONS : "includes"

CASTING ||--o{ DIRECTOR : "involves"
CASTING ||--o{ CAST : "features"
DATA_RATING ||--o{ RATING : "classifies"
DATA_LISTED_IN ||--o{ LISTED_IN : "categorizes"

ALL_SHOW_INFO {
    int show_id PK
    string title
    string director_name
    string cast_members
    string country_name
    date date_added
    int release_year
    string rating_description
    string duration
    string listed_name
    text description
    string type_name
}

MOVIES {
    int show_id PK
    string title
}

DIRECTOR {
    int director_id PK
    string director_name
}

CAST {
    int cast_id PK
    string cast_members
}

CASTING {
    int show_id PK
    int director_id FK
    int cast_id FK
}

TIME_INFO {
    int show_id PK
    date date_added
    int release_year
}

MOVIE_INFO {
    int show_id PK
    string duration
}

MOVIE_DESCRIPTIONS {
    int show_id PK
    text description
}

MISC {
    int show_id PK
    string type_name
    string country_name
}

DATA_RATING {
    int show_id PK
    int rating_id FK
}

DATA_LISTED_IN {
    int show_id PK
    int listed_id FK
}

LISTED_IN {
    int listed_id PK
    string listed_name
}

RATING {
    int rating_id PK
    string rating_description
}
```

## How to Use
1. Copy the Mermaid code provided below.
2. Paste it into a Mermaid-compatible viewer or online tool.
3. The tool will render a visual diagram based on the code.

This ERD is a comprehensive guide to understanding the structure and relationships within the Netflix shows and movies database.
