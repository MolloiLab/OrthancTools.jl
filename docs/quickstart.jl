### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 38c7cb4b-b317-4de4-82db-39fcb8117215
# ╠═╡ show_logs = false
begin
    using Pkg
	Pkg.activate(mktempdir())
	Pkg.add(url="https://github.com/Dale-Black/OrthancTools.jl")
	Pkg.add(["PlutoUI", "DICOM"])
    using PlutoUI, DICOM, OrthancTools
	using PlutoUI: combine
end

# ╔═╡ 8868c105-5209-4479-80cb-bb0423b66524
md"""
# Quickstart
This is an example tutorial showing how to download files from an Orthanc server using Julia. This tutorial can be copied by importing this notebook's URL into Pluto directly.
"""

# ╔═╡ 3089d9a4-389d-45ed-b9f3-7982a88448ee
md"""
## Download packages
"""

# ╔═╡ 48008e07-b10d-4e37-853f-0169fe2cb4b1
TableOfContents()

# ╔═╡ 85c694aa-15d9-4da4-8dbe-0a0e02563761
md"""
## Get Studies
Insert the IP address associated with the Orthanc server into the input box below and then click "Submit". When the code is finished, you can inspect the files by clicking on the dictionary.
"""

# ╔═╡ ee188b2c-d928-48be-a52e-d3fbdb3a3f70
@bind ip_address confirm(TextField(default="128.200.49.26"))

# ╔═╡ 399ba33a-a44d-4395-a523-f17fab9149d9
studies_dict = get_all_studies(ip_address)

# ╔═╡ b1e145de-16fa-4adc-886b-e1260b9a6fa2
md"""
## Get Series
Insert the accession number into the input box above and click "Submit". When the code is finished, you can inspect the files by clicking on the dictionary.
"""

# ╔═╡ 1b64364c-7b47-41d9-aa09-91c37fc95183
md"""
## Get Instance(s)
You can insert the series number of interest into the input box above and then click "Submit". When the code is finished, you can inspect the files by clicking on the dictionary.
"""

# ╔═╡ 388bb92b-fc3f-4054-977a-1ca655c16e40
md"""
# Download DICOM Instance(s)
Type the folder path above, where you want the DICOM files to be saved (or use a temporary directory via `mktempdir()`) in the code cell below. Then type in the instance number that you want to download and click "Submit".
"""

# ╔═╡ 01d891cf-b48f-44a2-aea7-5af27c6ea1b4
function download_info(acc, ser, inst, save_folder_path)
	
	return PlutoUI.combine() do Child
		
		inputs = [
			md""" $(acc): $(
				Child(TextField(default="2581"))
			)""",
			md""" $(ser): $(
				Child(TextField(default="1, 2"))
			)""",
			md""" $(inst): $(
				Child(TextField(default="1"))
			)""",
			md""" $(save_folder_path): $(
				Child(TextField(default=(mktempdir())))
			)"""
		]
		
		md"""
		#### Scan Details
		Input the relevant DICOM information to download the appropriate scans
		$(inputs)
		"""
	end
end

# ╔═╡ 46d908ed-f841-4938-899f-e65de3004574
@bind details confirm(download_info("Accession Number", "Series Number(s)", "Instance Number", "Output Directory"))

# ╔═╡ 265f6407-62b2-483c-a803-05b94afe7e3f
accession_number, series_num, instance_num, output_dir = details

# ╔═╡ a07a479a-830a-4a8f-a4de-1dc0b8156d8f
series_dict = get_all_series(studies_dict, accession_number, ip_address)

# ╔═╡ 31f97455-006b-4ec7-a6df-0f3980b77835
series_num_vec = parse.(Int, split(series_num, ","))

# ╔═╡ 8f777827-6ddf-4421-809d-d0d8858542b4
begin
	instances_dicts = []
	for i in series_num_vec
		instances_dict = get_all_instances(series_dict, string(i), ip_address)
		push!(instances_dicts, instances_dict)
	end
end

# ╔═╡ b8182048-77e2-47f1-8171-cc7181990ff0
instances_dicts

# ╔═╡ b8747a52-61a2-46ec-b5c6-8f29406251da
instance_number = parse(Int64, instance_num)

# ╔═╡ 8268df02-e085-4245-a3bc-5fa354bbad4e
for i in 1:length(instances_dicts)
	global output_path = joinpath(output_dir, string(series_num_vec[i]))
	if !isdir(output_path)
		mkpath(output_path)
	end
	download_instances(instances_dicts[i], instance_number, output_path, ip_address)
end

# ╔═╡ ece4cb9b-4eee-4317-b835-c803ee2781ef
dcms = dcmdir_parse(output_path)

# ╔═╡ Cell order:
# ╟─8868c105-5209-4479-80cb-bb0423b66524
# ╟─3089d9a4-389d-45ed-b9f3-7982a88448ee
# ╠═38c7cb4b-b317-4de4-82db-39fcb8117215
# ╠═48008e07-b10d-4e37-853f-0169fe2cb4b1
# ╟─85c694aa-15d9-4da4-8dbe-0a0e02563761
# ╟─ee188b2c-d928-48be-a52e-d3fbdb3a3f70
# ╠═399ba33a-a44d-4395-a523-f17fab9149d9
# ╟─46d908ed-f841-4938-899f-e65de3004574
# ╠═265f6407-62b2-483c-a803-05b94afe7e3f
# ╟─b1e145de-16fa-4adc-886b-e1260b9a6fa2
# ╠═a07a479a-830a-4a8f-a4de-1dc0b8156d8f
# ╟─1b64364c-7b47-41d9-aa09-91c37fc95183
# ╠═31f97455-006b-4ec7-a6df-0f3980b77835
# ╠═8f777827-6ddf-4421-809d-d0d8858542b4
# ╠═b8182048-77e2-47f1-8171-cc7181990ff0
# ╟─388bb92b-fc3f-4054-977a-1ca655c16e40
# ╠═b8747a52-61a2-46ec-b5c6-8f29406251da
# ╠═8268df02-e085-4245-a3bc-5fa354bbad4e
# ╠═ece4cb9b-4eee-4317-b835-c803ee2781ef
# ╟─01d891cf-b48f-44a2-aea7-5af27c6ea1b4
