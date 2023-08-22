# Generating the DataSpace Migration Spreadsheet

## Generating a full migration spreadsheet
1. `bundle exec rake migration:produce_full_spreadsheet`

## Generating a delta 
1. Download the current migration spreadsheet as a .csv file
2. Invoke the `produce_delta_spreadsheet` rake task and point to the current migration spreadsheet, like this:
   ```
     bundle exec rake migration:produce_delta_spreadsheet\["/Users/bess/projects/pdc_discovery/spec/fixtures/migration/migration_in_progress.csv"]
   ```