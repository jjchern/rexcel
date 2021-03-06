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

attr_bool <- function(x, missing=NA) {
  if (is.null(x)) missing else as.logical(as.integer(x))
}

attr_integer <- function(x, missing=NA_integer_) {
  if (is.null(x)) missing else as.integer(x)
}

attr_numeric <- function(x, missing=NA_real_) {
  if (is.null(x)) missing else as.numeric(x)
}

attr_character <- function(x, missing=NA_character_) {
  if (is.null(x)) missing else x
}

`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

process_container <- function(xml, xpath, ns, fun, ..., classes=NULL) {
  els <- xml2::xml_children(xml2::xml_find_first(xml, xpath, ns))
  if (isTRUE(classes)) {
    if (length(els) == 0L) {
      classes <- vcapply(fun(NULL, ns, ...), storage.mode)
    } else {
      classes <- NULL
    }
  }
  rbind_df(lapply(els, fun, ns, ...), classes)
}

## The function below is a faster version of
##
##   tibble::as_data_frame(do.call("rbind", x, quote=TRUE))
##
## But it avoids constructing a very hard to validate, slow to run
## function (on the order of a second), but it's not terrible nice to
## look at or understand.
rbind_df <- function(x, classes=NULL) {
  if (length(x) == 0L) {
    return(tibble_empty_data_frame(classes))
  }
  nms <- names(x[[1L]])
  xx <- unlist(x, FALSE)
  dim(xx) <- c(length(nms), length(x))
  if (is.null(classes)) {
    preserve <- logical(length(nms))
  } else {
    preserve <- classes == "list"
  }
  ul <- function(i, x) {
    if (preserve[[i]]) x else unlist(x)
  }
  tmp <- stats::setNames(lapply(seq_along(nms), function(i) ul(i, xx[i, ])), nms)
  tibble::as_data_frame(tmp)
}

tibble_empty_data_frame <- function(classes) {
  if (is.null(classes)) {
    ## NOTE: Once things settle down, this can be dropped.
    stop("deal with me")
    tibble::data_frame()
  } else {
    tibble::as_data_frame(lapply(classes, vector))
  }
}

progress <- function(fmt, total, ..., show=TRUE) {
  if (show && total > 0L) {
    pb <- progress::progress_bar$new(fmt, total=total)
    function(len=1) {
      invisible(pb$tick(len))
    }
  } else {
    function(...) {}
  }
}

path_join <- function(a, b) {
  na <- length(a)
  nb <- length(b)
  if (na == 1L && nb != 1L) {
    a <- rep_len(a, nb)
  } else if (nb == 1L && na != 1L) {
    b <- rep_len(b, na)
  } else if (na != nb && na != 1L && nb != 1L) {
    stop("Can't recycle vectors together")
  }

  i <- regexpr("(\\.\\./)+", b)
  len <- attr(i, "match.length", exact=TRUE)
  j <- len > 0L
  if (any(j)) {
    b[j] <- substr(b[j], len[j] + 1L, nchar(b[j]))
    len[j] <- len[j] / 3

    tmp <- strsplit(a[j], "/", fixed=TRUE)
    for (k in seq_along(tmp)) {
      tmp[[k]] <- paste(tmp[[k]][seq_len(length(tmp[[k]]) - len[j][[k]])],
                        collapse="/")
    }
    a[j] <- unlist(tmp)
  }
  paste(a, b, sep="/")
}

## TODO: replace as.list(xml2::xml_attrs(...)) with this where NULL
## values are OK.
xml_attrs_list <- function(x) {
  if (is.null(x)) {
    structure(list(), names=character())
  } else {
    as.list(xml2::xml_attrs(x))
  }
}

as_na <- function(x) {
  ret <- NA
  storage.mode(ret) <- storage.mode(x)
  ret
}
