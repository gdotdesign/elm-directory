# Elm Directory
This is a project to compile and display the documentation of Elm packages hosted on
Github.

## Main Features
- Reproducible: the database can be rebuilt from scratch
- Searchable: the documentation can be queried using PostgreSQLs JSON operators
- Cacheable: pages are generated so they can be cached easily
- SEO Friendly: pages contains the necessery meta tags
- Mobile Friendly

## Architecture and Installation
It's a **Ruby on Rails** application, using PostgreSQL and Redis.

The repository contains a `Dockerfile` and `docker-compose.yml`, to get started
follow these steps:

- clone the repository
- build the docker images `docker-compose build`
- create the database `docker-compose run web rake db:create`
- run the migrations `docker-compose run web rake db:migrate`
- start the server `docker-compose up`
- start importing all packages `docker-compose run web rake import`
	(you can stop after a few seconds with CTRL-C to have some packages)
- load the site on http://localhost:3000

For more information on how to use `docker-compose` with Rails check out
[this article](https://docs.docker.com/compose/rails/)

TODO: More content (CI, deployment, contribute, etc...)
