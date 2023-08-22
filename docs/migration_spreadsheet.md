# Generating the DataSpace Migration Spreadsheet

## Generating a full migration spreadsheet
1. `bundle exec rake migration:produce_full_spreadsheet`

## Generating a delta 
1. Download the current migration spreadsheet as a .csv file
2. Check whether any new collections should be added to `config/collections.csv`
3. Invoke the `produce_delta_spreadsheet` rake task and point to the current migration spreadsheet, like this:
   ```
     bundle exec rake migration:produce_delta_spreadsheet\["/Users/bess/projects/pdc_discovery/spec/fixtures/migration/migration_in_progress.csv"]
   ```
4. It will produce a spreadsheet named like `delta_dataspace_migration_spreadsheet_2023_08_22_19_55.csv` in the `/tmp` directory.