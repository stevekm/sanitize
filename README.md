# sanitize

Clean files to remove unwanted patterns.

Use the included `patterns.tsv` file to list the old and new patterns for replacement (in that order), one set per line.

## Clean File Contents

Clean all occurrences of patterns inside of files:

```
make sanitize-file-contents FILE=/path/to/file.txt
```

Clean the contents of all files in a directory:

```
make sanitize-all-file-contents DIR=/path/to/some_directory
```

## Clean Filenames

Remove all occurrences of patterns from a filename:

```
make sanitize-filename FILE=/path/to/file.txt
```

Remove all occurrences of patterns in all filenames in a directory:

```
make sanitize-all-filenames DIR=/path/to/some_directory
```

# Examples

Some example files have been included to demonstrate.

The old files to be changed, and their contents:

```
$ ls -1 example
180316_NB501073_0036_AH3VFKBGX5-SampleSheet.csv
180917_NB501073_0067_AHCM3CAFXY-SampleSheet.csv

$ cat example/*
...
...
Sample_ID,Sample_Name,...
NC-IVS35,NC-IVS35,...
Patient5,Patient5,...
Patient6,Patient6,...
Patient8,Patient8,...
NTC-H2O,NTC-H2O,...
...
...
Sample_ID,Sample_Name,...
NC-IVS35,NC-IVS35,...
Patient1,Patient1,...
Patient2,Patient2,...
Patient3,Patient3,...
NTC-H2O,NTC-H2O,...
```

The patterns to change with (`old    new`)

```
$ cat patterns.tsv
Patient1	Sample1
Patient2	Sample2
Patient3	Sample3
Patient5	Sample5
Patient6	Sample6
Patient8	Sample8
180316_NB501073_0036_AH3VFKBGX5	Run1
180917_NB501073_0067_AHCM3CAFXY	Run2
```

Running the scripts:

```
$ make sanitize-all-file-contents DIR=example
...
>>> Sanitizing contents of file: example/180917_NB501073_0067_AHCM3CAFXY-SampleSheet.csv
...
>>> Sanitizing contents of file: example/180316_NB501073_0036_AH3VFKBGX5-SampleSheet.csv
...
...

$ make sanitize-all-filenames DIR=example
...
‘example/180917_NB501073_0067_AHCM3CAFXY-SampleSheet.csv’ -> ‘example/Run2-SampleSheet.csv’
...
‘example/180316_NB501073_0036_AH3VFKBGX5-SampleSheet.csv’ -> ‘example/Run1-SampleSheet.csv’
```

Changed files:

```
$ ls -1 example
Run1-SampleSheet.csv
Run2-SampleSheet.csv

$ cat example/*
...
Sample_ID,Sample_Name,...
NC-IVS35,NC-IVS35,...
Sample5,Sample5,...
Sample6,Sample6,...
Sample8,Sample8,...
NTC-H2O,NTC-H2O,...
...
Sample_ID,Sample_Name,...
NC-IVS35,NC-IVS35,...
Sample1,Sample1,...
Sample2,Sample2,...
Sample3,Sample3,...
NTC-H2O,NTC-H2O,...
```

# Software

- GNU `make`

- `bash`

- `perl`

- `sed`
