module OrthancTools

using OrderedCollections: OrderedDict
using Downloads: download
import HTTP
import JSON

export get_all_studies, get_all_series, get_all_instances, download_instances

"""
    get_all_studies(ip_address::String="localhost"; show_warnings=false)

Get all studies from an Orthanc server.

# Arguments
- `ip_address`: IP address corresponding to the Orthanc server
- `show_warnings`: Whether to show warnings for studies without accession numbers

# Returns
- `studies_dict`: An `OrderedDict` of every study name with its corresponding accession number

# Example
```julia
studies_dict = get_all_studies("128.000.00.00")
# OrderedDict("CTP006" => ["e44217cc-498e394b-dc380909-a742a65f-51530d58"], ...)
```
"""
function get_all_studies(ip_address::String="localhost"; show_warnings=false)
    url_studies = HTTP.URI(scheme="http", host=ip_address, port="8042", path="/studies")
    studies = JSON.parse(String(HTTP.get(url_studies).body))

    studies_dict = OrderedDict{String,Vector}()
    for study in studies
        s = JSON.parse(String(HTTP.get(string(url_studies, "/", study)).body))
        try
            accession_num = s["MainDicomTags"]["AccessionNumber"]
            if !haskey(studies_dict, accession_num)
                push!(studies_dict, accession_num => [study])
            else
                push!(studies_dict[accession_num], study)
            end
        catch
            if show_warnings
                @warn "No accession number for $study"
            end
        end
    end

    return studies_dict
end

"""
    get_all_series(studies_dict::OrderedDict, accession_num::String, ip_address::String="localhost")

Get all series for a specific study from an Orthanc server.

# Arguments
- `studies_dict`: A dictionary of all the studies in this server (see `get_all_studies`)
- `accession_num`: The accession number for the study of interest
- `ip_address`: IP address corresponding to the Orthanc server

# Returns
- `series_dict`: An `OrderedDict` of every series name with its corresponding series number

# Example
```julia
series_dict = get_all_series(studies_dict, "2475", "128.000.00.00")
# OrderedDict("1" => ["776d9eb6-34ff4a40-e252e29c-3d3b9806-db6a4d8b"], ...)
```
"""
function get_all_series(
    studies_dict::OrderedDict,
    accession_num::String,
    ip_address::String="localhost")

    url_study = HTTP.URI(scheme="http", host=ip_address, port="8042", path="/studies/$(studies_dict[accession_num]...)")

    series = JSON.parse(String(HTTP.get(url_study).body))
    series_dict = OrderedDict{String,Vector}()
    for ser in series["Series"]
        url_series = HTTP.URI(
            scheme="http", host=ip_address, port="8042", path=string("/series/", ser)
        )
        s = JSON.parse(String(HTTP.get(url_series).body))
        try
            series_num = s["MainDicomTags"]["SeriesNumber"]
            if !haskey(series_dict, series_num)
                push!(series_dict, series_num => [ser])
            else
                push!(series_dict[series_num], ser)
            end
        catch
            @warn "No series number for $ser"
        end
    end

    return series_dict
end

"""
    get_all_instances(series_dict::OrderedDict, series_num::String, ip_address::String="localhost")

Get all instances for a specific series from an Orthanc server.

# Arguments
- `series_dict`: A dictionary of all the series in this server (see `get_all_series`)
- `series_num`: The series number for the study of interest
- `ip_address`: IP address corresponding to the Orthanc server

# Returns
- `instances_dict`: An `OrderedDict` of every instance name with its corresponding series number

# Example
```julia
instances_dict = get_all_instances(series_dict, "4", "128.000.00.00")
# OrderedDict("4" => [["ddbcf7d1-eab7dfc6-1f507224-7a92be0c-4c08d055"], ...])
```
"""
function get_all_instances(
    series_dict::OrderedDict,
    series_num::String,
    ip_address::String="localhost")

    instances_dict = OrderedDict{String,Vector}()
    for ser in series_dict[series_num]
        url_series = HTTP.URI(
            scheme="http", host=ip_address, port="8042", path=string("/series/", ser)
        )
        series = JSON.parse(String(HTTP.get(url_series).body))
        instances = series["Instances"]
        if !haskey(instances_dict, series_num)
            push!(instances_dict, series_num => [instances])
        else
            push!(instances_dict[series_num], instances)
        end
    end
    return instances_dict
end

"""
    download_instances(instances_dict::OrderedDict, instance_num::Number, output_directory::String, ip_address::String="localhost")

Download specific instances from an Orthanc server.

# Arguments
- `instances_dict`: A dictionary of all the instances in this series (see `get_all_series`)
- `instance_num`: The instance number of the series that you want to download
- `output_directory`: The folder you want to save the DICOM files
- `ip_address`: IP address corresponding to the Orthanc server

# Returns
Nothing, but saves DICOM files to the specified output directory

# Example
```julia
output_dir = mktempdir()
download_instances(instances_dict, 1, output_dir, "128.000.00.00")
```
"""
function download_instances(
    instances_dict::OrderedDict,
    instance_num::Number,
    output_directory::String,
    ip_address::String="localhost")

    for (key, value) in instances_dict
        for i in value[instance_num]
            url_instance = string("http://", ip_address, ":8042", string("/instances/", i))
            instance = JSON.parse(String(HTTP.get(url_instance).body))
            idx = instance["IndexInSeries"]
            download(string(url_instance, "/", "file"), joinpath(output_directory, "$(idx).dcm"))
        end
    end
    return nothing
end

end
