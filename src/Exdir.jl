module Exdir

import YAML

export attributes,
    attrs,
    create_dataset,
    create_group,
    delete!,
    exdiropen,
    is_nonraw_object_directory,
    require_group,
    setattrs!

include("constants.jl")
include("mode.jl")
include("path.jl")

abstract type AbstractObject end

struct Attribute
end

struct Object <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Object(; root_directory, parent_path, object_name, file)
        relative_path = joinpath(parent_path, object_name)
        relative_path = if relative_path == "." "" else relative_path end
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

function Base.getproperty(obj::AbstractObject, sym::Symbol)
    if sym == :directory
        return joinpath(obj.root_directory, obj.relative_path)
    elseif sym == :attrs
        return Attribute()
    elseif sym == :meta
        return Attribute()
    elseif sym == :attributes_filename
        return joinpath(obj.directory, ATTRIBUTES_FILENAME)
    elseif sym == :meta_filename
        return joinpath(obj.directory, META_FILENAME)
    elseif sym == :parent
        if length(splitpath(obj.parent_path)) < 1
            return nothing
        end
        (parent_parent_path, parent_name) = splitdir(obj.parent_path)
        return Group(
            root_directory = obj.root_directory,
            parent_path = parent_parent_path,
            object_name = parent_name,
            file = obj.file,
        )
    else
        return getfield(obj, sym)
    end
end

function Base.setproperty!(obj::AbstractObject, f::Symbol, v)
    if f == :attrs
        nothing
    else
        setfield!(obj, f, v)
    end
end

struct Raw <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Raw(; root_directory, parent_path, object_name, file=nothing)
        relative_path = joinpath(parent_path, object_name)
        relative_path = if relative_path == "." "" else relative_path end
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

struct Dataset
end

function Base.iterate(dset::Dataset)
    ()
end

Base.length(dset::Dataset) = prod(size(dset))

function Base.size(dset::Dataset)
    ()
end

struct Group <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function Group(; root_directory, parent_path, object_name, file=nothing)
        relative_path = joinpath(parent_path, object_name)
        relative_path = if relative_path == "." "" else relative_path end
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end
end

function Base.in(name::AbstractString, grp::Group)
    false
end

function Base.get(grp::Group, name::AbstractString)
    nothing
end

function Base.getindex(grp::Group, name::AbstractString)
    nothing
end

function Base.iterate(grp::Group)
    ()
end

function Base.length(grp::Group)
    0
end

function delete!(grp::Group, name::AbstractString)
    nothing
end

struct File <: AbstractObject
    root_directory::String
    parent_path::String
    object_name::String
    file
    relative_path::String
    name::String

    function File(; root_directory, parent_path, object_name, file)
        relative_path = joinpath(parent_path, object_name)
        relative_path = if relative_path == "." "" else relative_path end
        name = "/" * relative_path
        new(
            root_directory,
            parent_path,
            object_name,
            file,
            relative_path,
            name
        )
    end

    # location::AbstractString
    # writable::Bool

    # mode::AbstractString
    # allow_remove::Bool
    # name_validation
    # plugins
end

function Base.in(name::AbstractString, file::File)
    false
end

function Base.iterate(::File)
    ("hello", "world")
end

function Base.iterate(::File, ::String)
    nothing
end

function delete!(file::File, name::AbstractString)
    nothing
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

    # Exdir.File(location, writeable)
    File(
        root_directory = location,
        parent_path = "",
        object_name = "",
        file = nothing,
    )
end

# function exdiropen(directory::AbstractString, mode::AbstractString)
#     exdiropen(directory, mode, allow_remove=false)
# end

function Base.close(file::File)
    nothing
end

function Base.keys(file::File)
end

function Base.setindex!(attrs::Attribute, value, name::AbstractString)
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
    Attribute()
end

function attributes(dset::Dataset)
    Attribute()
end

function attributes(group::Group)
    Attribute()
end

function attributes(file::File)
    Attribute()
end

function attrs(thing)
end

function create_raw(grp::Group, name::AbstractString)
end

function _create_group(x, name::AbstractString)
    path = name_to_asserted_group_path(name)
    if length(splitpath(path)) > 1
        (parent, pname) = splitdir(path)
        subgroup = require_group(x, parent)
        return create_group(subgroup, pname)
    end

    _assert_valid_name(path, x)

    if name in x
        throw(ArgumentError("'$name' already exists in $(x.name)"))
    end

    group_directory = joinpath(x.directory, path)
    create_object_directory(group_directory, defaultmetadata(GROUP_TYPENAME))

    Group(
        root_directory = x.root_directory,
        parent_path = x.relative_path,
        object_name = name,
        file = x.file,
    )
end

"""
    create_group(file, name)


"""
function create_group(file::File, name::AbstractString)
    path = remove_root(name)
    _create_group(file, name)
end

"""
    create_group(grp, name)


"""
function create_group(grp::Group, name::AbstractString)
    _create_group(grp, name)
end

# """
#     require_group(file, name)


# """
# function require_group(file::File, name::AbstractString)
#     path = remove_root(name)
#     Group(
#         root_directory =,
#         parent_path = ,
#         object_name = ,
#         file =,
#     )
# end

"""
    require_group(grp, name)


"""
function require_group(grp::Group, name::AbstractString)
    path = name_to_asserted_group_path(name)

    if length(splitpath(path)) > 1
        (parent, pname) = splitdir(path)
        subgroup = require_group(x, parent)
        return create_group(subgroup, pname)
    end

    group_directory = joinpath(grp.directory, path)

    if name in grp
        current_object = grp[name]
        if isa(current_object, Group)
            return current_object
        else
            throw(ArgumentError("An object with name '$name' already exists, but it is not a Group."))
        end
    elseif ispath(group_directory)
        throw(ArgumentError("Directory '$(group_directory)' already exists, but is not an Exdir object."))
    end

    create_group(grp, name)
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

function open_object(directory)
end

function is_nonraw_object_directory(directory::AbstractString)
    meta_filename = joinpath(directory, META_FILENAME)
    if !ispath(meta_filename) && !isfile(meta_filename)
        return false
    end
    meta_data = YAML.load_file(meta_filename)
    # TODO is not instance of dict return false
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

function _assert_valid_name(name::AbstractString, container)
    # container.file.name_validation(container.directory, name)
end

end
