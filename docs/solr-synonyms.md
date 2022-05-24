# Solr Synonyms

We utilize solr synonyms on the Authors field to translate between a given names and their hypocoristics or pet names.  This allows us to search for Dan and return results for Authors with a given name of Daniel.

We are limiting the synonyms currently to only the author field so we do not encounter large numbers of results that seem irrelevant.

The work we did in this repository was directed by the documentation [here](https://library.brown.edu/create/digitaltechnologies/using-synonyms-in-solr/)

## Determining which fields get synonyms applied

The fields that have synonyms applied to them is determined by the [solr/conf/schema.xml](../solr/conf/schema.xml)

A field type is define, such as `text_name_en` which applies the `solr.SynonymFilterFactory` either at query time, index time, or both.  We have currently applied the filter at query time so that it is easy to update the synonym list without a re-index.

That field type is then utilized in a field like `author_tesim`to complete the configuration.

## Defining Synonyms

The synonyms are defined in a text file in the [solr/conf/](../solr/conf/) directory.  We are currently utilizing the generic synonym file [solr/conf/synonyms.txt](../solr/conf/synonyms.txt)

We may want to consider moving to a subject based synonym file if we utilize them in more fields types in the future.  This can be accomplished by changing the name of the file in the `synonyms` attribute of the `solr.SynonymFilterFactory`.

### Adding Synonyms
To add additional synonyms, you would add additional lines to the `synonyms.txt` file.  For example: `Carolyn, Carol, Lyn, Lynn`  

We are Utilizing the synonym format that translates both Dan to Daniel and Daniel to Dan `dan,daniel`. To translate only one direction you can utilize the format `dan=>daniel` which would only return results for Daniel and Dan if Dan is searched for.  If Daniel is searched for we would not return results for Dan. See the Solr documentation for more information on the formats of [synonyms](https://lucene.apache.org/core/8_0_0/analyzers-common/org/apache/lucene/analysis/synonym/SolrSynonymParser.html)

Also Notice: I utilize lowercase as I have passed the `ignoreCase="true"` option to the `solr.SynonymFilterFactory`.  If we find the need to make the matches more specific we could turn this off.