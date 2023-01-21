### A Pluto.jl notebook ###
# v0.19.18

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

# ╔═╡ 2803587a-98e8-11ed-26b9-e9960fe8c897
# ╠═╡ show_logs = false
begin
    using Pkg
    Pkg.activate(".")
    using Revise, PlutoUI, DICOM, OrthancTools
end

# ╔═╡ 03d840a8-b426-4910-be0c-8fd0adb2da16
title = "Getting Started";

# ╔═╡ 7112e3ff-1037-412c-8df0-f185b16cc749
"""
+++
title = "$title"
+++
""" |> Base.Text

# ╔═╡ fe44a1dd-0e9e-4ab0-905b-391e588af4e2
md"""
# $title
This is an example tutorial showing how to download files from an Orthanc server using Julia. This tutorial can be copied by importing this notebook's URL into Pluto directly.
"""

# ╔═╡ 05eb11b8-b3a0-4901-b8e5-b84f0656f04f
md"""
## Download packages
"""

# ╔═╡ 89c0b998-6a5a-4fd9-a323-35d96855b2a9
TableOfContents()

# ╔═╡ f9e214eb-6432-4cf5-ba12-29911c4a161f
md"""
## Get Studies
Insert the IP address associated with the Orthanc server into the input box below and then click the Check Box to begin locating all the studies
"""

# ╔═╡ fee1654e-9937-4723-aea3-e0b6ecee8ea6
md"""
## Get Series
Insert the accession number into the input box below and then click the Check Box
"""

# ╔═╡ 2da66929-7b74-4dfc-9dc1-840d6c739d6d
md"""
## Get Instances
You can insert the series number of interest into the input box below and then click the Check Box. When the code is finished, you can inspect the files by clicking on the dictionary and seeing the instances associated with the given series number. Note, some series have multiple instances (scans) while some only have one instance (one scan).
"""

# ╔═╡ 512a7103-c925-4d5b-83a3-c7a1c2afc560
md"""
## Download Instances
Type the folder path that you want to save the DICOM files into (or use a temporary directory via `mktempdir()`) in the code cell below. Then type in the instance number that you want to download and  click the CheckBox to start the download
"""

# ╔═╡ 86bb740b-5593-4951-8fd9-45b88e37bad8
output_dir = "/Users/daleblack/Documents/dcm_dir"

# ╔═╡ 70696008-32a6-436e-a013-dbe3550a6d7f
dcmdir_parse(output_dir)

# ╔═╡ 6fd14e1c-bfdc-43f4-a760-503fc0deb88f
md"""
# Appendix
"""

# ╔═╡ 151e1554-db05-4fdb-9b04-1f6c1e004b14
function input_values(placeholder="placeholder")
	
	return PlutoUI.combine() do Child
		
		inputs = [
			md"""$(Child(TextField(;placeholder=placeholder))
			)""";
			md"""$(Child(CheckBox()))
			"""
		]
		
		md"""
		$(inputs)
		"""
	end
end

# ╔═╡ 2b1696f6-4050-4e57-b385-e08e06e0469d
@bind ip_address input_values("Insert IP Address")

# ╔═╡ 42a41536-c505-420d-8398-fd315793faa2
if ip_address[2]
	studies_dict = get_all_studies(ip_address[1])
end

# ╔═╡ f933bec3-70ba-4b9d-adaa-59d8eb183aa1
@bind accession_number input_values("Insert Accession Number")

# ╔═╡ d38a8f79-38c2-4e72-8806-bece1eb63a3d
if accession_number[2]
	global series_dict = get_all_series(studies_dict, accession_number[1], ip_address[1])
end

# ╔═╡ 7e162ea2-6127-4d23-b844-0d69b80c2b10
@bind series_num input_values("Insert Instance Number")

# ╔═╡ caa657f6-191f-4379-8d36-1140ed3138cc
if series_num[2]
	global instances_dict = get_all_instances(series_dict, series_num[1], ip_address[1])
end

# ╔═╡ fdbe618f-e872-4d1f-93c2-bddb0b2ea55c
@bind instance_num input_values("Insert Instance Number")

# ╔═╡ e87baf2f-46c0-4386-a192-2c298b0c705b
if instance_num[2]
	instance_number = parse(Int64, instance_num[1])
	download_instances(instances_dict, instance_number, output_dir, ip_address[1])
end

# ╔═╡ Cell order:
# ╟─03d840a8-b426-4910-be0c-8fd0adb2da16
# ╟─7112e3ff-1037-412c-8df0-f185b16cc749
# ╟─fe44a1dd-0e9e-4ab0-905b-391e588af4e2
# ╟─05eb11b8-b3a0-4901-b8e5-b84f0656f04f
# ╠═2803587a-98e8-11ed-26b9-e9960fe8c897
# ╠═89c0b998-6a5a-4fd9-a323-35d96855b2a9
# ╟─f9e214eb-6432-4cf5-ba12-29911c4a161f
# ╟─2b1696f6-4050-4e57-b385-e08e06e0469d
# ╠═42a41536-c505-420d-8398-fd315793faa2
# ╟─fee1654e-9937-4723-aea3-e0b6ecee8ea6
# ╟─f933bec3-70ba-4b9d-adaa-59d8eb183aa1
# ╠═d38a8f79-38c2-4e72-8806-bece1eb63a3d
# ╟─2da66929-7b74-4dfc-9dc1-840d6c739d6d
# ╟─7e162ea2-6127-4d23-b844-0d69b80c2b10
# ╠═caa657f6-191f-4379-8d36-1140ed3138cc
# ╟─512a7103-c925-4d5b-83a3-c7a1c2afc560
# ╠═86bb740b-5593-4951-8fd9-45b88e37bad8
# ╟─fdbe618f-e872-4d1f-93c2-bddb0b2ea55c
# ╠═e87baf2f-46c0-4386-a192-2c298b0c705b
# ╠═70696008-32a6-436e-a013-dbe3550a6d7f
# ╟─6fd14e1c-bfdc-43f4-a760-503fc0deb88f
# ╠═151e1554-db05-4fdb-9b04-1f6c1e004b14
