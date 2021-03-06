
xlsx_read_rels <- function(path, file) {
  xml <- xlsx_read_file_if_exists(path, xlsx_path_rels(file))

  if (is.null(xml)) {
    NULL
  } else {
    ## TODO: These are allowed to be external references I think; in
    ## which case the abs path here is not correct.
    ret <- rbind_df(lapply(xml2::xml_children(xml), xlsx_parse_relationship))
    ret$target_abs <- path_join(dirname(file), ret$target)
    ret
  }
}

xlsx_parse_relationship <- function(x) {
  at <- as.list(xml2::xml_attrs(x))
  tibble::data_frame(
    id = attr_character(at$Id),
    type = basename(at$Type),
    target = at$Target)
}

## Part 2, 9.3.3, p. 24
## > A special naming convention is used for the Relationships
## > part. First, the Relationships part for a part in a given folder
## > in the name hierarchy is stored in a sub-folder called
## > “_rels”. Second, the name of the Relationships part is formed by
## > appending “.rels” to the name of the original part. Package
## > relationships are found in the package relationships part named
## > “/_rels/.rels”.
xlsx_path_rels <- function(filename) {
  file.path(dirname(filename), "_rels",
            paste0(basename(filename), ".rels"))
}
