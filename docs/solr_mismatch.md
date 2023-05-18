1. Open a solr console in pul_solr
1. Under Collections
   1. Loop at the pdc-discovery-* alias and see which one is currently in service
   2. click on the other one and delete it 
   3. Click on Add Collection
      1. Name it the same as what you just deleted
      1. Choose the pdc-discovery config set
      1. Choose 2 shards
   4. Delete the alias
   5. Recreate the alias pdc-discovery-* (staging/prod) and point it to the one you just created above
 1. reindex in pdc-discovery 
