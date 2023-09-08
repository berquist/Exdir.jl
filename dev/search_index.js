var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Exdir","category":"page"},{"location":"#Exdir","page":"Home","title":"Exdir","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Exdir.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Exdir]","category":"page"},{"location":"#Exdir.Raw","page":"Home","title":"Exdir.Raw","text":"Raw objects are simple folders with any content.\n\nRaw objects currently have no features apart from showing their path.\n\n\n\n\n\n","category":"type"},{"location":"#Exdir.create_group-Tuple{Exdir.File, AbstractString}","page":"Home","title":"Exdir.create_group","text":"create_group(file, name)\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.create_group-Tuple{Exdir.Group, AbstractString}","page":"Home","title":"Exdir.create_group","text":"create_group(grp, name)\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.create_object_directory-Tuple{AbstractString, Any}","page":"Home","title":"Exdir.create_object_directory","text":"create_object_directory(directory, metadata)\n\nCreate object directory and meta file if the directory doesn't already exist.\n\nTODO say something about expected correctness of metadata dict.\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.exdiropen-Tuple{AbstractString, AbstractString}","page":"Home","title":"Exdir.exdiropen","text":"exdiropen(directory::AbstractString, mode::AbstractString)\n\nOpens an ExDir tree at path directory.\n\n\"r\": Open for reading only, failing if no file exists \"r+\": Open for reading and writing, failing if no file exists \"w\"/\"w+\": Open for reading and writing, overwriting the file if it already exists \"a\"/\"a+\": Open for reading and writing, creating a new file if none exists, but               preserving the existing file if one is present\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.form_location-Tuple{AbstractString}","page":"Home","title":"Exdir.form_location","text":"form_location(directory)\n\nPrepare the given directory location for use by removing any trailing slashes/directory signifiers, ensuring the directory ends with the .exdir extension, and making the directory path absolute.\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.is_exdir_object-Tuple{Any}","page":"Home","title":"Exdir.is_exdir_object","text":"WARNING: Does not test of inside exdir directory, only if the object can be an exdir object (i.e. a directory).\n\n\n\n\n\n","category":"method"},{"location":"#Exdir.require_group-Tuple{Exdir.Group, AbstractString}","page":"Home","title":"Exdir.require_group","text":"require_group(grp, name)\n\n\n\n\n\n","category":"method"}]
}
