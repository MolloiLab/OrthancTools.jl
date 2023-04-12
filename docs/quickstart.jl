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
Insert the accession number into the input box below and click "Submit". When the code is finished, you can inspect the files by clicking on the dictionary.
"""

# ╔═╡ cc9fb05a-cfd6-45da-89ab-2315ae0cf08d
@bind accession_number confirm(TextField(default="2475"))

# ╔═╡ a07a479a-830a-4a8f-a4de-1dc0b8156d8f
series_dict = get_all_series(studies_dict, accession_number, ip_address)

# ╔═╡ 1b64364c-7b47-41d9-aa09-91c37fc95183
md"""
## Get Instance(s)
You can insert the series number of interest into the input box below and then click "Submit". When the code is finished, you can inspect the files by clicking on the dictionary.
"""

# ╔═╡ b379470c-d3c8-48b1-875c-2caee044897b
@bind series_num confirm(TextField(default="3"))

# ╔═╡ 8f777827-6ddf-4421-809d-d0d8858542b4
instances_dict = get_all_instances(series_dict, series_num, ip_address)

# ╔═╡ 388bb92b-fc3f-4054-977a-1ca655c16e40
md"""
# Download DICOM Instance(s)
Type the folder path below, where you want the DICOM files to be saved (or use a temporary directory via `mktempdir()`) in the code cell below. Then type in the instance number that you want to download and click "Submit".
"""

# ╔═╡ a8d994d6-cbb0-416c-852b-d0d173195444
output_dir = mktempdir()

# ╔═╡ 6ec25c7e-4982-4f55-ae50-48880be2062c
@bind instance_num confirm(TextField(placeholder="Insert Instance Number (usually 1)"))

# ╔═╡ b8747a52-61a2-46ec-b5c6-8f29406251da
instance_number = parse(Int64, instance_num)

# ╔═╡ 8268df02-e085-4245-a3bc-5fa354bbad4e
download_instances(instances_dict, instance_number, output_dir, ip_address)

# ╔═╡ ece4cb9b-4eee-4317-b835-c803ee2781ef
dcms = dcmdir_parse(output_dir)

# ╔═╡ Cell order:
# ╠═38c7cb4b-b317-4de4-82db-39fcb8117215
# ╟─8868c105-5209-4479-80cb-bb0423b66524
# ╟─3089d9a4-389d-45ed-b9f3-7982a88448ee
# ╠═48008e07-b10d-4e37-853f-0169fe2cb4b1
# ╟─85c694aa-15d9-4da4-8dbe-0a0e02563761
# ╠═ee188b2c-d928-48be-a52e-d3fbdb3a3f70
# ╠═399ba33a-a44d-4395-a523-f17fab9149d9
# ╟─b1e145de-16fa-4adc-886b-e1260b9a6fa2
# ╠═cc9fb05a-cfd6-45da-89ab-2315ae0cf08d
# ╠═a07a479a-830a-4a8f-a4de-1dc0b8156d8f
# ╟─1b64364c-7b47-41d9-aa09-91c37fc95183
# ╠═b379470c-d3c8-48b1-875c-2caee044897b
# ╠═8f777827-6ddf-4421-809d-d0d8858542b4
# ╟─388bb92b-fc3f-4054-977a-1ca655c16e40
# ╠═a8d994d6-cbb0-416c-852b-d0d173195444
# ╠═6ec25c7e-4982-4f55-ae50-48880be2062c
# ╠═b8747a52-61a2-46ec-b5c6-8f29406251da
# ╠═8268df02-e085-4245-a3bc-5fa354bbad4e
# ╠═ece4cb9b-4eee-4317-b835-c803ee2781ef
