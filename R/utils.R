vlapply <- function(X, FUN, ...) {
  vapply(X, FUN, logical(1), ...)
}
viapply <- function(X, FUN, ...) {
  vapply(X, FUN, integer(1), ...)
}
vnapply <- function(X, FUN, ...) {
  vapply(X, FUN, numeric(1), ...)
}
vcapply <- function(X, FUN, ...) {
  vapply(X, FUN, character(1), ...)
}

attrs_to_matrix <- function(x, mode=NULL) {
  dat <- xml2::xml_attrs(x)
  nms <- unique(unlist(lapply(dat, names)))
  ret <- t(vapply(dat, function(x) x[nms], character(length(nms))))
  if (length(nms) == 1L) {
    ret <- t(ret)
  }
  if (length(nms) > 0L) {
    colnames(ret) <- nms
  }
  if (!is.null(mode)) {
    if (mode == "integer" || mode == "logical") {
      ret[ret == "false"] <- "0"
      ret[ret == "true"] <- "1"
    }
    storage.mode(ret) <- mode
  }
  ret
}