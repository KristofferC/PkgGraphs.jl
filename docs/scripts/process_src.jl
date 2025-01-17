"""
Documenter can't do proper (CommonMark) markdown parsing yet.
This is a hack so I can use the more modern feature in my src/ .md's anyway.
"""

parentdir = dirname
docdir = parentdir(@__DIR__)
srcdir = joinpath(docdir, src)
moddir = joinpath(docdir, srcmod)

function process_src()
    copy_src()
    modify_src_copy()
end

# Make a copy of the `src/` tree
copy_src() = cp(srcdir, moddir, force = true)

modify_src_copy() = modify_files(moddir, ".md") do file, md
    println("Checking [$file]")
    md |> rm_comments |> inline_linkdefs
end

htmlcomment = r"<!--.*?-->"s

rm_comments(md) = begin
    for m in eachmatch(htmlcomment, md)
        comment = m.match
        println("  Removing ", truncated(comment))
        if is_in_code_block(md, m)
            @warn "Removed a html comment in a code block."
        end
    end
    replace(md, htmlcomment => "")
end

truncated(s, l = 40) = first(s, l) * suffix(s, l)
suffix(s, l) = length(s) ≤ l ? "" : " …"

include("modify_src_copy/code_blocks.jl")
include("modify_src_copy/inline_linkdefs.jl")

modify_files(f, dir, ext) =
    for (root, _, files) in walkdir(dir), fname in files
        endswith(fname, ext) || continue
        path = relpath(joinpath(root, fname))
        contents = read(path, String)
        modified = f(path, contents)
        write(path, modified)
    end


# After `makedocs` has ran, the 'Edit on GitHub' links
# point to `src-mod`. So we need to change that back to `src`.
correct_edit_links() = modify_files(builddir, ".html") do file, html
    println("Correcting edit link in [$file]")
    correct_edit_link(html)
end

builddir = joinpath(docdir, "build")

correct_edit_link(html) = replace(
    html,
    Regex("(href *= *\"https://github.com/$repo/blob/$ref/docs)/$srcmod/")
    => SubstitutionString("\1/$src/")
)



# ~~wishlist~~

# - Detect raw html, and wrap in ```@raw html … ```
#       * Eg for <img width=…
#       * (This would obviate comment removal btw)
# - Proper package ;)
