# pdc_discovery

A discovery portal for Princeton research data. Initially it will provide a better browsing experience for the research data contained in [DataSpace](https://dataspace.princeton.edu).

[![CircleCI](https://circleci.com/gh/pulibrary/pdc_discovery.svg?style=svg)](https://circleci.com/gh/pulibrary/pdc_discovery)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pdc_discovery/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/pdc_discovery?branch=main)


## Dependencies
* Ruby: 2.6.6
* nodejs: 12.18.3
* yarn: 1.22.10
* [Lando](https://github.com/lando/lando/releases): 3.0.0

## Local development

### Setup
1. Check out code
2. `bundle install`
3. `yarn install`

### Starting / stopping services
We use lando to run services required for both test and development environments.

Start and initialize solr and database services with:

`bundle exec rake servers:start`

To stop solr and database services:

`bundle exec rake servers:stop` or `lando stop`

### Running tests
1. Fast: `bundle exec rspec spec`
2. Run in browser: `RUN_IN_BROWSER=true bundle exec rspec spec`

### Starting the development server
*`foreman` is used to enable [Hot Module Replacement for Webpack](https://webpack.js.org/concepts/hot-module-replacement/).*

1. `bundle exec foreman start`
2. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

You can also use two terminal windows instead of `foreman` to start the Rails application and the Webpack server.
This is convenient when you need to step through the code as `byebug` does not always show the prompt when using `foreman`.

1. Terminal one: `bin/rails s -p 3000`
2. Terminal two: `bin/webpack-dev-server`
3. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

## Deploying
pulbot: `pulbot deploy pdc_discovery to [staging|production]`

## Indexing research data from DataSpace

```ruby
rake index:research_data
```
