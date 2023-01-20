### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

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
"""

# ╔═╡ 4b7bc42e-9958-4f96-8536-5afaee57ca1c
ip_address = "128.200.49.26"

# ╔═╡ 42a41536-c505-420d-8398-fd315793faa2
studies_dict = get_all_studies(ip_address)

# ╔═╡ fee1654e-9937-4723-aea3-e0b6ecee8ea6
md"""
## Get Series
"""

# ╔═╡ d38a8f79-38c2-4e72-8806-bece1eb63a3d
series_dict = get_all_series(studies_dict, "2475", ip_address)

# ╔═╡ 2da66929-7b74-4dfc-9dc1-840d6c739d6d
md"""
## Get Instances
"""

# ╔═╡ caa657f6-191f-4379-8d36-1140ed3138cc
instances_dict = get_all_instances(series_dict, "4", ip_address)

# ╔═╡ 512a7103-c925-4d5b-83a3-c7a1c2afc560
md"""
## Download Instances
"""

# ╔═╡ e91b87c8-401c-4c7c-b4ee-8e4fffb42eba
output_dir = mktempdir()

# ╔═╡ e87baf2f-46c0-4386-a192-2c298b0c705b
download_instances(instances_dict, 1, output_dir, ip_address)

# ╔═╡ Cell order:
# ╟─03d840a8-b426-4910-be0c-8fd0adb2da16
# ╟─7112e3ff-1037-412c-8df0-f185b16cc749
# ╟─fe44a1dd-0e9e-4ab0-905b-391e588af4e2
# ╟─05eb11b8-b3a0-4901-b8e5-b84f0656f04f
# ╠═2803587a-98e8-11ed-26b9-e9960fe8c897
# ╠═89c0b998-6a5a-4fd9-a323-35d96855b2a9
# ╟─f9e214eb-6432-4cf5-ba12-29911c4a161f
# ╠═4b7bc42e-9958-4f96-8536-5afaee57ca1c
# ╠═42a41536-c505-420d-8398-fd315793faa2
# ╟─fee1654e-9937-4723-aea3-e0b6ecee8ea6
# ╠═d38a8f79-38c2-4e72-8806-bece1eb63a3d
# ╟─2da66929-7b74-4dfc-9dc1-840d6c739d6d
# ╠═caa657f6-191f-4379-8d36-1140ed3138cc
# ╟─512a7103-c925-4d5b-83a3-c7a1c2afc560
# ╠═e91b87c8-401c-4c7c-b4ee-8e4fffb42eba
# ╠═e87baf2f-46c0-4386-a192-2c298b0c705b
