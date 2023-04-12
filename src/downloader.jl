### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ d8578dac-9845-11ed-324c-856950ed40c3
# ╠═╡ show_logs = false
begin
    using Pkg
    Pkg.activate("..")
    using Revise, PlutoUI, HTTP, JSON, Downloads, OrderedCollections
    using Downloads: download
end

# ╔═╡ 0771ec75-e37b-4fa8-906d-a6b1f3f51d6f
TableOfContents()

# ╔═╡ a8d7f303-4b86-4172-9425-da1c5c0daa66
ip_address = "128.200.49.26"

# ╔═╡ 93bc7b5c-97dc-4166-89e8-490e5366c7cb
md"""
## Get Studies
"""

# ╔═╡ 8e780f7b-53df-4e0b-bf3d-b4c1094b7b24
"""
```julia 
get_all_studies(ip_address::String="localhost")
```

#### Arguments
- `ip_address`: IP address corresponding to the Orthanc server

#### Returns
- `studies_dict`: An `OrderedDict` of every study name with its corresponding accession number

#### Example
```julia-repl
julia> studies_dict = get_all_studies("128.000.00.00")

studies_dict = OrderedDict("CTP006" => ["e44217cc-498e394b-dc380909-a742a65f-51530d58"], "2890" => ["30c04e76-4965d9e3-9ffd4fdc-b0e84651-325c9074", "30c04e76-4965d9e3-9ffd4fdc-b0e84651-895s9231"], more...)
```
"""
function get_all_studies(ip_address::String="localhost")
    url = string("http://", ip_address, ":8042")
    url_studies = joinpath(url, "studies")
    studies = JSON.parse(String(HTTP.get(url_studies).body))

    studies_dict = OrderedDict{String,Vector}()
    for study in studies
        s = JSON.parse(String(HTTP.get(joinpath(url_studies, study)).body))
        try
            accession_num = s["MainDicomTags"]["AccessionNumber"]
            if !haskey(studies_dict, accession_num)
                push!(studies_dict, accession_num => [study])
            else
                push!(studies_dict[accession_num], study)
            end
        catch
            @warn "No accession number for $study"
        end
    end

    return studies_dict
end

# ╔═╡ c17095fb-fe4d-458e-91f3-f94c48a785ec
export get_all_studies

# ╔═╡ 11082ead-55a8-48e7-9bbe-7856fa8d7903
# studies_dict = get_all_studies(ip_address)

# ╔═╡ 3540e706-ad58-4af2-b7c0-f83ae19edcd3
md"""
## Get Series
"""

# ╔═╡ 2c04e17b-9c6d-4a36-985c-c256a4397a8e
"""
```julia 
get_all_series(
	studies_dict::OrderedDict, 
	accession_num::String, 
	ip_address::String="localhost")
```

#### Arguments
- `studies_dict`: A dictionary of all the studies in this server (see `get_all_studies`)
- `accession_num`: The accession number for the study of interest
- `ip_address`: IP address corresponding to the Orthanc server

#### Return
- `series_dict`: An `OrderedDict` of every series name with its corresponding series number

#### Example
```julia-repl
julia> series_dict = get_all_series(studies_dict, "2475", "128.000.00.00")

series_dict = OrderedDict("1" => ["776d9eb6-34ff4a40-e252e29c-3d3b9806-db6a4d8b"], "2" => ["725fdc65-76d49a59-22f280ef-5c49f76e-9528dbb4", "bacca487-87933763-8d4b8253-aba41c21-cd57cad5"], more...)
```
"""
function get_all_series(
    studies_dict::OrderedDict,
    accession_num::String,
    ip_address::String="localhost")

    url = string("http://", ip_address, ":8042")
    url_study = joinpath(url, "studies", studies_dict[accession_num]...)
    @assert typeof(url_study) == String


    series = JSON.parse(String(HTTP.get(url_study).body))
    series_dict = OrderedDict{String,Vector}()
    for ser in series["Series"]
        url_series = joinpath(url, "series", ser)
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

# ╔═╡ 44b8bcae-9f64-4c1a-a98d-11d61a9fd747
export get_all_series

# ╔═╡ 6c3f471d-9a7b-454c-ab56-c19e6f0db07d
# series_dict = get_all_series(studies_dict, "2475", ip_address)

# ╔═╡ 2b291e5c-dafd-4914-aac7-212c4f8546c4
md"""
## Get Instances
"""

