// Notice that we don't pass the document ID in our calls to Plausible
// because Plausible automatically groups events by the current page
// and we make these calls from the document Show page e.g. /catalog/:id
function log_plausible_file_download(filename) {
  console.log("log_plausible_file_download: " + filename);
  plausible("Download", { props: { filename: filename } });
}

function log_plausible_globus_download(id) {
  // Use a fake filename (globus-download) to track Globus downloads in the same property
  // as file downloads. This is so that we can fetch all downloads with a single Plausible
  // API call (see ./app/models/plausible.rb for more information)
  console.log("log_plausible_globus_download: " + id);
  plausible("Download", { props: { filename: "globus-download" } });
}

// The possible action values for citation are: "copy-apa", "copy-bibtex", "download-bibtex"
function log_plausible_citation(action) {
  console.log("log_plausible_citation_copy: " + action);
  plausible("Citation", { props: { action: action } });
}
