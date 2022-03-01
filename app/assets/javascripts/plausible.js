function log_plausible_file_download(filename) {
  console.log("log_plausible_file_download: " + filename);
  plausible("Download", { props: { info: filename } });
}

function log_plausible_globus_download(id) {
  console.log("log_plausible_globus_download: " + id);
  plausible("GlobusDownload", { props: { info: id } });
}
