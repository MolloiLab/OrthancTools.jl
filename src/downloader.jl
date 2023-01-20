### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ d8578dac-9845-11ed-324c-856950ed40c3
# ╠═╡ show_logs = false
begin
	using Pkg; Pkg.activate("..")
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

	studies_dict = OrderedDict{String, Vector}()
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

# ╔═╡ 11082ead-55a8-48e7-9bbe-7856fa8d7903
studies_dict = get_all_studies(ip_address)

# ╔═╡ 3540e706-ad58-4af2-b7c0-f83ae19edcd3
md"""
## Get Series
"""

# ╔═╡ 2c04e17b-9c6d-4a36-985c-c256a4397a8e
"""
```julia 
get_all_series(
	study_dict::OrderedDict, 
	accession_num::String, 
	ip_address::String="localhost")
```

#### Arguments
- `study_dict`: A dictionary of all the studies in this server (see `get_all_studies`)
- `accession_num`: The accession number for the study of interest
- `ip_address`: IP address corresponding to the Orthanc server

#### Return
- `series_dict`: An `OrderedDict` of every series name with its corresponding series number

#### Example
```julia-repl
julia> series_dict = get_all_series(study_dict, "2475", "128.000.00.00")

series_dict = OrderedDict("1" => ["776d9eb6-34ff4a40-e252e29c-3d3b9806-db6a4d8b"], "2" => ["725fdc65-76d49a59-22f280ef-5c49f76e-9528dbb4", "bacca487-87933763-8d4b8253-aba41c21-cd57cad5"], more...)
```
"""
function get_all_series(
	study_dict::OrderedDict, 
	accession_num::String, 
	ip_address::String="localhost")
	
	url = string("http://", ip_address, ":8042")
	url_study = joinpath(url, "studies", study_dict[accession_num]...)
	@assert typeof(url_study) == String

	
	series = JSON.parse(String(HTTP.get(url_study).body))
	series_dict = OrderedDict{String, Vector}()
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

# ╔═╡ 6c3f471d-9a7b-454c-ab56-c19e6f0db07d
series_dict = get_all_series(studies_dict, "2475", ip_address)

# ╔═╡ 2b291e5c-dafd-4914-aac7-212c4f8546c4
md"""
## Get Instances
"""

# ╔═╡ Cell order:
# ╠═d8578dac-9845-11ed-324c-856950ed40c3
# ╠═0771ec75-e37b-4fa8-906d-a6b1f3f51d6f
# ╠═a8d7f303-4b86-4172-9425-da1c5c0daa66
# ╟─93bc7b5c-97dc-4166-89e8-490e5366c7cb
# ╠═8e780f7b-53df-4e0b-bf3d-b4c1094b7b24
# ╠═11082ead-55a8-48e7-9bbe-7856fa8d7903
# ╟─3540e706-ad58-4af2-b7c0-f83ae19edcd3
# ╠═2c04e17b-9c6d-4a36-985c-c256a4397a8e
# ╠═6c3f471d-9a7b-454c-ab56-c19e6f0db07d
# ╟─2b291e5c-dafd-4914-aac7-212c4f8546c4
