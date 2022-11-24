# Web scraper for financial news

## Installation
- There's no need install nothing, but this project requires `yarn >= 2.0.0`;
- The reason for that is because this project works with **Zero-Install** feature.

## Running
- To run this project the following command must executed `yarn start`;
- The project will be started at port `3333`.

## How it works
- After running the project, a endpoint will be avaiable to requests;
- This endpoint is a **POST** where the body can contain:
  - `source`: is **required** and must be an array, the avaiable sources are **infomoney** and **istoedinheiro**;
  - `start_date`: is **optional**;
  - `end_date`: is **optional**.
- It will trigger the process of collecting the data, after it the news will be saved in a **csv** file.

# To do

- Must have an endpoint to trigger the start of collecting data from web
  - This endpoint **must** receive the start_date and the end_date on request body;
  - Also, **must** receive the source of the news that will collected, initially **infomoney** and **istoedinheiro**;
