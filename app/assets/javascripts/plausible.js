function log_plausible(component_name) {
  plausible('Download', {props: {info: component_name}});
}
