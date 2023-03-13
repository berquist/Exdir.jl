module Exdir

import YAML

export attributes,
    create_dataset,
    create_group,
    exdiropen,
    is_nonraw_object_directory,
    setattrs!

# metadata
EXDIR_METANAME = "exdir"
TYPE_METANAME = "type"
VERSION_METANAME = "version"

# filenames
META_FILENAME = "exdir.yaml"
ATTRIBUTES_FILENAME = "attributes.yaml"
RAW_FOLDER_NAME = "__raw__"

# typenames
DATASET_TYPENAME = "dataset"
GROUP_TYPENAME = "group"
FILE_TYPENAME = "file"

struct Attributes
end

struct Object
end

struct Dataset
end

function Base.size(dset::Dataset)
    ()
end

Base.length(dset::Dataset) = prod(size(dset))

function Base.iterate(dset::Dataset)
    0
end

struct Group
    # root_directory
    # parent_path
    # object_name
    # file
end

struct File
    location::AbstractString
    writable::Bool
    # mode::AbstractString
    # allow_remove::Bool
    # name_validation
    # plugins
end

"""
    form_location(directory)

Prepare the given directory location for use by removing any trailing
slashes/directory signifiers, ensuring the directory ends with the `.exdir`
extension, and making the directory path absolute.
"""
function form_location(directory::AbstractString)
    normalized = if isdirpath(directory)
        dirname(directory)
    else
        directory
    end
    normalized = if splitext(normalized)[2] != ".exdir"
        normalized * ".exdir"
    else
        normalized
    end
    location = if isabspath(normalized)
        normalized
    else
        joinpath(pwd(), normalized)
    end
    location
end

# TODO should this instead correspond do
function parsemode(mode::AbstractString)
    mode == "r"  ? (writeable=false, create=false, truncate=false) :
    mode == "r+" ? (writeable=true, create=false, truncate=false) :
    mode == "a" || mode == "a+" ? (writeable=true, create=true, truncate=false) :
    mode == "w" || mode == "w+" ? (writeable=true, create=true, truncate=true) :
    throw(ArgumentError("invalid open mode: $mode"))
end

"""
    exdiropen(directory::AbstractString, mode::AbstractString)

Opens an ExDir tree at path `directory`.

`"r"`: Open for reading only, failing if no file exists
`"r+"`: Open for reading and writing, failing if no file exists
`"w"`/`"w+"`: Open for reading and writing, overwriting the file if it already exists
`"a"`/`"a+"`: Open for reading and writing, creating a new file if none exists, but
              preserving the existing file if one is present
"""
function exdiropen(directory::AbstractString, mode::AbstractString)::Exdir.File

    location = form_location(directory)
    (writeable, create, truncate) = parsemode(mode)
    already_exists = ispath(location)
    # is_directory = isdir(location)
    should_create_directory = false
    if !create
        if !already_exists
            throw(ArgumentError("mode='r' for $location but it doesn't exist"))
        # else if !isvalid()
        #     throw(ArgumentError("mode='r' for $location but it isn't a valid ExDir tree"))
        end
    else
        if truncate
            if already_exists
                rm(location, recursive=true)
            end
        end
        should_create_directory = true
    end

    if should_create_directory
        # name_validation(location)
        create_object_directory(location, defaultmetadata(FILE_TYPENAME))
    end

    Exdir.File(location, writeable)
end

# function exdiropen(directory::AbstractString, mode::AbstractString)
#     exdiropen(directory, mode, allow_remove=false)
# end

function Base.close(file::File)
    nothing
end

function Base.keys(file::File)
end

function Base.setindex!(attrs::Attributes, value, name::AbstractString)
end

function defaultmetadata(typename::String)
    Dict(EXDIR_METANAME => Dict(TYPE_METANAME => typename, VERSION_METANAME => 1))
end

makemetadata(typename::String) = YAML.write(defaultmetadata(typename))
makemetadata(_::Object) = error("makemetadata not implemented for Exdir.Object")
makemetadata(_::Dataset) = makemetadata(DATASET_TYPENAME)
makemetadata(_::Group) = makemetadata(GROUP_TYPENAME)
makemetadata(_::File) = makemetadata(FILE_TYPENAME)

# function setattrs!(f, "description", "This is a mock experiment with voltage values over time")
function setattrs!(obj, name::AbstractString, value)
    nothing
end

function attributes(object::Object)
    Attributes()
end

function attributes(dset::Dataset)
    Attributes()
end

function attributes(group::Group)
    Attributes()
end

function attributes(file::File)
    Attributes()
end

"""
    create_group(file, name)


"""
function create_group(file::File, name::AbstractString)
    Group()
end

struct Datatype
end

function create_dataset(grp::Group, name::AbstractString;
                        data)
    # TODO get shape (size) and dtype of data
    Dataset()
end

# function create_dataset(grp::Group, name::AbstractString;
#                         shape::Dims,
#                         dtype)
#     Dataset()
# end

function create_dataset(grp::Group, name::AbstractString;
                        shape::Dims)
    # create_dataset(grp, name; shape=shape, dtype=Float64)
    Dataset()
end

function Base.write(dset::Dataset, data)
    nothing
end

function is_nonraw_object_directory(directory::AbstractString)
    meta_filename = joinpath(directory, META_FILENAME)
    if !ispath(meta_filename) && !isfile(meta_filename)
        return false
    end
    meta_data = YAML.load_file(meta_filename)
    # is not instance of dict return false
    if !haskey(meta_data, EXDIR_METANAME)
        return false
    end
    if !haskey(meta_data[EXDIR_METANAME], TYPE_METANAME)
        return false
    end
    valid_types = [DATASET_TYPENAME, FILE_TYPENAME, GROUP_TYPENAME]
    if !(meta_data[EXDIR_METANAME][TYPE_METANAME] in valid_types)
        return false
    end
    true
end

"""
    create_object_directory(directory, metadata)

Create object directory and meta file if the directory doesn't already exist.

TODO say something about expected correctness of metadata dict.
"""
function create_object_directory(directory::AbstractString, metadata)
    if ispath(directory)
        throw(ArgumentError("The location '$directory' already exists"))
    end
    valid_types = [DATASET_TYPENAME, FILE_TYPENAME, GROUP_TYPENAME]
    typename = metadata[EXDIR_METANAME][TYPE_METANAME]
    if !(typename in valid_types)
        throw(("$typename is not a valid typename"))
    end
    mkdir(directory)
    YAML.write_file(joinpath(directory, META_FILENAME), metadata)
    nothing
end

end
