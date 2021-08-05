# pdc_discovery

A discovery portal for Princeton research data. Initially it will provide a better browsing experience for the research data containted in [DataSpace](https://dataspace.princeton.edu).

[![CircleCI](https://circleci.com/gh/pulibrary/pdc_discovery.svg?style=svg)](https://circleci.com/gh/pulibrary/pdc_discovery)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pdc_discovery/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/pdc_discovery?branch=main)


## Dependencies
* Ruby: 2.6.6
* nodejs: 12.18.3
* yarn: 1.22.10

## Deploying
pulbot: `pulbot deploy pdc_discovery to [staging|production]`

## Indexing sample data

```ruby
rake index:sample_data
```
