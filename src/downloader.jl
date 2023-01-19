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

Given an IP address corresponding to the Orthanc server's (`ip_address`), return an `OrderedDict` of every study name with its corresponding accession number
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
study_dict = get_all_studies(ip_address)

# ╔═╡ Cell order:
# ╠═d8578dac-9845-11ed-324c-856950ed40c3
# ╠═0771ec75-e37b-4fa8-906d-a6b1f3f51d6f
# ╠═a8d7f303-4b86-4172-9425-da1c5c0daa66
# ╟─93bc7b5c-97dc-4166-89e8-490e5366c7cb
# ╠═8e780f7b-53df-4e0b-bf3d-b4c1094b7b24
# ╠═11082ead-55a8-48e7-9bbe-7856fa8d7903
