# pdc_discovery

A discovery portal for Princeton research data. Initially it will provide a better browsing experience for the research data contained in [DataSpace](https://dataspace.princeton.edu).

[![CircleCI](https://circleci.com/gh/pulibrary/pdc_discovery.svg?style=svg)](https://circleci.com/gh/pulibrary/pdc_discovery)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pdc_discovery/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/pdc_discovery?branch=main)


## Dependencies
* Ruby: 2.6.6
* nodejs: 12.18.3
* yarn: 1.22.10
* Docker

## Local development

### Setup
1. Check out code
2. `bundle install`
3. `yarn install`
4. `rake servers:start`

### Running tests
1. Fast: `bundle exec rspec spec`
2. Run in browser: `RUN_IN_BROWSER=true bundle exec rspec spec`


## Deploying
pulbot: `pulbot deploy pdc_discovery to [staging|production]`

## Indexing research data from DataSpace

```ruby
rake index:research_data
```