# ╔═╡ 9d7bc7f9-2970-4636-a74a-e6b761f8e215
"""
```julia 
get_all_instances(
    series_dict::OrderedDict,
    series_num::String,
    ip_address::String="localhost")
```

#### Arguments
- `series_dict`: A dictionary of all the series in this server (see `get_all_series`)
- `series_num`: The series number for the study of interest
- `ip_address`: IP address corresponding to the Orthanc server

#### Return
- `instances_dict`: An `OrderedDict` of every instance name with its corresponding series number (see `get_all_series`)

#### Example
```julia-repl
julia> instances_dict = get_all_instances(series_dict, "4", "128.000.00.00")

series_dict = OrderedDict("4" => ["ddbcf7d1-eab7dfc6-1f507224-7a92be0c-4c08d055", "0b643ae7-ecb881f6-c62055fb-3573fda4-b9c2abd2", more...], [, more...])
```
"""
function get_all_instances(
    series_dict::OrderedDict,
    series_num::String,
    ip_address::String="localhost")

    url = string("http://", ip_address, ":8042")
    instances_dict = OrderedDict{String,Vector}()
    for ser in series_dict[series_num]
        url_series = joinpath(url, "series", ser)
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

# ╔═╡ 4e6ee284-3ee8-4af9-a7b4-cdfdabf65732
export get_all_instances

# ╔═╡ 0d8cba11-deb7-4990-a295-b8cdd9070f93
# instances_dict = get_all_instances(series_dict, "4", ip_address)

# ╔═╡ 8c2c8651-c413-48ab-8ed4-b71c97e83c04
md"""
## Download Instances
"""

# ╔═╡ a864c9f7-50e2-4105-8494-48cf9ba1a50b
"""
```julia 
download_instances(
	instances_dict::OrderedDict,
	instance_num::Number,
	output_directory::String,
	ip_address::String="localhost")

```

#### Arguments
- `instances_dict`: A dictionary of all the instances in this series (see `get_all_series`)
- `instance_num`: The instance number of the series that you want to download
- `output_directory`: The folder you want to save the DICOM files
- `ip_address`: IP address corresponding to the Orthanc server

#### Return
- `output_directory`: The location where the DICOM file(s) will be saved

#### Example
```julia-repl
julia> output_dir = mktempdir()
julia> download_instances(instances_dict, 1, output_dir, "128.000.00.00")

Files located at /var/folders/t3/_k26tgtj7cv96l4vy3pxk5nw0000gn/T/jl_Hsbrwd
```
"""
function download_instances(
	instances_dict::OrderedDict,
	instance_num::Number,
	output_directory::String,
	ip_address::String="localhost")

	url = string("http://", ip_address, ":8042")
	for (key, value) in instances_dict
		for i in value[instance_num]
			url_instance = joinpath(url, "instances", i)
			instance = JSON.parse(String(HTTP.get(url_instance).body))
			idx = instance["IndexInSeries"]
			download(joinpath(url_instance, "file"), joinpath(output_directory, "$(idx).dcm"))
		end
	end
	@info "Files located at $(output_directory)"
end

# ╔═╡ 75b6606c-2e33-454b-98b7-a673f265b7ef
export download_instances

# ╔═╡ 3c7a573d-bc0b-4795-8838-a40dde7a9322
# output_dir = mktempdir()

# ╔═╡ ab9c97ce-ddf3-4d16-9271-bfc8239b7861
# download_instances(instances_dict, 1, output_dir, ip_address)

# ╔═╡ Cell order:
# ╠═d8578dac-9845-11ed-324c-856950ed40c3
# ╠═0771ec75-e37b-4fa8-906d-a6b1f3f51d6f
# ╠═a8d7f303-4b86-4172-9425-da1c5c0daa66
# ╟─93bc7b5c-97dc-4166-89e8-490e5366c7cb
# ╠═8e780f7b-53df-4e0b-bf3d-b4c1094b7b24
# ╠═c17095fb-fe4d-458e-91f3-f94c48a785ec
# ╠═11082ead-55a8-48e7-9bbe-7856fa8d7903
# ╟─3540e706-ad58-4af2-b7c0-f83ae19edcd3
# ╠═2c04e17b-9c6d-4a36-985c-c256a4397a8e
# ╠═44b8bcae-9f64-4c1a-a98d-11d61a9fd747
# ╠═6c3f471d-9a7b-454c-ab56-c19e6f0db07d
# ╟─2b291e5c-dafd-4914-aac7-212c4f8546c4
# ╠═9d7bc7f9-2970-4636-a74a-e6b761f8e215
# ╠═4e6ee284-3ee8-4af9-a7b4-cdfdabf65732
# ╠═0d8cba11-deb7-4990-a295-b8cdd9070f93
# ╟─8c2c8651-c413-48ab-8ed4-b71c97e83c04
# ╠═a864c9f7-50e2-4105-8494-48cf9ba1a50b
# ╠═75b6606c-2e33-454b-98b7-a673f265b7ef
# ╠═3c7a573d-bc0b-4795-8838-a40dde7a9322
# ╠═ab9c97ce-ddf3-4d16-9271-bfc8239b7861
