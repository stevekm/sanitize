# sanitize
Shell script to replace all occurences of strings in files

Quick shell script(s) to replace all occurences of provided patterns in field 1 of file `replace.tsv` with corresponding items in field 2.

## `sanitize_dir.sh`

Replace all occurences of the specified pattern(s) in all files found in the specified directory.

### Example
Sample items to replace:

```bash
$ cat replace.tsv
foo	bar
waffle	pancake
chocolate	vanilla
```

Before:

```bash
$ cat test/sample.txt
Hello this is foo. I have a
waffle. It is chocolate flavored.
I ate the waffle. Goodbye.
Sincerely,
foo
```

Run:

```bash
$ ./sanitize_dir.sh test/
foo, bar
waffle, pancake
chocolate, vanilla
```

After:

```bash
$ cat test/sample.txt
Hello this is bar. I have a
pancake. It is vanilla flavored.
I ate the pancake. Goodbye.
Sincerely,
bar
```

## `sanitize_names.sh`

Replace all occurences of the specified patterns in file, directory, and symlink names in the specified directory
