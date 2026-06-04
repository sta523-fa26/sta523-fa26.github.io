#!/usr/bin/env Rscript
#
# One-time prep: download the canonical CIFAR10 binary distribution, parse the
# batch files, and write `train.rds` and `test.rds` into
# `static/slides/data/cifar10/`. The output files are gitignored.
#
# Run from the repo root:
#   Rscript static/slides/data/_prep_cifar10.R

out_dir = file.path("static", "slides", "data", "cifar10")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

url    = "https://www.cs.toronto.edu/~kriz/cifar-10-binary.tar.gz"
tgz    = file.path(out_dir, "cifar-10-binary.tar.gz")
extract_dir = file.path(out_dir, "extracted")

if (!file.exists(tgz)) {
  message("Downloading CIFAR10 (~170 MB) ...")
  options(timeout = max(600, getOption("timeout")))
  utils::download.file(url, tgz, mode = "wb")
}

dir.create(extract_dir, recursive = TRUE, showWarnings = FALSE)
utils::untar(tgz, exdir = extract_dir)

batch_dir = file.path(extract_dir, "cifar-10-batches-bin")

classes = readLines(file.path(batch_dir, "batches.meta.txt"))
classes = classes[nzchar(classes)]

read_batch = function(path) {
  n = 10000L
  raw = readBin(path, what = "raw", n = n * 3073L)
  m   = matrix(raw, nrow = 3073L, ncol = n)
  y   = as.integer(m[1L, ]) + 1L
  x   = array(as.integer(m[-1L, ]), dim = c(32L, 32L, 3L, n))
  x   = aperm(x, c(4L, 3L, 2L, 1L))
  storage.mode(x) = "integer"
  list(x = x, y = y)
}

train_files = sprintf(file.path(batch_dir, "data_batch_%d.bin"), 1:5)
train_list  = lapply(train_files, read_batch)

train_x = do.call(abind::abind, c(lapply(train_list, `[[`, "x"), list(along = 1L)))
train_y = unlist(lapply(train_list, `[[`, "y"))

test = read_batch(file.path(batch_dir, "test_batch.bin"))

train = list(x = train_x, y = as.integer(train_y), classes = classes)
test  = list(x = test$x,  y = as.integer(test$y),  classes = classes)

saveRDS(train, file.path(out_dir, "train.rds"), compress = "xz")
saveRDS(test,  file.path(out_dir, "test.rds"),  compress = "xz")

message(
  "wrote ", file.path(out_dir, "train.rds"),
  " (", paste(dim(train$x), collapse = "x"), ")"
)
message(
  "wrote ", file.path(out_dir, "test.rds"),
  " (", paste(dim(test$x), collapse = "x"), ")"
)

unlink(extract_dir, recursive = TRUE)
